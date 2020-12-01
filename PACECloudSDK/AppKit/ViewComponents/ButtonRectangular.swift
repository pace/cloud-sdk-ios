//
//  ButtonRectangular.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import UIKit

class ButtonRectangular: UIButton {
    var cornerRadius: CGFloat = 2.0 {
        didSet {
            setNeedsDisplay()
        }
    }

    var isBordered: Bool = false {
        didSet {
            setNeedsDisplay()
            updateColors()
        }
    }

    // sometimes iOS returns not the tint color we have set before
    var highlightedColor: UIColor = AppStyle.textColor2

    private var _tintColor = AppStyle.textColor2 {
        didSet {
            setNeedsDisplay()
            updateColors()
        }
    }

    override var tintColor: UIColor! {
        get {
            return _tintColor
        }

        set {
            _tintColor = newValue
        }
    }

    override var intrinsicContentSize: CGSize {
        let intrinsicContentSize = super.intrinsicContentSize

        let adjustedWidth = intrinsicContentSize.width + titleEdgeInsets.left + titleEdgeInsets.right
        let adjustedHeight = intrinsicContentSize.height + titleEdgeInsets.top + titleEdgeInsets.bottom

        return CGSize(width: adjustedWidth, height: adjustedHeight)
    }

    override var isEnabled: Bool {
        didSet {
            setNeedsDisplay()
        }
    }

    override var isHighlighted: Bool {
        didSet {
            setNeedsDisplay()
        }
    }

    override var isSelected: Bool {
        didSet {
            setNeedsDisplay()
        }
    }

    var loadingIndicator: UIActivityIndicatorView?
    var isLoading: Bool = false {
        didSet {
            isLoadingChanged()
        }
    }

    // MARK: - Action with closure
    fileprivate var tapAction: ((UIButton) -> Void)?

    var adjustDisabledColor = true

    override init(frame: CGRect) {
        super.init(frame: frame)

        titleLabel?.font = AppStyle.regularFont(ofSize: 18)
        titleEdgeInsets = UIEdgeInsets(top: 13, left: 13, bottom: 13, right: 13)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        var buttonColor: UIColor = self.tintColor ?? AppStyle.textColor2
        let lineWidth: CGFloat = 1.0
        var rect = rect

        withGraphicsContext { _ in
            let path = UIBezierPath(rect: rect)
            path.addClip()

            if isBordered {
                rect = rect.insetBy(dx: lineWidth / 2, dy: lineWidth / 2)
            }

            let rectanglePath = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
            if self.isHighlighted {
                buttonColor = buttonColor.darken(0.35)
            } else if !isEnabled && adjustDisabledColor {
                buttonColor = buttonColor.darken(0.6)
            }

            if isBordered {
                buttonColor.setStroke()
                rectanglePath.lineWidth = lineWidth
                rectanglePath.stroke()
            } else {
                buttonColor.setFill()
                rectanglePath.fill()
            }
        }
    }

    func withGraphicsContext(block: (CGContext?) -> Void) {
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        block(context)
        context?.restoreGState()
    }

    func addAction(_ action: ((UIButton) -> Void)?, forControlEvents controlEvents: UIControl.Event) {
        tapAction = action
        addTarget(self, action: #selector(callAction), for: controlEvents)
    }

    @objc
    func callAction(_ sender: AnyObject) {
        if let sender = sender as? ButtonRectangular {
            tapAction?(sender)
        }
    }

    func updateColors() {
        let buttonColor: UIColor = isBordered ? (self.tintColor ?? AppStyle.textColor2) : AppStyle.whiteColor
        setTitleColor(buttonColor, for: .normal)
        setTitleColor(buttonColor.darken(0.35), for: .highlighted)
        setTitleColor(buttonColor.darken(0.35), for: .selected)
        setTitleColor(adjustDisabledColor ? buttonColor.darken(0.6) : buttonColor, for: .disabled)
    }

    func isLoadingChanged() {
        DispatchQueue.main.async {
            if self.isLoading {
                guard self.loadingIndicator == nil else {
                    self.loadingIndicator?.startAnimating()
                    return
                }

                self.titleLabel?.alpha = 0.0
                let loadingIndicator = UIActivityIndicatorView()
                loadingIndicator.color = self.titleColor(for: UIControl.State())
                self.addSubview(loadingIndicator)
                loadingIndicator.startAnimating()

                loadingIndicator.removeConstraints()
                loadingIndicator.fillSuperview()

                self.loadingIndicator = loadingIndicator
            } else {
                self.titleLabel?.alpha = 1.0
                self.loadingIndicator?.removeFromSuperview()
                self.loadingIndicator = nil
            }
        }
    }
}
