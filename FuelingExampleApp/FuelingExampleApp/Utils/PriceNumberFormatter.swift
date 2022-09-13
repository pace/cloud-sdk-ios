//
//  PriceNumberFormatter.swift
//  FuelingExampleApp
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public class PriceNumberFormatter: NumberFormatter {

    private var _formatString: String = "d.dds" {
        didSet {
            configureFormatter(with: _formatString)
        }
    }

    public var formatString: String {
        get {
            return _formatString
        }

        set {
            _formatString = newValue.isEmpty ? "d.dds" : newValue
        }
    }

    private var usesSuperscript: Bool = true

    public override init() {
        super.init()
        self.locale = .current
        self.numberStyle = .decimal
        self.formatString = "d.dds"
        configureFormatter(with: _formatString)
    }

    public init(with format: String = "d.dds", locale: Locale = .current) {
        super.init()
        self.locale = locale
        self.numberStyle = .decimal
        self.formatString = format
        configureFormatter(with: _formatString)
    }

    required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    override public func string(from number: NSNumber) -> String? {
        guard var newString = super.string(from: number) else { return nil }
        guard usesSuperscript else { return newString }
        let endIndex = newString.endIndex
        let lastDigit = Range(uncheckedBounds: (lower: newString.index(endIndex, offsetBy: -1), upper: endIndex))
        newString.replaceSubrange(lastDigit, with: "^\(newString[lastDigit])")
        return newString
    }

    private func configureFormatter(with format: String) {
        let integerDigitsCount = getIntegerDigitsCount(in: format)
        let fractionDigitsCount = getFractionDigitsCount(in: format)

        minimumIntegerDigits = integerDigitsCount
        minimumFractionDigits = fractionDigitsCount
        maximumFractionDigits = fractionDigitsCount
    }

    private func getIntegerDigitsCount(in format: String) -> Int {
        guard let separator = format.range(of: ".") else { fatalError() }
        let integerDigitsRange = format.startIndex ..< separator.lowerBound
        return format[integerDigitsRange].count
    }

    private func getFractionDigitsCount(in format: String) -> Int {
        guard let separator = format.range(of: ".") else { fatalError() }
        let fractionDigitsRange = separator.upperBound ..< format.endIndex
        let fractionDigitsString = format[fractionDigitsRange]

        usesSuperscript = fractionDigitsString.contains("s")

        return fractionDigitsString.count
    }
}
