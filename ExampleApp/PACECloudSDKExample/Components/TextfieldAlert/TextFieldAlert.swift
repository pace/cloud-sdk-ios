//
//  TextFieldAlert.swift
//  PACECloudSDKExample
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import SwiftUI

struct TextFieldAlert {
    var title: String
    var message: String?
    var textFields: [AlertTextField] = [.init()]
    var accept: String = "OK"
    var cancel: String? = "Cancel"
    var action: ([String?]) -> Void
    var secondaryActionTitle: String?
    var secondaryAction: (() -> Void)?

    struct AlertTextField {
        var placeholder: String = ""
        var keyboardType: UIKeyboardType = .default
    }
}
