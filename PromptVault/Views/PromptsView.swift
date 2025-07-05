//
//  PromptsView.swift
//  PromptVault
//
//  Created by Kazuma Sakaguchi on 2025/07/02.
//

import SwiftUI

/// プロンプト管理画面のView
/// 保存されたプロンプトの表示・編集・管理を行う画面
struct PromptsView: View {
    @State private var promptsViewModel = PromptsViewModel()
    @State private var categoryViewModel = CategoryViewModel()
    @State private var searchText = ""
    @State private var selectedCategoryId = "All"
    @State private var navigationPath = NavigationPath()
    
    var filteredPrompts: [Prompt] {
        let prompts = selectedCategoryId == "All" ? promptsViewModel.prompts : promptsViewModel.prompts.filter { $0.categoryId == selectedCategoryId }
        
        if searchText.isEmpty {
            return prompts
        } else {
            return prompts.filter { prompt in
                prompt.title.localizedCaseInsensitiveContains(searchText) ||
                prompt.content.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var categoryOptions: [(id: String, name: String)] {
        var options = [("All", "All")]
        options.append(contentsOf: categoryViewModel.categories.map { ($0.id, $0.name) })
        return options
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(alignment: .leading, spacing: 0) {
            PageHeaderView(title: "Prompts")
            
            // 検索エリア
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    // テキスト検索
                    TextField("Search prompts...", text: $searchText)
                        .font(.system(size: 14))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 300, height: 36)
                    
                    Spacer()
                    
                    // カテゴリ選択
                    Picker("Category", selection: $selectedCategoryId) {
                        ForEach(categoryOptions, id: \.id) { option in
                            Text(option.name).tag(option.id)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 120)
                }
                
                // アクションボタンエリア
                HStack(spacing: 8) {
                    Button(action: { 
                        navigationPath.append("CreatePrompt")
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "plus")
                            Text("New")
                        }
                        .font(.system(size: 14))
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button(action: { print("Import") }) {
                        HStack(spacing: 6) {
                            Image(systemName: "square.and.arrow.down")
                            Text("Import")
                        }
                        .font(.system(size: 14))
                    }
                    .buttonStyle(.bordered)
                    
                    Button(action: { print("Export") }) {
                        HStack(spacing: 6) {
                            Image(systemName: "square.and.arrow.up")
                            Text("Export")
                        }
                        .font(.system(size: 14))
                    }
                    .buttonStyle(.bordered)
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 15)
            .padding(.top, 16)
            .padding(.bottom, 16)
            
            // 検索エリアの下ボーダー
            Rectangle()
                .fill(Color(NSColor.separatorColor))
                .frame(height: 1)
            
            // プロンプトリスト
            if promptsViewModel.isLoading {
                Spacer()
                HStack {
                    Spacer()
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Loading prompts...")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                Spacer()
            } else if filteredPrompts.isEmpty {
                Spacer()
                HStack {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text(searchText.isEmpty ? "No prompts found" : "No prompts match your search")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                        if searchText.isEmpty {
                            Text("Create your first prompt to get started")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredPrompts) { prompt in
                            CardView {
                                VStack(alignment: .leading, spacing: 8) {
                                    // タイトルとカテゴリ
                                    HStack(alignment: .top) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(prompt.title)
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(.primary)
                                            
                                            HStack(spacing: 8) {
                                                if let category = categoryViewModel.categories.first(where: { $0.id == prompt.categoryId }) {
                                                    Text(category.name)
                                                        .font(.system(size: 12))
                                                        .foregroundColor(.secondary)
                                                        .padding(.horizontal, 8)
                                                        .padding(.vertical, 2)
                                                        .background(Color(hex: category.color ?? "#007AFF").opacity(0.1))
                                                        .cornerRadius(4)
                                                }
                                                
                                                if prompt.usageCount > 0 {
                                                    Text("Used \(prompt.usageCount) times")
                                                        .font(.system(size: 11))
                                                        .foregroundColor(.secondary)
                                                        .padding(.horizontal, 6)
                                                        .padding(.vertical, 2)
                                                        .background(Color.gray.opacity(0.1))
                                                        .cornerRadius(3)
                                                }
                                                
                                                if prompt.hotkeyId != nil {
                                                    // ホットキー表示（簡易版）
                                                    Text("⌘+Key")
                                                        .font(.system(size: 11, weight: .medium))
                                                        .foregroundColor(.primary)
                                                        .padding(.horizontal, 6)
                                                        .padding(.vertical, 2)
                                                        .background(Color.blue.opacity(0.1))
                                                        .cornerRadius(3)
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 3)
                                                                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                                        )
                                                }
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        // アクションボタン
                                        HStack(spacing: 8) {
                                            Button(action: { 
                                                Task {
                                                    await promptsViewModel.incrementUsageCount(for: prompt)
                                                }
                                            }) {
                                                Image(systemName: "doc.on.clipboard")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.blue)
                                            }
                                            .buttonStyle(.plain)
                                            .help("Copy to clipboard")
                                            
                                            Button(action: { print("Edit \(prompt.title)") }) {
                                                Image(systemName: "pencil")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.primary)
                                            }
                                            .buttonStyle(.plain)
                                            .help("Edit prompt")
                                            
                                            Button(action: { 
                                                Task {
                                                    await promptsViewModel.deletePrompt(id: prompt.id)
                                                }
                                            }) {
                                                Image(systemName: "trash")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.red)
                                            }
                                            .buttonStyle(.plain)
                                            .help("Delete prompt")
                                        }
                                    }
                                    
                                    // プロンプト内容（プレビュー）
                                    Text(prompt.content)
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.leading)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 15)
                    .padding(.top, 16)
                }
            }
            
            // エラーメッセージ
            if promptsViewModel.errorMessage != nil || categoryViewModel.hasError {
                VStack {
                    if let errorMessage = promptsViewModel.errorMessage {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(errorMessage)
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                            Spacer()
                            Button("Dismiss") {
                                promptsViewModel.clearError()
                            }
                            .font(.system(size: 12))
                            .foregroundColor(.blue)
                        }
                        .padding(12)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(6)
                        .padding(.horizontal, 15)
                    }
                }
            }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .navigationDestination(for: String.self) { destination in
                if destination == "CreatePrompt" {
                    CreatePromptView(
                        onCategoryCreated: { category in
                            // カテゴリが新規作成された場合、カテゴリ一覧を更新
                            Task {
                                await categoryViewModel.loadCategories()
                            }
                        },
                        onPromptCreated: { prompt in
                            // プロンプトが作成された場合、プロンプト一覧を更新
                            Task {
                                await promptsViewModel.loadPrompts()
                            }
                        }
                    )
                }
            }
            .task {
                // 初期データ読み込み
                await promptsViewModel.loadPrompts()
                await categoryViewModel.loadCategories()
            }
        }
    }
}

#Preview {
    PromptsView()
}