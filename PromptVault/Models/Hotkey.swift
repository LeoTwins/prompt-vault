//
//  Hotkey.swift
//  PromptVault
//
//  Created by Kazuma Sakaguchi on 2025/07/04.
//

import Foundation

struct Hotkey: Identifiable, Codable, Equatable {
    let id: String
    let keyCode: Int16
    let modifiers: Int16
    let isEnabled: Bool
    let displayName: String
    let createdAt: Date
    
    init(
        id: String = UUID().uuidString,
        keyCode: Int16,
        modifiers: Int16,
        isEnabled: Bool = true,
        displayName: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.keyCode = keyCode
        self.modifiers = modifiers
        self.isEnabled = isEnabled
        self.displayName = displayName
        self.createdAt = createdAt
    }
}

extension Hotkey {
    /// macOS NSEvent 修飾キーのビットフラグ定数
    /// 参考: NSEvent.ModifierFlags
    struct ModifierKeys {
        static let command: Int16 = 0x100   // 256  (⌘) NSEvent.ModifierFlags.command
        static let shift: Int16 = 0x200     // 512  (⇧) NSEvent.ModifierFlags.shift
        static let option: Int16 = 0x400    // 1024 (⌥) NSEvent.ModifierFlags.option
        static let control: Int16 = 0x1000  // 4096 (⌃) NSEvent.ModifierFlags.control
    }
}