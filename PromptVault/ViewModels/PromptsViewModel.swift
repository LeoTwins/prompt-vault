//
//  PromptsViewModel.swift
//  PromptVault
//
//  Created by Claude Code on 2025/07/05.
//

import Foundation

@MainActor
@Observable
final class PromptsViewModel {
    
    // MARK: - Dependencies
    
    private let repository: PromptRepositoryProtocol
    
    // MARK: - Public Repository Access
    
    var repositoryAccess: PromptRepositoryProtocol {
        return repository
    }
    
    // MARK: - State Properties
    
    var prompts: [Prompt] = []
    var isLoading: Bool = false
    var errorMessage: String?
    
    // MARK: - Form Properties
    
    var newPromptTitle: String = ""
    var newPromptContent: String = ""
    var selectedCategory: PromptVault.Category?
    
    // MARK: - Computed Properties
    
    var isFormValid: Bool {
        !newPromptTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !newPromptContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        selectedCategory != nil
    }
    
    // MARK: - Initialization
    
    init(repository: PromptRepositoryProtocol = PromptRepository()) {
        self.repository = repository
    }
    
    // MARK: - Public Methods
    
    /// プロンプト一覧を読み込む
    func loadPrompts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            prompts = try await repository.getAll()
        } catch {
            errorMessage = "プロンプトの読み込みに失敗しました: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// 新しいプロンプトを作成する
    func createPrompt() async {
        guard isFormValid else {
            setValidationError()
            return
        }
        
        guard let category = selectedCategory else {
            errorMessage = "カテゴリを選択してください"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let newPrompt = Prompt(
            title: newPromptTitle.trimmingCharacters(in: .whitespacesAndNewlines),
            content: newPromptContent.trimmingCharacters(in: .whitespacesAndNewlines),
            categoryId: category.id
        )
        
        do {
            let createdPrompt = try await repository.create(newPrompt)
            prompts.insert(createdPrompt, at: 0) // 最新のプロンプトを先頭に追加
            clearForm()
        } catch {
            errorMessage = "プロンプトの作成に失敗しました: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// 指定されたIDのプロンプトを取得する
    func getPrompt(by id: String) async -> Prompt? {
        do {
            return try await repository.getById(id)
        } catch {
            errorMessage = "プロンプトの取得に失敗しました: \(error.localizedDescription)"
            return nil
        }
    }
    
    /// 指定されたカテゴリのプロンプト一覧を読み込む
    func loadPrompts(for categoryId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            prompts = try await repository.getByCategoryId(categoryId)
        } catch {
            errorMessage = "プロンプトの読み込みに失敗しました: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// プロンプトを更新する
    func updatePrompt(_ prompt: Prompt) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let updatedPrompt = try await repository.update(prompt)
            
            // ローカルの配列を更新
            if let index = prompts.firstIndex(where: { $0.id == updatedPrompt.id }) {
                prompts[index] = updatedPrompt
            }
        } catch {
            errorMessage = "プロンプトの更新に失敗しました: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// プロンプトを削除する
    func deletePrompt(id: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await repository.delete(id)
            prompts.removeAll { $0.id == id }
        } catch {
            errorMessage = "プロンプトの削除に失敗しました: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// プロンプトの使用回数を増加させる
    func incrementUsageCount(for prompt: Prompt) async {
        let updatedPrompt = prompt.withUpdatedUsage()
        await updatePrompt(updatedPrompt)
    }
    
    // MARK: - Form Management
    
    /// フォームをクリアする
    func clearForm() {
        newPromptTitle = ""
        newPromptContent = ""
        selectedCategory = nil
        errorMessage = nil
    }
    
    /// カテゴリを選択する
    func selectCategory(_ category: PromptVault.Category) {
        selectedCategory = category
        errorMessage = nil // カテゴリ選択時にエラーをクリア
    }
    
    /// エラーメッセージをクリアする
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Private Helper Methods
    
    private func setValidationError() {
        if newPromptTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "タイトルを入力してください"
        } else if newPromptContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "コンテンツを入力してください"
        } else if selectedCategory == nil {
            errorMessage = "カテゴリを選択してください"
        }
    }
}

// MARK: - Extensions

extension PromptsViewModel {
    
    /// プロンプト検索機能
    func searchPrompts(query: String) -> [Prompt] {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return prompts
        }
        
        let searchQuery = query.lowercased()
        return prompts.filter { prompt in
            prompt.title.lowercased().contains(searchQuery) ||
            prompt.content.lowercased().contains(searchQuery)
        }
    }
    
    /// 使用頻度順でソートされたプロンプト
    var promptsSortedByUsage: [Prompt] {
        prompts.sorted { $0.usageCount > $1.usageCount }
    }
    
    /// 作成日順でソートされたプロンプト
    var promptsSortedByDate: [Prompt] {
        prompts.sorted { $0.createdAt > $1.createdAt }
    }
    
    /// カテゴリ別にグループ化されたプロンプト
    func promptsGroupedByCategory() -> [String: [Prompt]] {
        Dictionary(grouping: prompts) { $0.categoryId }
    }
}