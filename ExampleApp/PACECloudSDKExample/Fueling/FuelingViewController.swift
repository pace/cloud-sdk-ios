//
//  FuelingViewController.swift
//  PACECloudSDKExample
//
//  Created by Patrick Niepel on 05.11.20.
//

import PACECloudSDK
import UIKit

class FuelingViewController: UIViewController {
    enum ButtonType: Int {
        case authorize
        case reset
        case drawer
        case fueling
        case payment
        case transactions
        case poiInRange
        case isPINSet
        case isPasswordSet
        case isPINOrPasswordSet
        case setPINWithOTP
        case setPINWithPassword
        case setPINWithBiometry
        case isBiometrySet
        case enableBiometryAfterLogin
        case enableBiometryWithOTP
        case enableBiometryWithPIN
        case enableBiometryWithPassword
        case disableBiometry
        case sendMailOTP

        var title: String {
            switch self {
            case .authorize:
                return "Authorize"

            case .reset:
                return "Reset Session"

            case .drawer:
                return "Request App Drawer"

            case .fueling:
                return "Request Fueling App"

            case .payment:
                return "Request Payment App"

            case .transactions:
                return "Request Transactions"

            case .poiInRange:
                return "Is POI in range?"

            case .isPINSet:
                return "Is PIN set?"

            case .isPasswordSet:
                return "Is Password set?"

            case .isPINOrPasswordSet:
                return "Is PIN or password set?"

            case .setPINWithOTP:
                return "Set PIN with otp"

            case .setPINWithPassword:
                return "Set PIN with password"

            case .setPINWithBiometry:
                return "Set PIN with biometry"

            case .isBiometrySet:
                return "Is biometry set?"

            case .enableBiometryAfterLogin:
                return "Enable biometry after login"

            case .enableBiometryWithOTP:
                return "Enable biometry with otp"

            case .enableBiometryWithPIN:
                return "Enable biometry with pin"

            case .enableBiometryWithPassword:
                return "Enable biometry with password"

            case .disableBiometry:
                return "Disable biometry"

            case .sendMailOTP:
                return "Send Mail OTP"
            }
        }
    }

    private lazy var idStackView = createStackView()
    private lazy var appStackView = createStackView()

    private lazy var appDrawerContainer = AppKit.AppDrawerContainer()

    private var idButtons: [PaceButton] = []
    private var appButtons: [PaceButton] = []

    private lazy var scrollView: UIScrollView = .init()
    private lazy var contentView: UIView = .init()

    override func viewDidLoad() {
        super.viewDidLoad()

        createButtons()
        setupLayout()

        setupSDK()
    }

    private func createButtons() {
        let buttonCreation: (ButtonType) -> PaceButton = { type in
            let button = PaceButton(with: type.title)
            button.tag = type.rawValue
            button.addTarget(self, action: #selector(self.handleButtonTapped), for: .touchUpInside)
            return button
        }

        idButtons = [ButtonType.authorize, .reset].map { buttonCreation($0) }
        appButtons = [ButtonType.drawer,
                      .fueling, .payment,
                      .transactions,
                      .poiInRange,
                      .isPINSet,
                      .isPasswordSet,
                      .isPINOrPasswordSet,
                      .setPINWithOTP,
                      .setPINWithPassword,
                      .setPINWithBiometry,
                      .isBiometrySet,
                      .enableBiometryAfterLogin,
                      .enableBiometryWithOTP,
                      .enableBiometryWithPIN,
                      .enableBiometryWithPassword,
                      .disableBiometry,
                      .sendMailOTP].map { buttonCreation($0) }
    }

    private func setupLayout() {
        view.backgroundColor = .white
        navigationItem.title = Strings.titleFuelingUnauthorized.rawValue

        [idStackView, scrollView, appDrawerContainer].forEach(view.addSubview)
        scrollView.addSubview(contentView)
        contentView.addSubview(appStackView)

        idStackView.snp.makeConstraints {
            $0.width.equalToSuperview().multipliedBy(0.75)
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(16)
        }

        scrollView.snp.makeConstraints {
            $0.top.equalTo(idStackView.snp.bottom).offset(16)
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview().inset(16)
        }

        contentView.snp.makeConstraints {
            $0.left.top.right.width.equalToSuperview()
            $0.bottom.equalToSuperview().inset(16)
        }

        appStackView.snp.makeConstraints {
            $0.width.equalToSuperview().multipliedBy(0.75)
            $0.centerX.equalToSuperview()
            $0.top.bottom.equalToSuperview()
        }

        idButtons.forEach {
            idStackView.addArrangedSubview($0)

            $0.snp.makeConstraints {
                $0.left.right.equalToSuperview()
                $0.height.equalTo(50)
            }
        }

        appButtons.forEach {
            appStackView.addArrangedSubview($0)

            $0.snp.makeConstraints {
                $0.left.right.equalToSuperview()
                $0.height.equalTo(50)
            }
        }

        appDrawerContainer.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(150)
            $0.right.equalToSuperview()
        }
    }

    private func setupSDK() {
        guard let navCtrl = navigationController else { return }
        IDControl.shared.setup(for: navCtrl)
        IDControl.shared.delegate = self

        AppControl.shared.delegate = self

        appDrawerContainer.setupContainerView()
    }

    // swiftlint:disable cyclomatic_complexity function_body_length
    @objc
    private func handleButtonTapped(sender: UIButton) {
        switch sender.tag {
        case ButtonType.authorize.rawValue:
            IDControl.shared.authorize()

        case ButtonType.reset.rawValue:
            IDControl.shared.reset()
            navigationItem.title = Strings.titleFuelingUnauthorized.rawValue

        case ButtonType.drawer.rawValue:
            AppControl.shared.requestLocalApps()

        case ButtonType.fueling.rawValue:
            let vc = AppControl.shared.appViewController(appUrl: Constants.URLs.fuelingUrl)
            present(vc, animated: true)

        case ButtonType.payment.rawValue:
            let vc = AppControl.shared.appViewController(appUrl: Constants.URLs.paymentUrl)
            present(vc, animated: true)

        case ButtonType.transactions.rawValue:
            let vc = AppControl.shared.appViewController(appUrl: "\(Constants.URLs.paymentUrl)/transactions")
            present(vc, animated: true)

        case ButtonType.poiInRange.rawValue:
            handleIsPoiInRangeAlert()

        case ButtonType.isPINSet.rawValue:
            IDControl.shared.isPINSet()

        case ButtonType.isPasswordSet.rawValue:
            IDControl.shared.isPasswordSet()

        case ButtonType.isPINOrPasswordSet.rawValue:
            IDControl.shared.isPINOrPasswordSet()

        case ButtonType.setPINWithOTP.rawValue:
            handleSetPINWithOTPAlert()

        case ButtonType.setPINWithPassword.rawValue:
            handleSetPINWithPasswordAlert()

        case ButtonType.setPINWithBiometry.rawValue:
            handleSetPINWithBiometryAlert()

        case ButtonType.isBiometrySet.rawValue:
            IDControl.shared.isBiometrySet()

        case ButtonType.enableBiometryAfterLogin.rawValue:
            IDControl.shared.enableBiometry()

        case ButtonType.enableBiometryWithOTP.rawValue:
            handleEnableBiometryWithOTP()

        case ButtonType.enableBiometryWithPIN.rawValue:
            handleEnableBiometryWithPIN()

        case ButtonType.enableBiometryWithPassword.rawValue:
            handleEnableBiometryWithPassword()

        case ButtonType.disableBiometry.rawValue:
            IDControl.shared.disableBiometry()

        case ButtonType.sendMailOTP.rawValue:
            IDControl.shared.sendMailOTP()

        default:
            break
        }
    }

    private func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        return stackView
    }

    private func handleIsPoiInRangeAlert() {
        let alert = UIAlertController(title: "Enter poi id", message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            let id = alert.textFields?.first?.text ?? ""
            AppControl.shared.isPoiInRange(with: id)
        }
        alert.addAction(okAction)
        present(alert, animated: true)
    }

    private func handleSetPINWithOTPAlert() {
        let alert = UIAlertController(title: "Enter PIN and OTP", message: nil, preferredStyle: .alert)
        alert.addTextField { textfield in
            textfield.placeholder = "PIN"
        }

        alert.addTextField { textfield in
            textfield.placeholder = "OTP"
        }

        let pinAction = UIAlertAction(title: "Set PIN", style: .default) { _ in
            let pin = alert.textFields?[0].text ?? ""
            let otp = alert.textFields?[1].text ?? ""

            guard !pin.isEmpty, !otp.isEmpty else { return }
            IDControl.shared.setPIN(pin: pin, otp: otp)
        }
        alert.addAction(pinAction)
        present(alert, animated: true)
    }

    private func handleSetPINWithPasswordAlert() {
        let alert = UIAlertController(title: "Enter PIN and Password", message: nil, preferredStyle: .alert)
        alert.addTextField { textfield in
            textfield.placeholder = "New PIN"
        }

        alert.addTextField { textfield in
            textfield.placeholder = "Your Password"
        }

        let pinAction = UIAlertAction(title: "Set PIN", style: .default) { _ in
            let pin = alert.textFields?[0].text ?? ""
            let password = alert.textFields?[1].text ?? ""

            guard !pin.isEmpty, !password.isEmpty else { return }
            IDControl.shared.setPIN(pin: pin, password: password)
        }
        alert.addAction(pinAction)
        present(alert, animated: true)
    }

    private func handleSetPINWithBiometryAlert() {
        let alert = UIAlertController(title: "Enter PIN", message: nil, preferredStyle: .alert)
        alert.addTextField { textfield in
            textfield.placeholder = "New PIN"
        }

        let pinAction = UIAlertAction(title: "Set PIN", style: .default) { _ in
            let pin = alert.textFields?[0].text ?? ""

            guard !pin.isEmpty else { return }
            IDControl.shared.setPINWithBiometry(pin: pin)
        }
        alert.addAction(pinAction)
        present(alert, animated: true)
    }

    private func handleEnableBiometryWithOTP() {
        let alert = UIAlertController(title: "Enter OTP", message: nil, preferredStyle: .alert)
        alert.addTextField { textfield in
            textfield.placeholder = "OTP"
        }

        let pinAction = UIAlertAction(title: "Enable Biometry", style: .default) { _ in
            let otp = alert.textFields?[0].text ?? ""

            guard !otp.isEmpty else { return }
            IDControl.shared.enableBiometry(otp: otp)
        }
        alert.addAction(pinAction)
        present(alert, animated: true)
    }

    private func handleEnableBiometryWithPIN() {
        let alert = UIAlertController(title: "Enter PIN", message: nil, preferredStyle: .alert)
        alert.addTextField { textfield in
            textfield.placeholder = "Your PIN"
        }

        let pinAction = UIAlertAction(title: "Enable Biometry", style: .default) { _ in
            let pin = alert.textFields?[0].text ?? ""

            guard !pin.isEmpty else { return }
            IDControl.shared.enableBiometry(pin: pin)
        }
        alert.addAction(pinAction)
        present(alert, animated: true)
    }

    private func handleEnableBiometryWithPassword() {
        let alert = UIAlertController(title: "Enter Password", message: nil, preferredStyle: .alert)
        alert.addTextField { textfield in
            textfield.placeholder = "Your Password"
        }

        let pinAction = UIAlertAction(title: "Enable Biometry", style: .default) { _ in
            let password = alert.textFields?[0].text ?? ""

            guard !password.isEmpty else { return }
            IDControl.shared.enableBiometry(password: password)
        }
        alert.addAction(pinAction)
        present(alert, animated: true)
    }
}

extension FuelingViewController: AppControlDelegate {
    func didReceiveDrawers(_ drawers: [AppKit.AppDrawer]) {
        appDrawerContainer.inject(drawers, theme: .light)
    }
}

extension FuelingViewController: IDControlDelegate {
    func didReceiveUserInfo(_ userInfo: IDKit.UserInfo) {
        navigationItem.title = "\(Strings.titleFuelingAuthorized.rawValue) \(userInfo.email ?? "No email")"
    }
}
