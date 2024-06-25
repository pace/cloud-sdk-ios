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
            guard case let .success(data) = result, let image = UIImage(data: data) else {
                // TODO: or set default image here
                return
            }

            DispatchQueue.main.async {
                self?.image = image
            }
        }
    }
}
