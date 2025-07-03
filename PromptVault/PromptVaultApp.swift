//
//  PromptVaultApp.swift
//  PromptVault
//
//  Created by Kazuma Sakaguchi on 2025/07/01.
//

import SwiftUI

@main
struct PromptVaultApp: App {
    
    init() {
        // アプリ起動時にCore Dataを初期化
        do {
            try DatabaseMigration.migrate()
        } catch {
            print("Database migration failed: \(error)")
        }
    }
    
    var body: some Scene {
        MenuBarExtra("PromptVault", systemImage: "doc.text.below.ecg") {
            MenuView()
        }
        .menuBarExtraStyle(.window)
    }
}
