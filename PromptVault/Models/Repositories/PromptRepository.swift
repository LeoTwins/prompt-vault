//
//  PromptRepository.swift
//  PromptVault
//
//  Created by Claude Code on 2025/07/05.
//

import Foundation
@preconcurrency import CoreData

// MARK: - Protocol (Interface)

/// Promptデータの永続化操作を定義するプロトコル
protocol PromptRepositoryProtocol: Sendable {
    /// 新しいPromptを作成する
    func create(_ prompt: Prompt) async throws -> Prompt
    
    /// IDでPromptを取得する
    func getById(_ id: String) async throws -> Prompt?
    
    /// 全てのPromptを取得する
    func getAll() async throws -> [Prompt]
    
    /// カテゴリIDでPromptを取得する
    func getByCategoryId(_ categoryId: String) async throws -> [Prompt]
    
    /// Promptを更新する
    func update(_ prompt: Prompt) async throws -> Prompt
    
    /// Promptを削除する
    func delete(_ id: String) async throws
}

// MARK: - Repository Errors

enum PromptRepositoryError: Error, LocalizedError {
    case promptNotFound
    case categoryNotFound
    case coreDataError(Error)
    case conversionError
    
    var errorDescription: String? {
        switch self {
        case .promptNotFound:
            return "Prompt not found"
        case .categoryNotFound:
            return "Category not found"
        case .coreDataError(let error):
            return "Core Data error: \(error.localizedDescription)"
        case .conversionError:
            return "Failed to convert between Prompt and PromptEntity"
        }
    }
}

// MARK: - Repository Implementation

/// PromptRepositoryの実装クラス
final class PromptRepository: PromptRepositoryProtocol, @unchecked Sendable {
    private let context: NSManagedObjectContext
    
    /// 初期化
    /// - Parameter context: Core DataのNSManagedObjectContext。nilの場合はデフォルトのコンテキストを使用
    init(context: NSManagedObjectContext? = nil) {
        if let context = context {
            self.context = context
        } else {
            self.context = DatabaseManager.shared.context
        }
    }
    
    // MARK: - CRUD Operations
    
    func create(_ prompt: Prompt) async throws -> Prompt {
        return try await context.perform {
            // カテゴリの存在確認
            guard let categoryEntity = try self.findCategoryEntitySync(by: prompt.categoryId) else {
                throw PromptRepositoryError.categoryNotFound
            }
            
            // PromptEntityを作成
            let promptEntity = PromptEntity(context: self.context)
            promptEntity.id = UUID(uuidString: prompt.id) ?? UUID()
            promptEntity.title = prompt.title
            promptEntity.content = prompt.content
            promptEntity.createdAt = prompt.createdAt
            promptEntity.updatedAt = prompt.updatedAt
            promptEntity.usageCount = Int32(prompt.usageCount)
            promptEntity.category = categoryEntity
            
            // ホットキーIDが指定されている場合は関連付け
            if let hotkeyId = prompt.hotkeyId {
                // ホットキーエンティティを検索して関連付け
                if let hotkeyEntity = try self.findHotkeyEntitySync(by: hotkeyId) {
                    promptEntity.hotkey = hotkeyEntity
                }
            }
            
            // 保存
            do {
                try self.context.save()
                return try self.convertToPrompt(from: promptEntity)
            } catch {
                throw PromptRepositoryError.coreDataError(error)
            }
        }
    }
    
    func getById(_ id: String) async throws -> Prompt? {
        return try await context.perform {
            guard let uuid = UUID(uuidString: id) else {
                return nil
            }
            
            let request: NSFetchRequest<PromptEntity> = PromptEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", uuid as CVarArg)
            request.fetchLimit = 1
            
            do {
                let results = try self.context.fetch(request)
                guard let promptEntity = results.first else {
                    return nil
                }
                return try self.convertToPrompt(from: promptEntity)
            } catch {
                throw PromptRepositoryError.coreDataError(error)
            }
        }
    }
    
    func getAll() async throws -> [Prompt] {
        return try await context.perform {
            let request: NSFetchRequest<PromptEntity> = PromptEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            
            do {
                let results = try self.context.fetch(request)
                return try results.map { try self.convertToPrompt(from: $0) }
            } catch {
                throw PromptRepositoryError.coreDataError(error)
            }
        }
    }
    
    func getByCategoryId(_ categoryId: String) async throws -> [Prompt] {
        return try await context.perform {
            guard let categoryUUID = UUID(uuidString: categoryId) else {
                return []
            }
            
            let request: NSFetchRequest<PromptEntity> = PromptEntity.fetchRequest()
            request.predicate = NSPredicate(format: "category.id == %@", categoryUUID as CVarArg)
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            
            do {
                let results = try self.context.fetch(request)
                return try results.map { try self.convertToPrompt(from: $0) }
            } catch {
                throw PromptRepositoryError.coreDataError(error)
            }
        }
    }
    
    func update(_ prompt: Prompt) async throws -> Prompt {
        return try await context.perform {
            guard let uuid = UUID(uuidString: prompt.id) else {
                throw PromptRepositoryError.promptNotFound
            }
            
            let request: NSFetchRequest<PromptEntity> = PromptEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", uuid as CVarArg)
            request.fetchLimit = 1
            
            do {
                let results = try self.context.fetch(request)
                guard let promptEntity = results.first else {
                    throw PromptRepositoryError.promptNotFound
                }
                
                // カテゴリの存在確認
                guard let categoryEntity = try self.findCategoryEntitySync(by: prompt.categoryId) else {
                    throw PromptRepositoryError.categoryNotFound
                }
                
                // 更新
                promptEntity.title = prompt.title
                promptEntity.content = prompt.content
                promptEntity.updatedAt = prompt.updatedAt
                promptEntity.usageCount = Int32(prompt.usageCount)
                promptEntity.category = categoryEntity
                
                if let hotkeyId = prompt.hotkeyId {
                    // ホットキーエンティティを検索して関連付け
                    if let hotkeyEntity = try self.findHotkeyEntitySync(by: hotkeyId) {
                        promptEntity.hotkey = hotkeyEntity
                    }
                }
                
                try self.context.save()
                return try self.convertToPrompt(from: promptEntity)
            } catch {
                throw PromptRepositoryError.coreDataError(error)
            }
        }
    }
    
    func delete(_ id: String) async throws {
        try await context.perform {
            guard let uuid = UUID(uuidString: id) else {
                throw PromptRepositoryError.promptNotFound
            }
            
            let request: NSFetchRequest<PromptEntity> = PromptEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", uuid as CVarArg)
            request.fetchLimit = 1
            
            do {
                let results = try self.context.fetch(request)
                guard let promptEntity = results.first else {
                    throw PromptRepositoryError.promptNotFound
                }
                
                self.context.delete(promptEntity)
                try self.context.save()
            } catch {
                throw PromptRepositoryError.coreDataError(error)
            }
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func findCategoryEntitySync(by categoryId: String) throws -> CategoryEntity? {
        guard let categoryUUID = UUID(uuidString: categoryId) else {
            return nil
        }
        
        let request: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", categoryUUID as CVarArg)
        request.fetchLimit = 1
        
        do {
            let results = try context.fetch(request)
            return results.first
        } catch {
            throw PromptRepositoryError.coreDataError(error)
        }
    }
    
    private func findHotkeyEntitySync(by hotkeyId: String) throws -> HotkeyEntity? {
        guard let hotkeyUUID = UUID(uuidString: hotkeyId) else {
            return nil
        }
        
        let request: NSFetchRequest<HotkeyEntity> = HotkeyEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", hotkeyUUID as CVarArg)
        request.fetchLimit = 1
        
        do {
            let results = try context.fetch(request)
            return results.first
        } catch {
            throw PromptRepositoryError.coreDataError(error)
        }
    }
    
    private func convertToPrompt(from entity: PromptEntity) throws -> Prompt {
        guard let id = entity.id?.uuidString,
              let title = entity.title,
              let content = entity.content,
              let categoryId = entity.category?.id?.uuidString,
              let createdAt = entity.createdAt,
              let updatedAt = entity.updatedAt else {
            throw PromptRepositoryError.conversionError
        }
        
        let hotkeyId = entity.hotkey?.id?.uuidString
        
        return Prompt(
            id: id,
            title: title,
            content: content,
            categoryId: categoryId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            usageCount: Int(entity.usageCount),
            hotkeyId: hotkeyId
        )
    }
}