//
//  CategoryRepository.swift
//  PromptVault
//
//  Created by Claude Code on 2025/07/05.
//

import Foundation
@preconcurrency import CoreData

// MARK: - Protocol (Interface)

/// Categoryデータの永続化操作を定義するプロトコル
protocol CategoryRepositoryProtocol: Sendable {
    /// 新しいCategoryを作成する
    func create(_ category: PromptVault.Category) async throws -> PromptVault.Category
    
    /// IDでCategoryを取得する
    func getById(_ id: String) async throws -> PromptVault.Category?
    
    /// 全てのCategoryを取得する
    func getAll() async throws -> [PromptVault.Category]
    
    /// Categoryを更新する
    func update(_ category: PromptVault.Category) async throws -> PromptVault.Category
    
    /// Categoryを削除する
    func delete(_ id: String) async throws
}

// MARK: - Repository Errors

enum CategoryRepositoryError: Error, LocalizedError {
    case invalidName
    case duplicateName
    case categoryNotFound
    case coreDataError(Error)
    case conversionError
    
    var errorDescription: String? {
        switch self {
        case .invalidName:
            return "Category name cannot be empty"
        case .duplicateName:
            return "Category name already exists"
        case .categoryNotFound:
            return "Category not found"
        case .coreDataError(let error):
            return "Core Data error: \(error.localizedDescription)"
        case .conversionError:
            return "Failed to convert between Category and CategoryEntity"
        }
    }
}

// MARK: - Repository Implementation

/// CategoryRepositoryの実装クラス
final class CategoryRepository: CategoryRepositoryProtocol, @unchecked Sendable {
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
    
    func create(_ category: PromptVault.Category) async throws -> PromptVault.Category {
        return try await context.perform {
            // 名前のバリデーション
            let trimmedName = category.name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedName.isEmpty else {
                throw CategoryRepositoryError.invalidName
            }
            
            // 重複チェック（大文字小文字区別なし）
            if try self.categoryExistsSync(name: trimmedName) {
                throw CategoryRepositoryError.duplicateName
            }
            
            // CategoryEntityを作成
            let categoryEntity = CategoryEntity(context: self.context)
            categoryEntity.id = UUID(uuidString: category.id) ?? UUID()
            categoryEntity.name = trimmedName
            categoryEntity.color = category.color
            categoryEntity.createdAt = category.createdAt
            
            // 保存
            do {
                try self.context.save()
                return try self.convertToCategory(from: categoryEntity)
            } catch {
                throw CategoryRepositoryError.coreDataError(error)
            }
        }
    }
    
    func getById(_ id: String) async throws -> PromptVault.Category? {
        return try await context.perform {
            guard let uuid = UUID(uuidString: id) else {
                return nil
            }
            
            let request: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", uuid as CVarArg)
            request.fetchLimit = 1
            
            do {
                let results = try self.context.fetch(request)
                guard let categoryEntity = results.first else {
                    return nil
                }
                return try self.convertToCategory(from: categoryEntity)
            } catch {
                throw CategoryRepositoryError.coreDataError(error)
            }
        }
    }
    
    func getAll() async throws -> [PromptVault.Category] {
        return try await context.perform {
            let request: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
            
            do {
                let results = try self.context.fetch(request)
                return try results.map { try self.convertToCategory(from: $0) }
            } catch {
                throw CategoryRepositoryError.coreDataError(error)
            }
        }
    }
    
    func update(_ category: PromptVault.Category) async throws -> PromptVault.Category {
        return try await context.perform {
            guard let uuid = UUID(uuidString: category.id) else {
                throw CategoryRepositoryError.categoryNotFound
            }
            
            // 名前のバリデーション
            let trimmedName = category.name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedName.isEmpty else {
                throw CategoryRepositoryError.invalidName
            }
            
            let request: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", uuid as CVarArg)
            request.fetchLimit = 1
            
            do {
                let results = try self.context.fetch(request)
                guard let categoryEntity = results.first else {
                    throw CategoryRepositoryError.categoryNotFound
                }
                
                // 名前が変更されている場合、重複チェック
                if categoryEntity.name != trimmedName {
                    if try self.categoryExistsSync(name: trimmedName) {
                        throw CategoryRepositoryError.duplicateName
                    }
                }
                
                // 更新
                categoryEntity.name = trimmedName
                categoryEntity.color = category.color
                
                try self.context.save()
                return try self.convertToCategory(from: categoryEntity)
            } catch {
                throw CategoryRepositoryError.coreDataError(error)
            }
        }
    }
    
    func delete(_ id: String) async throws {
        try await context.perform {
            guard let uuid = UUID(uuidString: id) else {
                throw CategoryRepositoryError.categoryNotFound
            }
            
            let request: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", uuid as CVarArg)
            request.fetchLimit = 1
            
            do {
                let results = try self.context.fetch(request)
                guard let categoryEntity = results.first else {
                    throw CategoryRepositoryError.categoryNotFound
                }
                
                self.context.delete(categoryEntity)
                try self.context.save()
            } catch {
                throw CategoryRepositoryError.coreDataError(error)
            }
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func categoryExistsSync(name: String) throws -> Bool {
        let request: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        request.predicate = NSPredicate(format: "name ==[c] %@", name) // 大文字小文字区別なし
        request.fetchLimit = 1
        
        do {
            let results = try context.fetch(request)
            return !results.isEmpty
        } catch {
            throw CategoryRepositoryError.coreDataError(error)
        }
    }
    
    private func convertToCategory(from entity: CategoryEntity) throws -> PromptVault.Category {
        guard let id = entity.id?.uuidString,
              let name = entity.name,
              let createdAt = entity.createdAt else {
            throw CategoryRepositoryError.conversionError
        }
        
        return PromptVault.Category(
            id: id,
            name: name,
            color: entity.color,
            createdAt: createdAt
        )
    }
}