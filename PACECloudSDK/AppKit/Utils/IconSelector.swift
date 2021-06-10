//
//  IconSelector.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import UIKit

struct IconSelector {
    static func chooseSuitableDrawerIcon(in icons: [AppIcon], requestedSize: (width: Int, height: Int)) -> AppIcon? {
        let pngIcons: [AppIcon] = icons.filter { $0.type?.contains("png") ?? false }
        let prefIcons = pngIcons.isEmpty ? icons : pngIcons

        let suitableIcon: AppIcon? = prefIcons.reduce(prefIcons.first) { currentIcon, nextIcon in
            let currentIconSizes = sizes(for: currentIcon)
            let nextIconSizes = sizes(for: nextIcon)

            guard let currentIconClosestSize = closestSize(in: currentIconSizes, to: requestedSize) else { return nil }
            guard let nextIconClosestSize = closestSize(in: nextIconSizes, to: requestedSize) else { return currentIcon }

            return currentIconClosestSize < nextIconClosestSize ? currentIcon : nextIcon
        }

        return suitableIcon
    }

    private static func sizes(for icon: AppIcon?) -> [(Int, Int)] {
        let sizesNoWhitespace = icon?.sizes?.components(separatedBy: " ") ?? []
        let sizes: [(Int, Int)] = sizesNoWhitespace.compactMap {
            let components = $0.components(separatedBy: "x")

            guard let widthString = components.first,
                  let heightString = components.last,
                  let width = Int(widthString),
                  let height = Int(heightString)
            else { return nil }

            return (width, height)
        }
        return sizes
    }

    private static func closestSize(in sizes: [(width: Int, height: Int)],
                                    to referenceSize: (width: Int, height: Int)) -> Int? {
        sizes.map {
            abs($0.width - referenceSize.width) + abs($0.height - referenceSize.height)
        }.min()
    }
}
