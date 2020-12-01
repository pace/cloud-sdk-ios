//
//  PaymentConfirmationViewController.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import LocalAuthentication
import UIKit

protocol PaymentConfirmationControllerDelegate: class {
    func paymentConfirmationController(didFinishWithResult result: PaymentConfirmationViewController.PaymentConfirmationResult)
}

protocol PaymentConfirmationControllerDataSource: class {
    func paymentConfirmationController(dataFor paymentController: PaymentConfirmationViewController) -> PaymentConfirmationData
}

// swiftlint:disable type_body_length file_length
class PaymentConfirmationViewController: UIViewController {
    weak var delegate: PaymentConfirmationControllerDelegate?
    weak var datasource: PaymentConfirmationControllerDataSource?

    let contentHeight = CGFloat(475)
    let edgePadding: CGFloat = 19

    private var isPresenting = false

    enum PaymentConfirmationResult: String {
        case success
        case canceled
    }

    lazy var backdropView: UIView = {
        let view = UIView()
        view.backgroundColor = AppStyle.gray1Color
        return view
    }()

    lazy var contentView: UIView = UIView()

    lazy var gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [AppStyle.gray4Color.cgColor,
                     AppStyle.gray2Color.cgColor]
        return gradientLayer
    }()

    lazy var pacePayLogo: UIImageView = {
        let imageView = UIImageView(image: AppStyle.pacePayLogoSmall)
        imageView.contentMode = .left
        return imageView
    }()

    lazy var cancelButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = AppStyle.mediumFont(ofSize: 16)
        button.addTarget(self, action: #selector(dismiss(_:)), for: .touchUpInside)
        button.titleLabel?.textAlignment = .right
        button.setTitle("action.cancel".localized, for: .normal)
        return button
    }()

    lazy var logoSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = AppStyle.gray2Color
        return view
    }()

    lazy var recipientPurpose: UILabel = {
        let label = UILabel()
        label.text = "Recipient - Purpose"
        label.textColor = AppStyle.textColor2
        label.font = AppStyle.lightFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()

    lazy var paymentAccount: UILabel = {
        let label = UILabel()
        label.text = "PACE Pay"
        label.textColor = AppStyle.whiteColor
        label.font = AppStyle.regularFont(ofSize: 22)
        label.textAlignment = .center
        return label
    }()

    lazy var paymentMethodKind: UILabel = {
        let label = UILabel()
        label.text = "PaymentMethodKind"
        label.textColor = AppStyle.textColor2
        label.font = AppStyle.lightFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()

    lazy var paymentMethodSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = AppStyle.gray2Color
        return view
    }()

    lazy var price: UILabel = {
        let label = UILabel()
        label.textColor = AppStyle.whiteColor
        label.font = AppStyle.regularFont(ofSize: 40)
        label.textAlignment = .center
        return label
    }()

    lazy var amountLabelDescription: UILabel = {
        let label = UILabel()
        label.text = "payment.method.amount.description".localized
        label.textColor = AppStyle.textColor2
        label.font = AppStyle.lightFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()

    lazy var authenticateButton: ButtonRectangular = {
        let button = ButtonRectangular()
        button.tintColor = AppStyle.blueColor
        button.addTarget(self, action: #selector(authenticate), for: .touchUpInside)
        button.titleLabel?.font = AppStyle.regularFont(ofSize: 18)
        button.setTitle("payment.payButton.title".localized, for: .normal)
        button.cornerRadius = 4.0
        button.backgroundColor = .clear
        return button
    }()

    lazy var successfulLoadingIndicator: AppActivityIndicatorView = {
        let indicator = AppActivityIndicatorView()
        indicator.alpha = 0
        return indicator
    }()

    lazy var successfulLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppStyle.textColor1
        label.font = AppStyle.regularFont(ofSize: 17)
        label.textAlignment = .center
        label.alpha = 0
        label.text = "payment.authentication.successful".localized
        return label
    }()

    private lazy var purposeLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppStyle.textColor1
        label.font = AppStyle.regularFont(ofSize: 40)
        label.textAlignment = .center
        return label
    }()

    private lazy var recipientLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppStyle.textColor1
        label.font = AppStyle.regularFont(ofSize: 40)
        label.textAlignment = .center
        return label
    }()

    var contentBottomConstraint: NSLayoutConstraint?

    init(delegate: PaymentConfirmationControllerDelegate, datasource: PaymentConfirmationControllerDataSource) {
        self.datasource = datasource
        self.delegate = delegate

        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .custom
        transitioningDelegate = self

        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    func setupViews() {
        view.addSubview(backdropView)
        view.addSubview(contentView)

        [pacePayLogo, cancelButton, logoSeparator, recipientPurpose, paymentMethodKind,
         paymentAccount, paymentMethodSeparator, price, amountLabelDescription, authenticateButton,
         successfulLoadingIndicator, successfulLabel].forEach { contentView.addSubview($0) }

        backdropView.fillSuperview()

        contentView.anchor(leading: view.leadingAnchor, trailing: view.trailingAnchor, size: .init(width: 0, height: contentHeight))

        contentBottomConstraint = NSLayoutConstraint(item: contentView,
                                                     attribute: .bottom,
                                                     relatedBy: .equal,
                                                     toItem: view,
                                                     attribute: .bottom,
                                                     multiplier: 1,
                                                     constant: contentHeight)
        contentBottomConstraint?.isActive = true

        setupHeader()
        setupPaymentInformation()
        setupAuthorizationPossibilities()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let datasource = datasource else {
            fatalError("No datasource provided")
        }

        view.backgroundColor = .clear

        contentView.layer.addSublayer(gradientLayer)
        gradientLayer.frame = contentView.bounds

        let currencyFormatter = NumberFormatter()

        currencyFormatter.currencyCode = datasource.paymentConfirmationController(dataFor: self).currency
        let amount: Float = datasource.paymentConfirmationController(dataFor: self).price
        let purpose = datasource.paymentConfirmationController(dataFor: self).purpose
        let recipient = datasource.paymentConfirmationController(dataFor: self).recipient
        let account = datasource.paymentConfirmationController(dataFor: self).account
        let methodKind = datasource.paymentConfirmationController(dataFor: self).paymentMethodKind

        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale(identifier: "de_DE")

        price.text = currencyFormatter.string(from: NSNumber(value: amount))

        paymentAccount.text = account

        recipientPurpose.text = "\(recipient) - \(purpose)"

        paymentMethodKind.text = String.localizedPaymentMethodKind(for: methodKind)
    }

    override func viewDidLayoutSubviews() {
        contentView.roundCorner(corners: [.topLeft, .topRight], radius: 10)
        gradientLayer.frame = contentView.bounds
    }

    private func setupHeader() {
        pacePayLogo.anchor(top: contentView.topAnchor,
                           leading: contentView.leadingAnchor,
                           padding: .init(top: edgePadding, left: edgePadding, bottom: 0, right: 0),
                           size: .init(width: 0, height: 30))

        cancelButton.anchor(trailing: contentView.trailingAnchor, centerY: pacePayLogo.centerYAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: edgePadding))

        logoSeparator.anchor(top: pacePayLogo.bottomAnchor,
                             leading: contentView.leadingAnchor,
                             trailing: contentView.trailingAnchor,
                             padding: .init(top: edgePadding, left: edgePadding, bottom: 0, right: edgePadding),
                             size: .init(width: 0, height: 1))
    }

    private func setupPaymentInformation() {
        recipientPurpose.anchor(top: logoSeparator.bottomAnchor,
                                  leading: contentView.leadingAnchor,
                                  trailing: contentView.trailingAnchor,
                                  padding: .init(top: edgePadding, left: 0, bottom: 0, right: 0))

        paymentAccount.anchor(top: recipientPurpose.bottomAnchor,
                                 leading: contentView.leadingAnchor,
                                 trailing: contentView.trailingAnchor,
                                 padding: .init(top: 16, left: 0, bottom: 0, right: 0))

        paymentMethodKind.anchor(top: paymentAccount.bottomAnchor,
                                        leading: contentView.leadingAnchor,
                                        trailing: contentView.trailingAnchor,
                                        padding: .init(top: 3, left: 0, bottom: 0, right: 0))

        paymentMethodSeparator.anchor(top: paymentMethodKind.bottomAnchor,
                                      leading: logoSeparator.leadingAnchor,
                                      trailing: logoSeparator.trailingAnchor,
                                      padding: .init(top: 30, left: 0, bottom: 0, right: 0),
                                      size: .init(width: 0, height: logoSeparator.bounds.height))

        price.anchor(top: paymentMethodSeparator.bottomAnchor,
                           leading: contentView.leadingAnchor,
                           trailing: contentView.trailingAnchor,
                           padding: .init(top: 25, left: 0, bottom: 0, right: 0))

        amountLabelDescription.anchor(top: price.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor)
    }

    private func setupAuthorizationPossibilities() {
        authenticateButton.anchor(top: amountLabelDescription.bottomAnchor,
                                  leading: contentView.leadingAnchor,
                                  trailing: contentView.trailingAnchor,
                                  padding: .init(top: 65, left: edgePadding, bottom: 0, right: edgePadding),
                                  size: .init(width: 0, height: 53))
        authenticateButton.bottomAnchor.constraint(lessThanOrEqualTo: contentView.safeAreaLayoutGuide.bottomAnchor).isActive = true

        successfulLoadingIndicator.anchor(top: amountLabelDescription.bottomAnchor,
                                          centerX: contentView.centerXAnchor,
                                          padding: .init(top: 35, left: 0, bottom: 0, right: 0),
                                          size: .init(width: 45, height: 45))

        successfulLabel.anchor(top: successfulLoadingIndicator.bottomAnchor,
                               leading: contentView.leadingAnchor,
                               trailing: contentView.trailingAnchor,
                               padding: .init(top: 15, left: edgePadding, bottom: 0, right: edgePadding))
        successfulLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }

    @objc
    func authenticate() {
        let laContext = LAContext()
        let reasonText = "payment.authentication.confirmation".localized

        var authError: NSError?
        if laContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &authError) {
            laContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reasonText) { success, error in
                if success {
                    self.paymentSucceeded()
                } else {
                    self.finish(with: .canceled)
                    AppKitLogger.e(error?.localizedDescription ?? "Failed to authenticate")
                }
            }
        } else {
            paymentSucceeded()
        }
    }

    private func paymentSucceeded() {
        DispatchQueue.main.async {
            self.successfulLoadingIndicator.startAnimating()

            UIView.animate(withDuration: 0.3,
                           animations: {
                self.authenticateButton.alpha = 0
                self.successfulLabel.alpha = 1
                self.successfulLoadingIndicator.alpha = 1
            }, completion: { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { [weak self] in
                    self?.finish(with: .success)
                }
            })
        }
    }

    func finish(with result: PaymentConfirmationResult) {
        DispatchQueue.main.async {
            self.successfulLoadingIndicator.stopAnimating()
            self.delegate?.paymentConfirmationController(didFinishWithResult: result)
        }
    }

    @objc
    func dismiss(_ sender: Any) {
        finish(with: .canceled)
    }
}

extension PaymentConfirmationViewController: UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .to) else { return }

        let containerView = transitionContext.containerView

        isPresenting.toggle()

        if isPresenting {
            containerView.addSubview(toVC.view)

            backdropView.alpha = 0
            self.view.layoutIfNeeded()

            UIView.animate(withDuration: transitionDuration(using: transitionContext),
                           delay: 0,
                           options: [.curveEaseOut],
                           animations: {
                self.contentBottomConstraint?.constant = 0
                self.backdropView.alpha = 0.8
                self.view.layoutIfNeeded()
            }, completion: { _ in
                transitionContext.completeTransition(true)
            })
        } else {
            UIView.animate(withDuration: transitionDuration(using: transitionContext),
                           delay: 0,
                           options: [.curveEaseOut],
                           animations: {
                self.contentBottomConstraint?.constant = self.contentHeight
                self.backdropView.alpha = 0
                self.view.layoutIfNeeded()
            }, completion: { _ in
                transitionContext.completeTransition(true)
            })
        }
    }
}
