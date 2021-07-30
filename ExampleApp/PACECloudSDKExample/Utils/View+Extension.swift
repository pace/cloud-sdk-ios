//
//  View+Extension.swift
//  PACECloudSDKExample
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import SwiftUI

extension View {
    func alert(isPresented: Binding<Bool>, _ alert: TextFieldAlert) -> some View {
        TextFieldAlertWrapper(isPresented: isPresented, alert: alert, content: self)
    }
}
