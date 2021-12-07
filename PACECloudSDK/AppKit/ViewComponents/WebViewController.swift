//
//  WebViewController.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import UIKit

public class WebViewController: UIViewController {
    private let webView: WebView

    init(appUrl: String?,
         hasNavigationBar: Bool = false,
         isModalInPresentation: Bool = true) {

        webView = WebView(with: appUrl)
        super.init(nibName: nil, bundle: nil)

        navigationController?.setNavigationBarHidden(!hasNavigationBar, animated: false)

        if #available(iOS 13.0, *) {
            self.isModalInPresentation = isModalInPresentation
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    private func setupView() {
        view.addSubview(webView)
        view.backgroundColor = AppStyle.backgroundColor1
        navigationController?.navigationBar.tintColor = AppStyle.whiteColor
        webView.fillSuperview()
    }
}
