//
//  MainTabView.swift
//  FoodTrackerApp
//
//  Created by Template
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var viewModel = FoodTrackerViewModel()
    
    var body: some View {
        TabView {
            FoodTrackerView(viewModel: viewModel)
                .tabItem {
                    Label("Today", systemImage: "calendar")
                }
            
            HistoryView(viewModel: viewModel)
                .tabItem {
                    Label("History", systemImage: "chart.bar")
                }
            
            ProfileView(viewModel: viewModel)
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
    }
}

#Preview {
    MainTabView()
}

