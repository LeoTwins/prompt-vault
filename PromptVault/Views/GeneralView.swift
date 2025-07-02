//
//  GeneralView.swift
//  PromptVault
//
//  Created by Kazuma Sakaguchi on 2025/07/02.
//

import SwiftUI

/// General設定画面のView
/// 一般的なアプリケーション設定を管理する画面
struct GeneralView: View {
    @State private var launchOnStart: Bool = false
    @State private var automaticUpdates: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            PageHeaderView(title: "General")
            
            // Current version セクション
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("Current version")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("1.0.0")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 8)
                .padding(.horizontal, 15)
                
                Rectangle()
                    .fill(Color(NSColor.separatorColor))
                    .frame(height: 1)
                    .padding(.top, 8)
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    // Launch on start カード
                    CardView {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Launch on start")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.primary)
                                Text("Automatically launch PromptVault when you start your Mac")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: $launchOnStart)
                                .toggleStyle(SwitchToggleStyle())
                                .scaleEffect(1.2)
                                .labelsHidden()
                        }
                    }
                    
                    // Automatic updates カード
                    CardView {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Automatic updates")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.primary)
                                Text("Automatically download and install updates")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: $automaticUpdates)
                                .toggleStyle(SwitchToggleStyle())
                                .scaleEffect(1.2)
                                .labelsHidden()
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 15)
                .padding(.top, 20)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

#Preview {
    GeneralView()
}