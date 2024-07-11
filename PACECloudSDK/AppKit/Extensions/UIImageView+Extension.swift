//
//  UIImageView+Extension.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import UIKit

extension UIImageView {
    func load(urlString: String) {
        URLDataRequest.requestData(with: urlString, headers: nil) { [weak self] result in
            guard case let .success(data) = result, let image = UIImage(data: data) else { return }
            AppKitLogger.d("Successfully loaded app drawer image")
            DispatchQueue.main.async {
                self?.image = image
            }
        }
    }
}
