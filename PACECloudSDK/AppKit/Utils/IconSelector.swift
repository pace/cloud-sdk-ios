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

        let requestedSize = Int(AppStyle.drawerSize * AppStyle.drawerSize)

        let suitableIcon: AppIcon? = prefIcons.reduce(prefIcons.first) { currentIcon, nextIcon in
            let currentIconSizes = sizes(for: currentIcon)
            let nextIconSizes = sizes(for: nextIcon)

            guard let currentIconClosestSize = closestSize(in: currentIconSizes, to: requestedSize) else { return nil }
            guard let nextIconClosestSize = closestSize(in: nextIconSizes, to: requestedSize) else { return currentIcon }

            return abs(currentIconClosestSize - requestedSize) < abs(nextIconClosestSize - requestedSize) ? currentIcon : nextIcon
        }

        return suitableIcon
    }

    private static func sizes(for icon: AppIcon?) -> [Int] {
        let sizesNoWhitespace = icon?.sizes?.components(separatedBy: " ") ?? []
        let sizes: [Int] = sizesNoWhitespace.compactMap {
            let components = $0.components(separatedBy: "x")

            guard let widthString = components.first,
                  let heightString = components.last,
                  let width = Int(widthString),
                  let height = Int(heightString)
            else { return nil }

            return width * height
        }.sorted()
        return sizes
    }

    private static func closestSize(in sizes: [Int], to referenceSize: Int) -> Int? {
        guard let firstSize = sizes.first else { return nil }
        return sizes.reduce(firstSize) { abs($0 - referenceSize) < abs($1 - referenceSize) ? $0 : $1 }
    }
}
