//
//  RectangularButton.swift
//  PACECloudSDKExample
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import SwiftUI

struct RectangularButton: View {
    private let title: String
    private let height: CGFloat
    private let action: () -> Void

    init(title: String, height: CGFloat = 44, action: @escaping () -> Void) {
        self.title = title
        self.height = height
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(maxWidth: .infinity, minHeight: height)
                .background(Color.brand)
                .foregroundColor(.black)
                .font(.system(size: 18).weight(.regular))
        }
        .cornerRadius(6)
        .shadow(radius: 6)
    }
}
