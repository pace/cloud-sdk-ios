//
//  UIImage+Extension.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import UIKit

extension UIImage {
    func tinted(with color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        color.setFill()

        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.setBlendMode(.normal)

        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)

        guard let cgImage = self.cgImage else { return UIImage() }
        context?.clip(to: rect, mask: cgImage)
        context?.fill(rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image ?? UIImage()
    }
}
