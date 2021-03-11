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

        var title: String {
            switch self {
            case .authorize:
                return Strings.buttonAuthorize.rawValue

            case .reset:
                return Strings.buttonReset.rawValue

            case .drawer:
                return Strings.buttonDrawer.rawValue

            case .fueling:
                return Strings.buttonFueling.rawValue

            case .payment:
                return Strings.buttonPayment.rawValue

            case .transactions:
                return Strings.buttonTransactions.rawValue

            case .poiInRange:
                return Strings.poiInRange.rawValue
            }
        }
    }

    private lazy var idStackView = createStackView()
    private lazy var appStackView = createStackView()

    private lazy var appDrawerContainer = AppKit.AppDrawerContainer()

    private var idButtons: [PaceButton] = []
    private var appButtons: [PaceButton] = []

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
        appButtons = [ButtonType.drawer, .fueling, .payment, .transactions, .poiInRange].map { buttonCreation($0) }

        isAuthorized(false)
    }

    private func setupLayout() {
        view.backgroundColor = .white
        navigationItem.title = Strings.titleFuelingUnauthorized.rawValue

        [idStackView, appStackView, appDrawerContainer].forEach(view.addSubview)

        idStackView.snp.makeConstraints {
            $0.width.equalToSuperview().multipliedBy(0.75)
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(16)
        }

        appStackView.snp.makeConstraints {
            $0.width.equalToSuperview().multipliedBy(0.75)
            $0.centerX.centerY.equalToSuperview()
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
            let alert = UIAlertController(title: "Enter poi id", message: nil, preferredStyle: .alert)
            alert.addTextField(configurationHandler: nil)
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                let id = alert.textFields?.first?.text ?? ""
                AppControl.shared.isPoiInRange(with: id)
            }
            alert.addAction(okAction)
            present(alert, animated: true)

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
}

extension FuelingViewController: AppControlDelegate {
    func didReceiveDrawers(_ drawers: [AppKit.AppDrawer]) {
        appDrawerContainer.inject(drawers, theme: .light)
    }
}

extension FuelingViewController: IDControlDelegate {
    func isAuthorized(_ authorized: Bool) {
        appButtons.forEach {
            $0.isEnabled = authorized
            $0.alpha = authorized ? 1 : 0.5
        }
    }

    func didReceiveUserInfo(_ userInfo: IDKit.UserInfo) {
        navigationItem.title = "\(Strings.titleFuelingAuthorized.rawValue) \(userInfo.email ?? "No email")"
    }
}
