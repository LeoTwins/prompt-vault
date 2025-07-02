//
//  PromptsView.swift
//  PromptVault
//
//  Created by Kazuma Sakaguchi on 2025/07/02.
//

import SwiftUI

/// プロンプトデータの構造体（モックデータ用）
struct PromptItem: Identifiable {
    let id = UUID()
    let title: String
    let category: String
    let prompt: String
    let shortcut: String?
}

/// プロンプト管理画面のView
/// 保存されたプロンプトの表示・編集・管理を行う画面
struct PromptsView: View {
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    
    // モックデータ
    private let mockPrompts = [
        PromptItem(title: "Code Review", category: "Development", prompt: "Please review this code and provide feedback on improvements, best practices, and potential issues.", shortcut: "⌘R"),
        PromptItem(title: "Bug Analysis", category: "Development", prompt: "Analyze this bug report and suggest possible causes and solutions.", shortcut: "⌘B"),
        PromptItem(title: "Email Writing", category: "Communication", prompt: "Help me write a professional email for the following situation:", shortcut: "⌘E"),
        PromptItem(title: "Meeting Notes", category: "Communication", prompt: "Summarize the key points from this meeting transcript:", shortcut: "⌘M"),
        PromptItem(title: "Data Analysis", category: "Analytics", prompt: "Analyze this dataset and provide insights on patterns and trends.", shortcut: "⌘D")
    ]
    
    private let categories = ["All", "Development", "Communication", "Analytics"]
    
    var filteredPrompts: [PromptItem] {
        mockPrompts.filter { prompt in
            let matchesSearch = searchText.isEmpty || 
                prompt.title.localizedCaseInsensitiveContains(searchText) ||
                prompt.prompt.localizedCaseInsensitiveContains(searchText)
            let matchesCategory = selectedCategory == "All" || prompt.category == selectedCategory
            return matchesSearch && matchesCategory
        }
    }
    
    var body: some View {
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
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 120)
                }
                
                // アクションボタンエリア
                HStack(spacing: 8) {
                    Button(action: { print("New prompt") }) {
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
                                            Text(prompt.category)
                                                .font(.system(size: 12))
                                                .foregroundColor(.secondary)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 2)
                                                .background(Color.accentColor.opacity(0.1))
                                                .cornerRadius(4)
                                            
                                            if let shortcut = prompt.shortcut {
                                                Text(shortcut)
                                                    .font(.system(size: 11, weight: .medium))
                                                    .foregroundColor(.primary)
                                                    .padding(.horizontal, 6)
                                                    .padding(.vertical, 2)
                                                    .background(Color(NSColor.controlBackgroundColor))
                                                    .cornerRadius(3)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 3)
                                                            .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                                                    )
                                            }
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    // アクションボタン
                                    HStack(spacing: 8) {
                                        Button(action: { print("Edit \(prompt.title)") }) {
                                            Image(systemName: "pencil")
                                                .font(.system(size: 14))
                                                .foregroundColor(.primary)
                                        }
                                        .buttonStyle(.plain)
                                        .help("Edit prompt")
                                        
                                        Button(action: { print("Delete \(prompt.title)") }) {
                                            Image(systemName: "trash")
                                                .font(.system(size: 14))
                                                .foregroundColor(.red)
                                        }
                                        .buttonStyle(.plain)
                                        .help("Delete prompt")
                                    }
                                }
                                
                                // プロンプト内容（プレビュー）
                                Text(prompt.prompt)
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
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

#Preview {
    PromptsView()
}