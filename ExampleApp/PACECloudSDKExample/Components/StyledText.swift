//
//  StyledText.swift
//  PACECloudSDKExample
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import SwiftUI

enum TextStyle {
    case primary
    case secondary
}

struct StyledText: View {
    private let content: String
    private let style: TextStyle

    init(_ content: String, style: TextStyle = .primary) {
        self.content = content
        self.style = style
    }

    var body: some View {
        Text(content)
            .font(.system(size: style == .primary ? 17 : 16))
            .fontWeight(style == .primary ? .regular : .light)
            .foregroundColor(style == .primary ? .black : .secondary)

    }
}
