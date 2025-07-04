//
//  HotkeyViewModel.swift
//  PromptVault
//
//  Created by Kazuma Sakaguchi on 2025/07/04.
//

import Foundation

@MainActor
@Observable
final class HotkeyViewModel {
    
    // MARK: - View Model Methods
    
    /// Hotkeyエンティティから表示名を生成
    func displayName(for hotkey: Hotkey) -> String {
        return HotkeyFormatter.generateDisplayName(keyCode: hotkey.keyCode, modifiers: hotkey.modifiers)
    }
}