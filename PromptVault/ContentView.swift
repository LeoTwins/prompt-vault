//
//  ContentView.swift
//  PromptVault
//
//  Created by Kazuma Sakaguchi on 2025/07/01.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var sideMenuViewModel = SideMenuViewModel()
    
    var body: some View {
        HStack(spacing: 0) {
            SideMenuView()
                .environmentObject(sideMenuViewModel)
            
            Divider()
            
            VStack {
                Spacer()
                
                Image(systemName: "doc.text")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("PromptVault Dashboard")
                    .font(.title)
                Text("プロンプト管理ダッシュボード")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea(.all, edges: .top)
        .frame(width: 800, height: 500)
        .onAppear {
            setupNotificationObserver()
        }
    }
    
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("ToggleSidebar"),
            object: nil,
            queue: .main
        ) { _ in
            sideMenuViewModel.toggleVisibility()
        }
    }
}

#Preview {
    ContentView()
}
