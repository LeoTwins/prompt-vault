//
//  MenuView.swift
//  PromptVault
//
//  Created by Kazuma Sakaguchi on 2025/07/02.
//

import SwiftUI

struct MenuView: View {
    @State private var isShortcutEnabled = true
    
    // サンプルデータ（実際のデータは後で実装）
    private let samplePrompts = [
        ("コード生成", "⌘1"),
        ("バグ修正", "⌘2"),
        ("コードレビュー", "⌘3"),
        ("リファクタリング", "⌘4")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // ショートカット機能のon/offボタン
            HStack {
                Text("ショートカット機能")
                    .font(.subheadline)
                Spacer()
                Toggle("", isOn: $isShortcutEnabled)
                    .toggleStyle(SwitchToggleStyle())
            }
            
            Divider()
            
            // 登録済みプロンプトのタイトルとショートカットキー
            Text("登録済みプロンプト")
                .font(.subheadline)
                .fontWeight(.medium)
            
            ForEach(Array(samplePrompts.enumerated()), id: \.offset) { index, prompt in
                HStack {
                    Text(prompt.0)
                        .font(.subheadline)
                    Spacer()
                    Text(prompt.1)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 1)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(3)
                }
                .opacity(isShortcutEnabled ? 1.0 : 0.6)
            }
            
            Divider()
            
            // ダッシュボード表示ボタン
            Button(action: {
                openDashboard()
            }) {
                Text("ダッシュボード")
                    .font(.subheadline)
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .frame(width: 250)
    }
    
    private func openDashboard() {
        NSApplication.shared.activate(ignoringOtherApps: true)
        
        if let window = NSApplication.shared.windows.first(where: { $0.title == "Dashboard" }) {
            window.makeKeyAndOrderFront(nil)
        } else {
            let dashboardWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 600, height: 400),
                styleMask: [.titled, .closable, .resizable],
                backing: .buffered,
                defer: false
            )
            dashboardWindow.title = "Dashboard"
            dashboardWindow.contentView = NSHostingView(rootView: ContentView())
            dashboardWindow.center()
            dashboardWindow.makeKeyAndOrderFront(nil)
        }
    }
}

#Preview {
    MenuView()
}
