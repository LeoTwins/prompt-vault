//
//  DatabaseManager.swift
//  PromptVault
//
//  Created by Kazuma Sakaguchi on 2025/07/03.
//

import Foundation
import CoreData

class DatabaseManager {
    static let shared = DatabaseManager()
    
    private init() {
        // デフォルトカテゴリの作成をバックグラウンドで実行
        createDefaultCategoriesIfNeeded()
    }
    
    // MARK: - Core Data Stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PromptVault")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Core Data error: \(error), \(error.userInfo)")
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
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // MARK: - Default Categories
    
    private func createDefaultCategoriesIfNeeded() {
        let request: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        
        do {
            let count = try context.count(for: request)
            if count == 0 {
                createDefaultCategories()
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
            category.id = UUID().uuidString
            category.name = name
            category.color = color
            category.createdAt = Date()
        }
        
        saveContext()
        print("✅ Default categories created")
    }
}