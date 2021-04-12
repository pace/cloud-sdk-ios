//
//  AppDrawer.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import UIKit

public protocol AppDrawerProtocol: AnyObject {
    func didOpenApp()
    func didDisableApp(_ appDrawer: AppKit.AppDrawer, host: String)
}

public extension AppKit {
    open class AppDrawer: UIView {
        public let appData: AppData
        public var currentState: State = .collapsed
        public weak var delegate: AppDrawerProtocol?
        internal(set) public var appViewController: AppViewController?

        var appWindow: AppWindow?

        private var didLayoutSubviews = false

        // MARK: - Gesture handling
        var isSlidingLocked = false
        var drawerWidthConstraint: NSLayoutConstraint?
        var drawerRightPaddingConstraint: NSLayoutConstraint? // To compensate the initial damping of the expand animation
        var expandOrOpenAppGestureRecognizer: UITapGestureRecognizer?
        var slideDrawerGestureRecognizer: UIPanGestureRecognizer?
        var slideStartX: CGFloat = 0
        let labelsPadding = AppStyle.drawerSize + 8
        var lastSlideDirection: SlideDirection = .left

        var appDrawerBackgroundColor: UIColor = AppStyle.lightColor
        let appIconBackgroundColor: UIColor

        lazy var drawerBackgroundView: UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = .clear
            return view
        }()

        lazy var closeButton: UIButton = {
            let button = UIButton()
            button.setTitleColor(.white, for: .normal)
            button.addTarget(self, action: #selector(handleCollapse), for: .touchUpInside)
            button.layer.opacity = 1
            return button
        }()

        lazy var titleLabel: UILabel = {
            let label = UILabel()
            label.font = AppStyle.regularFont(ofSize: 20)
            return label
        }()

        lazy var subtitleLabel: UILabel = {
            let label = UILabel()
            label.font = AppStyle.regularFont(ofSize: 16)
            return label
        }()

        private lazy var appImageBackgroundView: UIView = {
            let view = UIView()
            view.clipsToBounds = true
            return view
        }()

        private lazy var appImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true
            return imageView
        }()

        public init(with appData: AppData) {
            self.appData = appData

            let appColorString = appData.appManifest?.iconBackgroundColor ?? ""
            appIconBackgroundColor = UIColor(hex: appColorString) ?? AppStyle.lightColor

            super.init(frame: CGRect())

            titleLabel.text = appData.appManifest?.name ?? "Name Placeholder"
            subtitleLabel.text = appData.appManifest?.description ?? "Description Placeholder"

            setupGestureRecognizers()

            loadIcon()
        }

        required public init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        public override func layoutSubviews() {
            super.layoutSubviews()

            if !didLayoutSubviews {
                self.backgroundColor = .clear
                appImageBackgroundView.roundCorner(corners: .allCorners, radius: self.bounds.height / 2)
                drawerBackgroundView.addShadow(cornerRadius: self.bounds.height / 2, corners: [.topLeft, .bottomLeft], fillColor: appDrawerBackgroundColor)
                didLayoutSubviews = true
            }
        }

        func setupView(theme: AppDrawerTheme) {
            switchTheme(to: theme)
            setupDesign()
            layoutView()
            addCloseButton()
        }

        func switchTheme(to theme: AppDrawerTheme) {
            let appDrawerBackgroundColor: UIColor
            let appDrawerTextColor: UIColor

            if let manifest = appData.appManifest,
                let themeColorString = manifest.themeColor,
                let textColorString = manifest.textColor,
                let themeColor = UIColor(hex: themeColorString),
                let textColor = UIColor(hex: textColorString) {

                appDrawerBackgroundColor = themeColor
                appDrawerTextColor = textColor
            } else {
                appDrawerBackgroundColor = theme == .light ? AppStyle.lightColor : AppStyle.darkColor
                appDrawerTextColor = UIColor.contrastColor(hex: appDrawerBackgroundColor.hexString)
            }

            self.appDrawerBackgroundColor = appDrawerBackgroundColor

            let currentStateDrawerBackgroundColor = currentState == .collapsed ? appIconBackgroundColor : appDrawerBackgroundColor
            setDrawerBackgroundViewColor(with: currentStateDrawerBackgroundColor)

            titleLabel.textColor = appDrawerTextColor
            subtitleLabel.textColor = appDrawerTextColor
            closeButton.setImage(AppStyle.roundCloseIcon.tinted(with: appDrawerTextColor), for: .normal)
        }

        func setDrawerBackgroundViewColor(with color: UIColor) {
            (drawerBackgroundView.layer.sublayers?.first as? CAShapeLayer)?.fillColor = color.cgColor
        }

        private func setupGestureRecognizers() {
            expandOrOpenAppGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didPressAppDrawer))
            self.addGestureRecognizer(expandOrOpenAppGestureRecognizer!) // swiftlint:disable:this force_unwrapping

            slideDrawerGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleSlideGesture))
            slideDrawerGestureRecognizer?.delegate = self
            self.addGestureRecognizer(slideDrawerGestureRecognizer!) // swiftlint:disable:this force_unwrapping
        }

        private func loadIcon() {
            guard let manifest = appData.appManifest,
                let icons = manifest.icons,
                let icon = IconSelector.chooseSuitableDrawerIcon(in: icons),
                let iconSource = icon.source,
                let iconUrlString = URLBuilder.buildAppIconUrl(baseUrl: appData.appBaseUrl, iconSrc: iconSource)
            else { return }

            appImageView.load(urlString: iconUrlString)
        }

        private func setupDesign() {
            self.appImageBackgroundView.backgroundColor = appIconBackgroundColor
        }

        @objc
        private func didPressAppDrawer() {
            handleExpandOrOpenApp()
        }

        private func handleExpandOrOpenApp() {
            if currentState == .collapsed {
                expand()
            } else if currentState == .expanded {
                prepareForOpenApp()
            }
        }

        @objc
        private func handleCollapse() {
            guard currentState == .expanded else { return }
            collapse()
        }

        @objc
        func handleSlideGesture(gesture: UIPanGestureRecognizer) {
            guard !isSlidingLocked else { return }
            slide()
        }

        deinit {
            appWindow = nil
            appViewController = nil

            if let expandOrOpenAppGestureRecognizer = expandOrOpenAppGestureRecognizer {
                self.removeGestureRecognizer(expandOrOpenAppGestureRecognizer)
            }

            if let slideDrawerGestureRecognizer = slideDrawerGestureRecognizer {
                self.removeGestureRecognizer(slideDrawerGestureRecognizer)
            }
        }
    }
}

extension AppKit.AppDrawer {
    public enum State {
        case collapsed
        case expanded
    }

    public enum SlideDirection {
        case left
        case right
    }
}

/* View Setup */
extension AppKit.AppDrawer {
    private func layoutView() {
        anchor(size: .init(width: 0, height: AppStyle.drawerSize))

        drawerWidthConstraint = self.widthAnchor.constraint(equalToConstant: AppStyle.drawerSize)
        drawerWidthConstraint?.isActive = true

        addSubview(drawerBackgroundView)
        addSubview(appImageBackgroundView)

        appImageBackgroundView.addSubview(appImageView)
        drawerBackgroundView.addSubview(titleLabel)
        drawerBackgroundView.addSubview(subtitleLabel)

        appImageBackgroundView.anchor(top: topAnchor,
                                      leading: leadingAnchor,
                                      bottom: bottomAnchor,
                                      size: .init(width: AppStyle.drawerSize, height: AppStyle.drawerSize))

        titleLabel.anchor(leading: drawerBackgroundView.leadingAnchor,
                          bottom: drawerBackgroundView.bottomAnchor,
                          padding: .init(top: 0, left: labelsPadding, bottom: 9.5, right: 0))

        subtitleLabel.anchor(top: drawerBackgroundView.topAnchor,
                             leading: drawerBackgroundView.leadingAnchor,
                             bottom: titleLabel.topAnchor,
                             padding: .init(top: 9, left: labelsPadding, bottom: 4.5, right: 0))

        drawerBackgroundView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, padding: .init(top: 0, left: 1, bottom: 0, right: 0))

        drawerRightPaddingConstraint = drawerBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 20)
        drawerRightPaddingConstraint?.isActive = true

        let iconSize = AppStyle.iconSize
        appImageView.centerInSuperview(size: .init(width: iconSize, height: iconSize))
    }

    func addCloseButton() {
        drawerBackgroundView.addSubview(closeButton)

        let size = AppStyle.closeButtonSize
        closeButton.anchor(centerY: drawerBackgroundView.centerYAnchor, size: .init(width: size, height: size))
        closeButton.anchor(trailing: drawerBackgroundView.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0))
    }
}

public extension AppKit.AppDrawer {
    static func == (lhs: AppKit.AppDrawer, rhs: AppKit.AppDrawer) -> Bool {
        return lhs.appData == rhs.appData
    }
}
