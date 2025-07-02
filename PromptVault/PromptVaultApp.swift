//
//  PromptVaultApp.swift
//  PromptVault
//
//  Created by Kazuma Sakaguchi on 2025/07/01.
//

import SwiftUI

@main
struct PromptVaultApp: App {
    var body: some Scene {
        MenuBarExtra("PromptVault", systemImage: "doc.text.below.ecg") {
            MenuView()
        }
        .menuBarExtraStyle(.window)
    }
}
