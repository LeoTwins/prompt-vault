//
//  DatabaseManager.swift
//  PromptVault
//
//  Created by Kazuma Sakaguchi on 2025/07/03.
//

import Foundation
@preconcurrency import CoreData

class DatabaseManager {
    static let shared = DatabaseManager()
    
    private init() {
        // デフォルトカテゴリの作成を非同期で実行してUIスレッドブロックを防止
        Task {
            await createDefaultCategoriesIfNeeded()
        }
    }
    
    // MARK: - Core Data Stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PromptVault")
        
        // 軽量マイグレーション設定
        let storeDescription = container.persistentStoreDescriptions.first
        storeDescription?.setOption(true as NSNumber, forKey: NSMigratePersistentStoresAutomaticallyOption)
        storeDescription?.setOption(true as NSNumber, forKey: NSInferMappingModelAutomaticallyOption)
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                // 開発中のデータベース削除とリセット
                print("❌ Core Data migration error: \(error)")
                print("🔄 Attempting to delete and recreate database...")
                
                if let storeURL = storeDescription.url {
                    do {
                        try FileManager.default.removeItem(at: storeURL)
                        print("✅ Old database deleted")
                        
                        // 再度ストアを作成
                        try container.persistentStoreCoordinator.addPersistentStore(
                            ofType: NSSQLiteStoreType,
                            configurationName: nil,
                            at: storeURL,
                            options: [
                                NSMigratePersistentStoresAutomaticallyOption: true,
                                NSInferMappingModelAutomaticallyOption: true
                            ]
                        )
                        print("✅ New database created")
                    } catch {
                        fatalError("Failed to delete and recreate database: \(error)")
                    }
                } else {
                    fatalError("Core Data error: \(error), \(error.userInfo)")
                }
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Core Data Saving
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
                print("✅ Context saved successfully")
            } catch {
                let nsError = error as NSError
                print("❌ Context save failed: \(nsError), \(nsError.userInfo)")
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        } else {
            print("⚠️ No changes to save in context")
        }
    }
    
    // MARK: - Default Categories
    
    private func createDefaultCategoriesIfNeeded() async {
        let request: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        
        do {
            let count = try context.count(for: request)
            if count == 0 {
                await MainActor.run {
                    createDefaultCategories()
                }
            }
        } catch {
            print("Error checking categories: \(error)")
        }
    }
    
    private func createDefaultCategories() {
        let defaultCategories = [
            ("コード生成", "#007AFF"),
            ("デバッグ", "#FF3B30"),
            ("説明", "#34C759"),
            ("レビュー", "#FF9500")
        ]
        
        for (name, color) in defaultCategories {
            let category = CategoryEntity(context: context)
            category.id = UUID()
            category.name = name
            category.color = color
            category.createdAt = Date()
        }
        
        saveContext()
        print("✅ Default categories created")
    }
    
    // MARK: - Hotkey Management
    
    func createHotkey(keyCode: Int16, modifiers: Int16, displayName: String) -> HotkeyEntity? {
        // Check for duplicate key combination
        if hotkeyExists(keyCode: keyCode, modifiers: modifiers) {
            print("❌ Hotkey combination already exists: \(displayName)")
            return nil
        }
        
        let hotkey = HotkeyEntity(context: context)
        hotkey.id = UUID()
        hotkey.keyCode = keyCode
        hotkey.modifiers = modifiers
        hotkey.displayName = displayName
        hotkey.isEnabled = true
        hotkey.createdAt = Date()
        
        saveContext()
        print("✅ Hotkey created: \(displayName)")
        return hotkey
    }
    
    func hotkeyExists(keyCode: Int16, modifiers: Int16) -> Bool {
        let request: NSFetchRequest<HotkeyEntity> = HotkeyEntity.fetchRequest()
        request.predicate = NSPredicate(format: "keyCode == %d AND modifiers == %d", keyCode, modifiers)
        
        do {
            let count = try context.count(for: request)
            return count > 0
        } catch {
            print("Error checking hotkey existence: \(error)")
            return false
        }
    }
    
    func deleteHotkey(_ hotkey: HotkeyEntity) {
        context.delete(hotkey)
        saveContext()
        print("✅ Hotkey deleted: \(hotkey.displayName ?? "Unknown")")
    }
    
    func generateDisplayName(keyCode: Int16, modifiers: Int16) -> String {
        return HotkeyFormatter.generateDisplayName(keyCode: keyCode, modifiers: modifiers)
    }
}
