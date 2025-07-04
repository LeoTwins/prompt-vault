//
//  HotkeyViewModel.swift
//  PromptVault
//
//  Created by Kazuma Sakaguchi on 2025/07/04.
//

import Foundation
import CoreData

@MainActor
@Observable
final class HotkeyViewModel {
    
    // MARK: - Properties
    
    private let databaseManager = DatabaseManager.shared
    var hotkeys: [HotkeyEntity] = []
    var isLoading = false
    var error: String?
    
    // MARK: - Initialization
    
    init() {
        loadHotkeys()
    }
    
    // MARK: - Data Management
    
    func loadHotkeys() {
        isLoading = true
        error = nil
        
        let request: NSFetchRequest<HotkeyEntity> = HotkeyEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \HotkeyEntity.createdAt, ascending: true)]
        
        do {
            hotkeys = try databaseManager.context.fetch(request)
            isLoading = false
        } catch {
            self.error = "ホットキーの読み込みに失敗しました: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    func createHotkey(keyCode: Int16, modifiers: Int16) {
        let displayName = HotkeyFormatter.generateDisplayName(keyCode: keyCode, modifiers: modifiers)
        
        if let newHotkey = databaseManager.createHotkey(keyCode: keyCode, modifiers: modifiers, displayName: displayName) {
            hotkeys.append(newHotkey)
        } else {
            error = "このホットキーの組み合わせは既に存在します"
        }
    }
    
    func deleteHotkey(_ hotkey: HotkeyEntity) {
        databaseManager.deleteHotkey(hotkey)
        hotkeys.removeAll { $0.objectID == hotkey.objectID }
    }
    
    func toggleHotkey(_ hotkey: HotkeyEntity) {
        hotkey.isEnabled.toggle()
        databaseManager.saveContext()
    }
    
    // MARK: - View Model Methods
    
    /// Hotkeyエンティティから表示名を生成
    func displayName(for hotkey: HotkeyEntity) -> String {
        return HotkeyFormatter.generateDisplayName(keyCode: hotkey.keyCode, modifiers: hotkey.modifiers)
    }
    
    /// 新しいホットキーの組み合わせが有効かチェック
    func isValidKeyCodeAndModifiers(keyCode: Int16, modifiers: Int16) -> Bool {
        return !databaseManager.hotkeyExists(keyCode: keyCode, modifiers: modifiers)
    }
    
    /// エラーをクリア
    func clearError() {
        error = nil
    }
}