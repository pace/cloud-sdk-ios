//
//  XCTestCase+Extension.swift
//  PACECloudSDKTests
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import XCTest

extension XCTestCase {
    func addCommandLineArguments(_ args: [CommandLineArgument]) {
        CommandLine.arguments += args.map { $0.rawValue }
    }
}
