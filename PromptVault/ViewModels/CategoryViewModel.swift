//
//  CategoryViewModel.swift
//  PromptVault
//
//  Created by Claude Code on 2025/07/05.
//

import Foundation

@MainActor
@Observable
final class CategoryViewModel {
    private let categoryRepository: CategoryRepositoryProtocol
    
    // MARK: - State
    private(set) var categories: [Category] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    
    // MARK: - Initialization
    init(categoryRepository: CategoryRepositoryProtocol = CategoryRepository()) {
        self.categoryRepository = categoryRepository
    }
    
    // MARK: - Actions
    
    /// カテゴリ一覧を読み込む
    func loadCategories() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            categories = try await categoryRepository.getAll()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    /// 新しいカテゴリを作成する
    func createCategory(name: String, color: String? = nil) async {
        errorMessage = nil
        
        let newCategory = Category(name: name, color: color)
        
        do {
            let createdCategory = try await categoryRepository.create(newCategory)
            categories.append(createdCategory)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    /// カテゴリを更新する
    func updateCategory(_ category: Category) async {
        errorMessage = nil
        
        do {
            let updatedCategory = try await categoryRepository.update(category)
            
            // ローカルの配列を更新
            if let index = categories.firstIndex(where: { $0.id == category.id }) {
                categories[index] = updatedCategory
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    /// カテゴリを削除する
    func deleteCategory(_ category: Category) async {
        errorMessage = nil
        
        do {
            try await categoryRepository.delete(category.id)
            
            // ローカルの配列から削除
            categories.removeAll { $0.id == category.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    /// IDでカテゴリを取得する
    func getCategoryById(_ id: String) async -> Category? {
        do {
            return try await categoryRepository.getById(id)
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
    
    /// デフォルトカテゴリを初期化する
    func initializeDefaultCategories() async {
        errorMessage = nil
        
        // 既存のカテゴリが存在するかチェック
        do {
            let existingCategories = try await categoryRepository.getAll()
            if !existingCategories.isEmpty {
                categories = existingCategories
                return
            }
        } catch {
            errorMessage = error.localizedDescription
            return
        }
        
        // デフォルトカテゴリを作成
        for defaultCategory in Category.defaultCategories {
            do {
                let createdCategory = try await categoryRepository.create(defaultCategory)
                categories.append(createdCategory)
            } catch {
                errorMessage = error.localizedDescription
                break
            }
        }
    }
    
    // MARK: - Computed Properties
    
    /// エラーが発生しているかどうか
    var hasError: Bool {
        errorMessage != nil
    }
    
    /// カテゴリが空かどうか
    var isEmpty: Bool {
        categories.isEmpty
    }
    
    /// 作成日時順でソートされたカテゴリ
    var sortedByCreatedAt: [Category] {
        categories.sorted { $0.createdAt < $1.createdAt }
    }
    
    /// 名前順でソートされたカテゴリ
    var sortedByName: [Category] {
        categories.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
    }
    
    // MARK: - Validation
    
    /// カテゴリ名が有効かどうかをチェック
    func isValidCategoryName(_ name: String) -> Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedName.isEmpty
    }
    
    /// カテゴリ名が重複していないかチェック
    func isDuplicateCategoryName(_ name: String, excludingId: String? = nil) -> Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return categories.contains { category in
            if let excludingId = excludingId, category.id == excludingId {
                return false
            }
            return category.name.lowercased() == trimmedName.lowercased()
        }
    }
    
    // MARK: - Error Handling
    
    /// エラーメッセージをクリアする
    func clearError() {
        errorMessage = nil
    }
}