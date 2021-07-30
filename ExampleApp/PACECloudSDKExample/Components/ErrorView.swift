//
//  ErrorView.swift
//  PACECloudSDKExample
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import SwiftUI

struct ErrorView: View {
    var body: some View {
        Text("Oops, looks like something went wrong...")
            .font(.system(size: 18).weight(.semibold))
            .padding([.leading, .trailing], .defaultPadding)
    }
}
