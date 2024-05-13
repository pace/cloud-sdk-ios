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

extension AppKit {
    open class AppDrawer: UIView {
        public weak var delegate: AppDrawerProtocol?

        internal(set) public var appData: AppData
        internal(set) public var appViewController: AppViewController?

        var currentState: State = .collapsed
        var appWindow: AppWindow?

        private var didLayoutSubviews = false

        // MARK: - Gesture handling
        var isSlidingLocked = false
        var drawerWidthConstraint: NSLayoutConstraint?
        var drawerRightPaddingConstraint: NSLayoutConstraint? // To compensate the initial damping of the expand animation
        var expandOrOpenAppGestureRecognizer: UITapGestureRecognizer?
        var slideDrawerGestureRecognizer: UIPanGestureRecognizer?
        var slideStartX: CGFloat = 0
        let labelsPadding = AppDrawer.drawerSize + 8
        var lastSlideDirection: SlideDirection = .left

        var appDrawerBackgroundColor: UIColor = AppStyle.lightColor
        let appIconBackgroundColor: UIColor
        var distanceViewLeadingConstraint: NSLayoutConstraint?
        var subtitleTrailingConstraint: NSLayoutConstraint?

        public lazy var drawerBackgroundView: UIView = {
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

        lazy var distanceView: UIView = {
            let view = UIView()
            view.layer.cornerRadius = 4
            return view
        }()

        lazy var subtitleContainer: UIView = {
            let view = UIView()
            return view
        }()

        lazy var distanceIcon: UIImageView = {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.image = AppStyle.distanceIcon
            return imageView
        }()

        lazy var distanceLabel: UILabel = {
            let label = UILabel()
            label.font = AppStyle.regularFont(ofSize: 12)
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

        private lazy var metricFormatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .none
            formatter.maximumFractionDigits = 0
            return formatter
        }()

        public init(with appData: AppData) {
            self.appData = appData

            let appColorString = appData.appManifest?.iconBackgroundColor ?? ""
            appIconBackgroundColor = UIColor(hex: appColorString) ?? AppStyle.lightColor

            super.init(frame: CGRect())

            titleLabel.text = appData.appManifest?.name ?? L10n.defaultDrawerSecondLine
            subtitleLabel.text = appData.appManifest?.description ?? L10n.defaultDrawerFirstLine
            updateUserDistance(with: appData)

            setupGestureRecognizers()

            loadIcon()
        }

        required public init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        open override func layoutSubviews() {
            super.layoutSubviews()

            if !didLayoutSubviews {
                self.backgroundColor = .clear
                appImageBackgroundView.roundCorner(corners: .allCorners, radius: self.bounds.height / 2)
                drawerBackgroundView.addShadow(cornerRadius: self.bounds.height / 2, corners: [.topLeft, .bottomLeft], fillColor: appDrawerBackgroundColor)
                didLayoutSubviews = true
            }
        }

        func update(with appData: AppData) {
            self.appData = appData

            updateUserDistance(with: appData)
            subtitleTrailingConstraint?.isActive = appData.userDistance == nil || !appData.shouldShowDistance
            if appData.userDistance == nil || !appData.shouldShowDistance {
                distanceView.removeFromSuperview()
            } else if distanceView.superview == nil {
                layoutDistanceView()
            }
            layoutIfNeeded()
        }

        func setupView(theme: AppDrawerTheme) {
            switchTheme(to: theme)
            setupDesign()
            layoutView()
        }

        open func layoutView() {
            drawerWidthConstraint = self.widthAnchor.constraint(equalToConstant: Self.drawerSize)
            drawerWidthConstraint?.isActive = true

            [drawerBackgroundView, appImageBackgroundView].forEach(addSubview)
            [titleLabel, subtitleContainer, closeButton].forEach(drawerBackgroundView.addSubview)
            appImageBackgroundView.addSubview(appImageView)

            appImageBackgroundView.anchor(top: drawerBackgroundView.topAnchor,
                                          leading: drawerBackgroundView.leadingAnchor,
                                          bottom: drawerBackgroundView.bottomAnchor,
                                          size: .init(width: Self.drawerSize, height: Self.drawerSize))

            let closeButtonSize = Self.closeButtonSize
            let labelWidth = Self.drawerMaxWidth - labelsPadding - closeButtonSize + 16 // 16 == trailing inset label <-> closeButton

            titleLabel.anchor(leading: drawerBackgroundView.leadingAnchor,
                              bottom: drawerBackgroundView.bottomAnchor,
                              padding: .init(top: 0, left: labelsPadding, bottom: 9.5, right: 0),
                              size: .init(width: labelWidth, height: 0))

            subtitleContainer.anchor(top: drawerBackgroundView.topAnchor,
                                     leading: drawerBackgroundView.leadingAnchor,
                                     bottom: titleLabel.topAnchor,
                                     padding: .init(top: 9, left: labelsPadding, bottom: 4.5, right: 0),
                                     size: .init(width: labelWidth, height: 0))

            layoutSubtitleContainer()

            closeButton.anchor(centerY: drawerBackgroundView.centerYAnchor, size: .init(width: closeButtonSize, height: closeButtonSize))
            closeButton.anchor(trailing: drawerBackgroundView.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0))

            drawerBackgroundView.anchor(top: topAnchor, 
                                        leading: leadingAnchor,
                                        bottom: bottomAnchor,
                                        padding: .init(top: 0, left: 1, bottom: 0, right: 0),
                                        size: .init(width: 0, height: Self.drawerSize))

            drawerRightPaddingConstraint = drawerBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 20)
            drawerRightPaddingConstraint?.isActive = true

            appImageView.centerInSuperview(size: .init(width: Self.iconSize, height: Self.iconSize))
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
            distanceView.backgroundColor = appDrawerTextColor
            closeButton.setImage(AppStyle.roundCloseIcon.tinted(with: appDrawerTextColor), for: .normal)

            distanceIcon.tintColor = appDrawerBackgroundColor
            distanceLabel.textColor = appDrawerBackgroundColor
        }

        func setDrawerBackgroundViewColor(with color: UIColor) {
            (drawerBackgroundView.layer.sublayers?.first as? CAShapeLayer)?.fillColor = color.cgColor
        }

        open func expand() {
            isSlidingLocked = true
            drawerWidthConstraint?.constant = Self.drawerMaxWidth

            UIView.animate(withDuration: Self.animationDuration,
                           delay: 0,
                           usingSpringWithDamping: Self.damping,
                           initialSpringVelocity: Self.springVelocity,
                           options: .curveEaseOut,
                           animations: {

                self.setDrawerBackgroundViewColor(with: self.appDrawerBackgroundColor)
                self.layoutSuperviews()
            }, completion: { _ in
                self.isSlidingLocked = false
                self.drawerRightPaddingConstraint?.constant = 0
                self.layoutSuperviews()
            })

            // Animate appearance of close button
            UIView.animate(withDuration: Self.animationDuration / 3, animations: {
                self.activateCloseButton()
            })

            currentState = .expanded
        }

        open func collapse() {
            isSlidingLocked = true
            drawerWidthConstraint?.constant = Self.drawerSize

            deactivateCloseButtton()

            UIView.animate(withDuration: Self.animationDuration,
                           delay: 0,
                           usingSpringWithDamping: Self.damping,
                           initialSpringVelocity: Self.springVelocity,
                           options: .curveEaseOut,
                           animations: {

                self.setDrawerBackgroundViewColor(with: self.appIconBackgroundColor)
                self.layoutSuperviews()
            }, completion: { _ in
                self.isSlidingLocked = false
            })

            currentState = .collapsed
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

// MARK: - Private functions
extension AppKit.AppDrawer {
    private func layoutSubtitleContainer() {
        subtitleContainer.addSubview(subtitleLabel)
        subtitleTrailingConstraint = subtitleLabel.trailingAnchor.constraint(equalTo: subtitleContainer.trailingAnchor)
        subtitleTrailingConstraint?.isActive = !appData.shouldShowDistance

        if appData.shouldShowDistance {
            layoutDistanceView()
        }

        subtitleLabel.anchor(top: subtitleContainer.topAnchor,
                             leading: subtitleContainer.leadingAnchor,
                             bottom: subtitleContainer.bottomAnchor)
    }

    private func layoutDistanceView() {
        subtitleContainer.addSubview(distanceView)
        [distanceIcon, distanceLabel].forEach(distanceView.addSubview)
        distanceView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        subtitleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        distanceLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        distanceIcon.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        distanceView.trailingAnchor.constraint(lessThanOrEqualTo: subtitleContainer.trailingAnchor, constant: -16).isActive = true

        distanceView.anchor(top: subtitleContainer.topAnchor,
                            leading: subtitleLabel.trailingAnchor,
                            bottom: subtitleLabel.bottomAnchor,
                            padding: .init(top: 0, left: 6, bottom: 0, right: 0))

        distanceIcon.anchor(top: distanceView.topAnchor,
                            leading: distanceView.leadingAnchor,
                            bottom: distanceView.bottomAnchor,
                            padding: .init(top: 2, left: 4, bottom: 2, right: 0))

        distanceLabel.anchor(top: distanceView.topAnchor,
                             leading: distanceIcon.trailingAnchor,
                             bottom: distanceView.bottomAnchor,
                             trailing: distanceView.trailingAnchor,
                             centerY: distanceIcon.centerYAnchor,
                             padding: .init(top: 2, left: 4, bottom: 2, right: 4))
    }

    private func setupDesign() {
        self.appImageBackgroundView.backgroundColor = appIconBackgroundColor
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
              let icon = IconSelector.chooseSuitableDrawerIcon(in: icons,
                                                               requestedSize: (Int(Self.drawerSize), Int(Self.drawerSize))),
              let iconSource = icon.source,
              let iconUrlString = URLBuilder.buildAppIconUrl(baseUrl: appData.appBaseUrl, iconSrc: iconSource)
        else { return }

        appImageView.load(urlString: iconUrlString.absoluteString)
    }

    private func updateUserDistance(with appData: AppKit.AppData) {
        if appData.shouldShowDistance,
           let distance = appData.userDistance,
           let formattedDistance = metricFormatter.string(from: NSNumber(value: distance)) {
            distanceLabel.text = distance <= 10 ? "0 m" : "\(formattedDistance) m"
        }
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
    private func handleSlideGesture(gesture: UIPanGestureRecognizer) {
        guard !isSlidingLocked else { return }
        slide()
    }
}

extension AppKit.AppDrawer {
    enum State {
        case collapsed
        case expanded
    }

    enum SlideDirection {
        case left
        case right
    }
    
    public static let drawerSize: CGFloat = 64

    static let drawerMargin: CGFloat = 16
    static let drawerMaxWidth = UIScreen.main.bounds.width - drawerMargin

    static let iconSize: CGFloat = 40
    static let closeButtonSize: CGFloat = 48

    // Animations
    static let animationDuration: TimeInterval = 0.6
    static let damping: CGFloat = 0.7
    static let springVelocity: CGFloat = 0.5

    static func == (lhs: AppKit.AppDrawer, rhs: AppKit.AppDrawer) -> Bool {
        return lhs.appData == rhs.appData
    }
}
