//
//  DashboardView.swift
//  PACECloudSDKExample
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import SwiftUI

struct DashboardView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Spacer()
                        .frame(height: .defaultPadding / 2)
                    DashboardButton(type: .payment)
                    Spacer()
                        .frame(height: .defaultPadding / 2)
                    DashboardButton(type: .transactions)
                    Spacer()
                        .frame(height: .defaultPadding / 2)
                    DashboardButton(type: .account)
                    Spacer()
                        .frame(height: .defaultPadding / 2)
                    DashboardButton(type: .dashboard)
                    Spacer()
                }
            }
            .navigationTitle("Dashboard")
        }
    }
}
