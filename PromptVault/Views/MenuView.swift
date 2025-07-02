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
                styleMask: [.titled, .closable, .fullSizeContentView],
                backing: .buffered,
                defer: false
            )
            dashboardWindow.title = ""
            dashboardWindow.titlebarAppearsTransparent = true
            dashboardWindow.titleVisibility = .hidden
            
            // ツールバーを作成してサイドメニューボタンを追加
            let toolbar = NSToolbar(identifier: "MainToolbar")
            toolbar.displayMode = .iconOnly
            toolbar.showsBaselineSeparator = false
            
            // サイドメニュー表示/非表示ボタンのアイテム識別子
            let sidebarItemIdentifier = NSToolbarItem.Identifier("SidebarToggle")
            
            // ツールバーデリゲートを設定
            let toolbarDelegate = ToolbarDelegate(sidebarItemIdentifier: sidebarItemIdentifier)
            toolbar.delegate = toolbarDelegate
            
            // ツールバーをウィンドウに設定
            dashboardWindow.toolbar = toolbar
            
            dashboardWindow.contentView = NSHostingView(rootView: ContentView())
            dashboardWindow.center()
            dashboardWindow.makeKeyAndOrderFront(nil)
        }
    }
}

// NSToolbarのデリゲートクラス
class ToolbarDelegate: NSObject, NSToolbarDelegate {
    let sidebarItemIdentifier: NSToolbarItem.Identifier
    
    init(sidebarItemIdentifier: NSToolbarItem.Identifier) {
        self.sidebarItemIdentifier = sidebarItemIdentifier
        super.init()
    }
    
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        if itemIdentifier == sidebarItemIdentifier {
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            item.image = NSImage(systemSymbolName: "sidebar.left", accessibilityDescription: "Toggle Sidebar")
            item.label = "サイドバー"
            item.paletteLabel = "サイドバー"
            item.toolTip = "サイドメニューの表示/非表示"
            item.target = self
            item.action = #selector(toggleSidebar(_:))
            return item
        }
        return nil
    }
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [sidebarItemIdentifier]
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [sidebarItemIdentifier]
    }
    
    @objc func toggleSidebar(_ sender: Any) {
        // ContentViewのEnvironmentObjectを通じてサイドバーの表示/非表示を切り替える
        NotificationCenter.default.post(name: NSNotification.Name("ToggleSidebar"), object: nil)
    }
}

#Preview {
    MenuView()
}
