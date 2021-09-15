//
//  MainTabView.swift
//  PACECloudSDKExample
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabsView()
    }
}

private struct TabsView: View {
    var body: some View {
        TabView {
            ListView(viewModel: ListViewModelImplementation())
                .tabItem {
                    Label("List", systemImage: "list.bullet")
                }
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "person.fill")
                }
            DrawerView(viewModel: DrawerViewModelImplementation())
                .tabItem {
                    Label("Drawer", systemImage: "hand.draw.fill")
                }
            SettingsView(viewModel: SettingsViewModelImplementation())
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}
