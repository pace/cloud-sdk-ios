//
//  AppDrawerContainer.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import UIKit

public extension AppKit {
    class AppDrawerContainer: UIView {
        private lazy var drawerStackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.distribution = .fillEqually
            stackView.spacing = 8
            stackView.alignment = .trailing
            return stackView
        }()

        public init() {
            super.init(frame: CGRect())

            NotificationCenter.default.addObserver(self, selector: #selector(handleAppClose), name: .appEventOccured, object: nil)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        @objc
        private func handleAppClose(notification: NSNotification) {
            guard let appEvent = notification.object as? AppEvent,
                  case let .escapedForecourt(gasStationId: id) = appEvent else { return }

            removeAppDrawer(with: id)
        }

        private func removeAppDrawer(with gasStationId: String) {
            DispatchQueue.main.async { [weak self] in
                guard let appDrawer = self?.drawerStackView.arrangedSubviews
                        .compactMap({ $0 as? AppDrawer })
                        .first(where: { $0.appData.poiId == gasStationId })
                else { return }
                appDrawer.removeFromSuperview()
            }
        }

        deinit {
            NotificationCenter.default.removeObserver(self)
        }
    }
}

public extension AppKit.AppDrawerContainer {
    func setupContainerView() {
        self.isHidden = true

        addSubview(drawerStackView)
        drawerStackView.fillSuperview()
    }

    func remove(_ drawer: AppKit.AppDrawer) {
        let subviews = drawerStackView.subviews as? [AppKit.AppDrawer]
        subviews?.forEach { presentedDrawer in
            if drawer.appData == presentedDrawer.appData {
                presentedDrawer.removeFromSuperview()
            }
        }
    }

    func inject(_ drawers: [AppKit.AppDrawer], theme: AppKit.AppDrawerTheme) {
        // Only add those which are not already visible
        let subviews = drawerStackView.subviews as? [AppKit.AppDrawer]
        let subviewsToRemove = subviews?.filter { presentedDrawer in
            !drawers.contains(where: { $0.appData == presentedDrawer.appData })
        }

        let appDrawersToAdd = drawers.filter { newDrawer in
            guard let subviews = subviews else { return true }
            return subviews.isEmpty || !subviews.contains(where: { $0.appData == newDrawer.appData })
        }

        subviewsToRemove?.forEach { $0.removeFromSuperview() }

        appDrawersToAdd.forEach {
            drawerStackView.addArrangedSubview($0)
            $0.setupView(theme: theme)

            // Temporary fix
            // Shadow sub layer won't fill the view if started in collapsed state
            $0.expand()
            $0.collapse()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isHidden = false
            appDrawersToAdd.forEach {
                $0.expand()
            }
        }
    }

    func switchTheme(to theme: AppKit.AppDrawerTheme) {
        let drawers = drawerStackView.subviews as? [AppKit.AppDrawer]
        drawers?.forEach {
            $0.switchTheme(to: theme)
        }
    }

    /**
     Force closes currently displayed apps by the app drawers.
     - parameter gasStationIds: Specifies which apps to close. If not specified all apps will be closed.
     */
    func forceCloseAppDrawerApps(_ gasStationIds: [String]? = nil) {
        let currentDrawers = drawerStackView.arrangedSubviews.compactMap({ $0 as? AppKit.AppDrawer })

        let relevantDrawers: [AppKit.AppDrawer]
        if let gasStationIds = gasStationIds {
            relevantDrawers = currentDrawers.filter { gasStationIds.contains($0.appData.poiId) }
        } else {
            relevantDrawers = currentDrawers
        }

        relevantDrawers.forEach {
            $0.forceCloseApp()
        }
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        var hitDrawer: Bool = false
        drawerStackView.subviews.forEach { drawer in
            guard !hitDrawer else { return }
            hitDrawer = drawer.frame.contains(point)
        }

        return hitDrawer ? super.hitTest(point, with: event) : nil
    }
}
