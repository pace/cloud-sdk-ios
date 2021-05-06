//
//  IconSelector.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import UIKit

struct IconSelector {
    static func chooseSuitableDrawerIcon(in icons: [AppIcon]) -> AppIcon? {
        let pngIcons: [AppIcon] = icons.filter { $0.type?.contains("png") ?? false }

        let prefIcons = pngIcons.isEmpty ? icons : pngIcons

        let suitableIcon: AppIcon? = prefIcons.compactMap({ icon in

            let sizesNoWhitespace = icon.sizes?.components(separatedBy: " ")

            let sizes = sizesNoWhitespace?.compactMap({
                Int($0.components(separatedBy: "x").first ?? "") // Get first part of size (32x32) as Integer
            }).sorted()

            guard sizes?.first(where: { CGFloat($0) >= AppStyle.drawerSize }) != nil else { return nil }
            return icon
        }).first

        return suitableIcon
    }
}
