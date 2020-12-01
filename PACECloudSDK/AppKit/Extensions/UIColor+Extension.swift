//
//  UIColor+Extension.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import UIKit

extension UIColor {
    convenience init?(hex: String) {
        let r, g, b: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                    b = CGFloat((hexNumber & 0x0000ff) >> 0) / 255

                    self.init(red: r, green: g, blue: b, alpha: 1)
                    return
                }
            }
        }

        return nil
    }

    var hexString: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        getRed(&r, green: &g, blue: &b, alpha: &a)

        let rgb: Int = (Int)(r * 255) << 16 | (Int)(g * 255) << 8 | (Int)(b * 255) << 0

        return String(format: "#%06x", rgb)
    }

    func darken(_ pct: CGFloat) -> UIColor {
        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        var alpha: CGFloat = 0.0

        self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        brightness = brightness * (1 - pct)
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }

    /**
     Calculates if black or white should be returned based on the contrast color
     */
    static func contrastColor(hex: String) -> UIColor {
        // Black RGB
        let blackHex = "#000000"

        guard let contrastRGB = rgb(hex: hex),
            let blackRGB = rgb(hex: blackHex) else {
                return .white
        }

        // Calc contrast ratio
        let luminosityContrastColor = 0.2126 * pow(contrastRGB.r, 2.2) +
            0.7152 * pow(contrastRGB.g, 2.2) +
            0.0722 * pow(contrastRGB.b, 2.2)

        let luminosityBlack = 0.2126 * pow(blackRGB.r, 2.2) +
            0.7152 * pow(blackRGB.g, 2.2) +
            0.0722 * pow(blackRGB.b, 2.2)

        var contrastRatio: CGFloat = 0
        if luminosityContrastColor > luminosityBlack {
            contrastRatio = (luminosityContrastColor + 0.05) / (luminosityBlack + 0.05)
        } else {
            contrastRatio = (luminosityBlack + 0.05) / (luminosityContrastColor + 0.05)
        }

        // If contrast is more than 5, return black color
        if contrastRatio > 5 {
            return .black
        } else {
            // if not, return white color.
            return .white
        }
    }

    // swiftlint:disable large_tuple
    private static func rgb(hex: String) -> (r: CGFloat, g: CGFloat, b: CGFloat)? {
        let r, g, b: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                    b = CGFloat((hexNumber & 0x0000ff) >> 0) / 255

                    return (r: r, g: g, b: b)
                }
            }
        }
        return nil
    }
}
