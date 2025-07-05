//
//  CategoryViewModelTests.swift
//  PromptVaultTests
//
//  Created by Claude Code on 2025/07/05.
//

import Testing
import Foundation
@testable import PromptVault

// MARK: - Mock Repository

final class MockCategoryRepository: CategoryRepositoryProtocol, Sendable {
    private var categories: [Category] = []
    private var shouldThrowError = false
    private var errorToThrow: Error?
    
    func create(_ category: Category) async throws -> Category {
        if shouldThrowError, let error = errorToThrow {
            throw error
        }
        
        // 重複チェック
        if categories.contains(where: { $0.name.lowercased() == category.name.lowercased() }) {
            throw CategoryRepositoryError.duplicateName
        }
        
        categories.append(category)
        return category
    }
    
    func getById(_ id: String) async throws -> Category? {
        if shouldThrowError, let error = errorToThrow {
            throw error
        }
        
        return categories.first { $0.id == id }
    }
    
    func getAll() async throws -> [Category] {
        if shouldThrowError, let error = errorToThrow {
            throw error
        }
        
        return categories.sorted { $0.createdAt < $1.createdAt }
    }
    
    func update(_ category: Category) async throws -> Category {
        if shouldThrowError, let error = errorToThrow {
            throw error
        }
        
        guard let index = categories.firstIndex(where: { $0.id == category.id }) else {
            throw CategoryRepositoryError.categoryNotFound
        }
        
        // 名前の重複チェック（自分以外）
        if categories.contains(where: { $0.id != category.id && $0.name.lowercased() == category.name.lowercased() }) {
            throw CategoryRepositoryError.duplicateName
        }
        
        categories[index] = category
        return category
    }
    
    func delete(_ id: String) async throws {
        if shouldThrowError, let error = errorToThrow {
            throw error
        }
        
        guard let index = categories.firstIndex(where: { $0.id == id }) else {
            throw CategoryRepositoryError.categoryNotFound
        }
        
        categories.remove(at: index)
    }
    
    // MARK: - Test Helper Methods
    
    func setCategories(_ categories: [Category]) {
        self.categories = categories
    }
    
    func setShouldThrowError(_ shouldThrow: Bool, error: Error? = nil) {
        shouldThrowError = shouldThrow
        errorToThrow = error
    }
    
    func getCategoriesCount() -> Int {
        return categories.count
    }
}

// MARK: - Test Suite

@Suite("CategoryViewModel Tests")
struct CategoryViewModelTests {
    
    @Test("ViewModel initializes with empty state")
    func testInitialState() async {
        let mockRepository = MockCategoryRepository()
        let viewModel = CategoryViewModel(categoryRepository: mockRepository)
        
        #expect(viewModel.categories.isEmpty)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.hasError == false)
        #expect(viewModel.isEmpty == true)
    }
    
    @Test("Load categories successfully")
    func testLoadCategoriesSuccess() async {
        let mockRepository = MockCategoryRepository()
        let testCategories = [
            Category(name: "Test Category 1", color: "#FF0000"),
            Category(name: "Test Category 2", color: "#00FF00")
        ]
        mockRepository.setCategories(testCategories)
        
        let viewModel = CategoryViewModel(categoryRepository: mockRepository)
        
        await viewModel.loadCategories()
        
        #expect(viewModel.categories.count == 2)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isEmpty == false)
    }
    
    @Test("Load categories handles error")
    func testLoadCategoriesError() async {
        let mockRepository = MockCategoryRepository()
        mockRepository.setShouldThrowError(true, error: CategoryRepositoryError.coreDataError(NSError(domain: "TestError", code: 1)))
        
        let viewModel = CategoryViewModel(categoryRepository: mockRepository)
        
        await viewModel.loadCategories()
        
        #expect(viewModel.categories.isEmpty)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.hasError == true)
    }
    
    @Test("Create category successfully")
    func testCreateCategorySuccess() async {
        let mockRepository = MockCategoryRepository()
        let viewModel = CategoryViewModel(categoryRepository: mockRepository)
        
        await viewModel.createCategory(name: "New Category", color: "#FF0000")
        
        #expect(viewModel.categories.count == 1)
        #expect(viewModel.categories.first?.name == "New Category")
        #expect(viewModel.categories.first?.color == "#FF0000")
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test("Create category handles duplicate name error")
    func testCreateCategoryDuplicateName() async {
        let mockRepository = MockCategoryRepository()
        mockRepository.setCategories([Category(name: "Existing Category")])
        
        let viewModel = CategoryViewModel(categoryRepository: mockRepository)
        await viewModel.loadCategories()
        
        await viewModel.createCategory(name: "Existing Category")
        
        #expect(viewModel.categories.count == 1)
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.hasError == true)
    }
    
    @Test("Update category successfully")
    func testUpdateCategorySuccess() async {
        let mockRepository = MockCategoryRepository()
        let originalCategory = Category(name: "Original", color: "#FF0000")
        mockRepository.setCategories([originalCategory])
        
        let viewModel = CategoryViewModel(categoryRepository: mockRepository)
        await viewModel.loadCategories()
        
        let updatedCategory = Category(
            id: originalCategory.id,
            name: "Updated",
            color: "#00FF00",
            createdAt: originalCategory.createdAt
        )
        
        await viewModel.updateCategory(updatedCategory)
        
        #expect(viewModel.categories.count == 1)
        #expect(viewModel.categories.first?.name == "Updated")
        #expect(viewModel.categories.first?.color == "#00FF00")
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test("Delete category successfully")
    func testDeleteCategorySuccess() async {
        let mockRepository = MockCategoryRepository()
        let categoryToDelete = Category(name: "To Delete")
        mockRepository.setCategories([categoryToDelete])
        
        let viewModel = CategoryViewModel(categoryRepository: mockRepository)
        await viewModel.loadCategories()
        
        await viewModel.deleteCategory(categoryToDelete)
        
        #expect(viewModel.categories.isEmpty)
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test("Get category by ID successfully")
    func testGetCategoryById() async {
        let mockRepository = MockCategoryRepository()
        let testCategory = Category(name: "Test Category")
        mockRepository.setCategories([testCategory])
        
        let viewModel = CategoryViewModel(categoryRepository: mockRepository)
        
        let foundCategory = await viewModel.getCategoryById(testCategory.id)
        
        #expect(foundCategory != nil)
        #expect(foundCategory?.id == testCategory.id)
        #expect(foundCategory?.name == testCategory.name)
    }
    
    @Test("Initialize default categories when none exist")
    func testInitializeDefaultCategories() async {
        let mockRepository = MockCategoryRepository()
        let viewModel = CategoryViewModel(categoryRepository: mockRepository)
        
        await viewModel.initializeDefaultCategories()
        
        #expect(viewModel.categories.count == Category.defaultCategories.count)
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test("Initialize default categories skips when categories exist")
    func testInitializeDefaultCategoriesSkipsWhenExist() async {
        let mockRepository = MockCategoryRepository()
        let existingCategory = Category(name: "Existing")
        mockRepository.setCategories([existingCategory])
        
        let viewModel = CategoryViewModel(categoryRepository: mockRepository)
        
        await viewModel.initializeDefaultCategories()
        
        #expect(viewModel.categories.count == 1)
        #expect(viewModel.categories.first?.name == "Existing")
    }
    
    @Test("Category name validation works correctly")
    func testCategoryNameValidation() async {
        let mockRepository = MockCategoryRepository()
        let viewModel = CategoryViewModel(categoryRepository: mockRepository)
        
        #expect(viewModel.isValidCategoryName("Valid Name") == true)
        #expect(viewModel.isValidCategoryName("") == false)
        #expect(viewModel.isValidCategoryName("   ") == false)
        #expect(viewModel.isValidCategoryName("  Valid  ") == true)
    }
    
    @Test("Duplicate name check works correctly")
    func testDuplicateNameCheck() async {
        let mockRepository = MockCategoryRepository()
        let viewModel = CategoryViewModel(categoryRepository: mockRepository)
        
        let category1 = Category(name: "Category 1")
        let category2 = Category(name: "Category 2")
        mockRepository.setCategories([category1, category2])
        await viewModel.loadCategories()
        
        #expect(viewModel.isDuplicateCategoryName("Category 1") == true)
        #expect(viewModel.isDuplicateCategoryName("CATEGORY 1") == true) // 大文字小文字区別なし
        #expect(viewModel.isDuplicateCategoryName("New Category") == false)
        #expect(viewModel.isDuplicateCategoryName("Category 1", excludingId: category1.id) == false)
    }
    
    @Test("Sorted properties work correctly")
    func testSortedProperties() async {
        let mockRepository = MockCategoryRepository()
        let viewModel = CategoryViewModel(categoryRepository: mockRepository)
        
        let category1 = Category(name: "Z Category", createdAt: Date().addingTimeInterval(-100))
        let category2 = Category(name: "A Category", createdAt: Date())
        mockRepository.setCategories([category1, category2])
        await viewModel.loadCategories()
        
        let sortedByName = viewModel.sortedByName
        #expect(sortedByName.first?.name == "A Category")
        #expect(sortedByName.last?.name == "Z Category")
        
        let sortedByCreatedAt = viewModel.sortedByCreatedAt
        #expect(sortedByCreatedAt.first?.name == "Z Category")
        #expect(sortedByCreatedAt.last?.name == "A Category")
    }
    
    @Test("Clear error works correctly")
    func testClearError() async {
        let mockRepository = MockCategoryRepository()
        mockRepository.setShouldThrowError(true, error: CategoryRepositoryError.invalidName)
        
        let viewModel = CategoryViewModel(categoryRepository: mockRepository)
        
        await viewModel.loadCategories()
        #expect(viewModel.hasError == true)
        
        viewModel.clearError()
        #expect(viewModel.hasError == false)
        #expect(viewModel.errorMessage == nil)
    }
}