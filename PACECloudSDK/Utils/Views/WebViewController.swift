//
//  WebViewController.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import UIKit

protocol WebViewControllerDelegate: AnyObject {
    func dismiss(webViewController: WebViewController)
}

public class WebViewController: UIViewController {
    let webView: WebView

    weak var delegate: WebViewControllerDelegate?

    init(appUrl: String?, hasNavigationBar: Bool = false, isModalInPresentation: Bool = true, webView: WebView? = nil) {
        self.webView = webView ?? WebView(with: appUrl)

        super.init(nibName: nil, bundle: nil)

        self.webView.delegate = self

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

extension WebViewController: WebViewDelegate {
    func dismissWebView() {
        delegate?.dismiss(webViewController: self)
    }
}
