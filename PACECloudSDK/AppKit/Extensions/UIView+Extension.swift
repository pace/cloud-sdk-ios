//
//  UIView+Extension.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import UIKit

extension UIView {
    func roundCorner(corners: UIRectCorner, radius: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }

    func addShadow(cornerRadius: CGFloat, corners: UIRectCorner, fillColor: UIColor = .white) {
        let shadowLayer = CAShapeLayer()
        let size = CGSize(width: cornerRadius, height: cornerRadius)
        let cgPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: size).cgPath
        shadowLayer.frame = self.bounds
        shadowLayer.path = cgPath
        shadowLayer.fillColor = fillColor.cgColor
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowPath = cgPath
        shadowLayer.shadowOffset = .init(width: 0, height: 0)
        shadowLayer.shadowOpacity = 0.6
        shadowLayer.shadowRadius = 5.0
        self.layer.insertSublayer(shadowLayer, at: 0)
    }
}

/* Constraints */
extension UIView {

    /** Programmatic constraints */
    struct AnchoredConstraints {
        var top, leading, bottom, trailing, centerX, centerY, width, height: NSLayoutConstraint?
    }

    /**
     Anchors this view instance with the specified constraints
     - parameter top: The top anchor of the view to align this view's top anchor to; not active if nil
     - parameter leading: The leading anchor of the view to align this view's leading anchor to; not active if nil
     - parameter bottom: The bottom anchor of the view to align this view's bottom anchor to; not active if nil
     - parameter trailing: The trailing anchor of the view to align this view's trailing anchor to; not active if nil
     - parameter centerX: The centerX anchor of the view to align this view's centerX anchor to; not active if nil
     - parameter centerY: The centerY anchor of the view to align this view's centerY anchor to; not active if nil
     - parameter padding: The desired edge insets. Zero by default
     - parameter size: The desired size for this view instance. Zero by default
     - returns: The anchored constraints (top, leading, bottom, trailing, centerX, centerY, width, height)
    */
    @discardableResult
    func anchor(top: NSLayoutYAxisAnchor? = nil,
                leading: NSLayoutXAxisAnchor? = nil,
                bottom: NSLayoutYAxisAnchor? = nil,
                trailing: NSLayoutXAxisAnchor? = nil,
                centerX: NSLayoutXAxisAnchor? = nil,
                centerY: NSLayoutYAxisAnchor? = nil,
                padding: UIEdgeInsets = .zero,
                size: CGSize = .zero) -> AnchoredConstraints {

        translatesAutoresizingMaskIntoConstraints = false
        var anchoredConstraints = AnchoredConstraints()

        if let top = top {
            anchoredConstraints.top = topAnchor.constraint(equalTo: top, constant: padding.top)
        }

        if let leading = leading {
            anchoredConstraints.leading = leadingAnchor.constraint(equalTo: leading, constant: padding.left)
        }

        if let bottom = bottom {
            anchoredConstraints.bottom = bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom)
        }

        if let trailing = trailing {
            anchoredConstraints.trailing = trailingAnchor.constraint(equalTo: trailing, constant: -padding.right)
        }

        if let centerX = centerX {
            anchoredConstraints.centerX = centerXAnchor.constraint(equalTo: centerX)
        }

        if let centerY = centerY {
           anchoredConstraints.centerY = centerYAnchor.constraint(equalTo: centerY)
        }

        if size.width != 0 {
            anchoredConstraints.width = widthAnchor.constraint(equalToConstant: size.width)
        }

        if size.height != 0 {
            anchoredConstraints.height = heightAnchor.constraint(equalToConstant: size.height)
        }

        [
            anchoredConstraints.top,
            anchoredConstraints.leading,
            anchoredConstraints.bottom,
            anchoredConstraints.trailing,
            anchoredConstraints.centerX,
            anchoredConstraints.centerY,
            anchoredConstraints.width,
            anchoredConstraints.height
        ].forEach { $0?.isActive = true }

        return anchoredConstraints
    }

    /**
     Aligns this view instance to all four edges of its superview
     - parameter padding: The desired edge insets. Zero by default
    */
    func fillSuperview(padding: UIEdgeInsets = .zero, safeArea: Bool = false) {
        translatesAutoresizingMaskIntoConstraints = false
        if let superviewTopAnchor = safeArea ? superview?.safeAreaLayoutGuide.topAnchor : superview?.topAnchor {
            topAnchor.constraint(equalTo: superviewTopAnchor, constant: padding.top).isActive = true
        }

        if let superviewBottomAnchor = safeArea ? superview?.safeAreaLayoutGuide.bottomAnchor : superview?.bottomAnchor {
            bottomAnchor.constraint(equalTo: superviewBottomAnchor, constant: -padding.bottom).isActive = true
        }

        if let superviewLeadingAnchor = superview?.leadingAnchor {
            leadingAnchor.constraint(equalTo: superviewLeadingAnchor, constant: padding.left).isActive = true
        }

        if let superviewTrailingAnchor = superview?.trailingAnchor {
            trailingAnchor.constraint(equalTo: superviewTrailingAnchor, constant: -padding.right).isActive = true
        }
    }

    /**
     Centers this view instance within its superview
     - parameter size: The desired size for this view instance. Zero by default
    */
    func centerInSuperview(size: CGSize = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        if let superviewCenterXAnchor = superview?.centerXAnchor {
            centerXAnchor.constraint(equalTo: superviewCenterXAnchor).isActive = true
        }

        if let superviewCenterYAnchor = superview?.centerYAnchor {
            centerYAnchor.constraint(equalTo: superviewCenterYAnchor).isActive = true
        }

        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }

        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }

    /** Removes all constraints from this view instance */
    func removeConstraints() {
        self.removeConstraints(constraints)
    }

    /**
     Sizes this view instance as desired
     - parameter size: The desired size for this view instance
    */
    func size(equalTo size: CGSize) {
        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }

        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }
}
