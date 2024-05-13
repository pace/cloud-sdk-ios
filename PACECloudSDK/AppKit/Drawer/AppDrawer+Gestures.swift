//
//  AppDrawer+Gestures.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import UIKit

extension AppKit.AppDrawer {
    func slide() {
        guard let gesture = slideDrawerGestureRecognizer,
         let widthConstraint = drawerWidthConstraint else { return }

        let p: CGPoint = gesture.location(in: self)

        if gesture.state == .began {
            slideStartX = p.x
            setDrawerBackgroundViewColor(with: appDrawerBackgroundColor)
        } else if gesture.state == .changed {
            let widthDelta = p.x - slideStartX
            lastSlideDirection = widthDelta >= 0 ? .right : .left
            let newWidth = widthConstraint.constant - widthDelta

            if newWidth < Self.drawerSize || newWidth > Self.drawerMaxWidth {
                return
            }

            widthConstraint.constant = newWidth
            toggleCloseButtonVisibility()

            layoutSuperviews()
        } else if gesture.state == .ended {
            if lastSlideDirection == .right {
                collapse()
            } else {
                expand()
            }
        }
    }

    func activateCloseButton() {
        closeButton.layer.opacity = 1
        closeButton.isEnabled = true
    }

    func deactivateCloseButtton() {
        closeButton.layer.opacity = 0
        closeButton.isEnabled = false
    }

    private func toggleCloseButtonVisibility() {
        let labelsMaxWidth = max(titleLabel.bounds.width, subtitleLabel.bounds.width)
        let minXValue = closeButton.frame.minX - labelsPadding
        let spacing = labelsMaxWidth - minXValue // spacing between largest label and closeButton
        guard closeButton.bounds.width > 0 else { return }
        let ratio = spacing / closeButton.bounds.width
        closeButton.layer.opacity = Float(1 - ratio)
    }

    func layoutSuperviews() {
        // self -> stackView -> containerView -> clientParentView
        self.superview?.superview?.superview?.layoutIfNeeded()
    }
}

extension AppKit.AppDrawer: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
