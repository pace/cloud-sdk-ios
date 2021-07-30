//
//  DashboardButton.swift
//  PACECloudSDKExample
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import SwiftUI

struct DashboardButton: View {
    enum DashboadButtonType {
        case payment
        case transactions
        case account

        var title: String {
            switch self {
            case .payment:
                return "Manage Payment Methods"

            case .transactions:
                return "List Transactions"

            case .account:
                return "Manage PACE ID Account"
            }
        }

        var appView: AppView {
            switch self {
            case .payment:
                return AppView(presetUrl: .payment)

            case .transactions:
                return AppView(presetUrl: .transactions)

            case .account:
                return AppView(presetUrl: .paceID)
            }
        }
    }

    private let type: DashboadButtonType
    @State private var isAppVisible: Bool = false

    init(type: DashboadButtonType) {
        self.type = type
    }

    var body: some View {
        Button(action: {
            isAppVisible = true
        }, label: {
            ZStack {
                Text(type.title)
                    .frame(maxWidth: .infinity, minHeight: 75, alignment: .leading)
                    .padding([.leading, .trailing], .defaultPadding / 2)
                    .background(Color.white)
                    .foregroundColor(.black)
                    .font(.system(size: 18).weight(.regular))
                HStack {
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.body)
                        .padding(.trailing, .defaultPadding / 2)
                        .foregroundColor(.black)
                }
            }
        })
        .cornerRadius(8)
        .shadow(radius: 8)
        .padding([.leading, .trailing], .defaultPadding / 2)
        .sheet(isPresented: $isAppVisible) {
            type.appView
        }
    }
}
