//
//  AppDrawer+Gestures.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import UIKit

extension AppKit.AppDrawer {
    func expand() {
        isSlidingLocked = true
        drawerWidthConstraint?.constant = AppStyle.drawerMaxWidth

        UIView.animate(withDuration: AppStyle.animationDuration,
                       delay: 0,
                       usingSpringWithDamping: AppStyle.damping,
                       initialSpringVelocity: AppStyle.springVelocity,
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
        UIView.animate(withDuration: AppStyle.animationDuration / 3, animations: {
            self.activateCloseButton()
        })

        currentState = .expanded
    }

    func collapse() {
        isSlidingLocked = true
        drawerWidthConstraint?.constant = AppStyle.drawerSize

        deactivateCloseButtton()

        UIView.animate(withDuration: AppStyle.animationDuration,
                       delay: 0,
                       usingSpringWithDamping: AppStyle.damping,
                       initialSpringVelocity: AppStyle.springVelocity,
                       options: .curveEaseOut,
                       animations: {

                        self.setDrawerBackgroundViewColor(with: self.appIconBackgroundColor)
                        self.layoutSuperviews()
        }, completion: { _ in
            self.isSlidingLocked = false
        })

        currentState = .collapsed
    }

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

            if newWidth < AppStyle.drawerSize || newWidth > AppStyle.drawerMaxWidth {
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

    private func layoutSuperviews() {
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
