//
//  CreateCategoryView.swift
//  PromptVault
//
//  Created by Claude Code on 2025/07/05.
//

import SwiftUI

/// カテゴリ新規作成画面（小さなwindow用）
/// カテゴリ名とカラーを入力して新規カテゴリを作成する
struct CreateCategoryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = CategoryViewModel()
    
    // UI状態管理
    @State private var categoryName = ""
    @State private var selectedColor = "#007AFF"
    @State private var showValidationError = false
    @State private var validationErrorMessage = ""
    
    // カテゴリ作成完了時のコールバック（他のViewに作成完了を通知するため）
    let onCategoryCreated: ((Category) -> Void)?
    
    // プリセットカラー
    private let presetColors = [
        "#007AFF", // Blue
        "#34C759", // Green
        "#FF9500", // Orange
        "#FF3B30", // Red
        "#AF52DE", // Purple
        "#FF2D92", // Pink
        "#5AC8FA", // Light Blue
        "#FFCC00", // Yellow
        "#FF6B6B", // Light Red
        "#4ECDC4"  // Teal
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Create New Category")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("✕") {
                    dismiss()
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            Divider()
            
            // Form content
            VStack(alignment: .leading, spacing: 20) {
                
                // Category name input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Category Name")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    TextField("Enter category name", text: $categoryName)
                        .font(.system(size: 14))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(height: 36)
                }
                
                // Color selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Color")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 8) {
                        ForEach(presetColors, id: \.self) { color in
                            Button(action: {
                                selectedColor = color
                            }) {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color(hex: color))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(
                                                selectedColor == color ? Color.primary : Color.clear,
                                                lineWidth: selectedColor == color ? 3 : 0
                                            )
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                // Preview
                HStack(spacing: 12) {
                    Text("Preview:")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    if !categoryName.isEmpty {
                        Text(categoryName)
                            .font(.system(size: 12))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(hex: selectedColor).opacity(0.1))
                            .cornerRadius(4)
                    } else {
                        Text("Category Preview")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(4)
                    }
                    
                    Spacer()
                }
                
                // Error message (validation errors)
                if showValidationError {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                            .font(.system(size: 14))
                        
                        Text(validationErrorMessage)
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                        
                        Spacer()
                    }
                    .padding(12)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(6)
                }
                
                // Repository error message
                if viewModel.hasError {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                            .font(.system(size: 14))
                        
                        Text(viewModel.errorMessage ?? "Unknown error occurred")
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                        
                        Spacer()
                    }
                    .padding(12)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(6)
                }
                
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 20)
            
            Spacer()
            
            // Bottom button area
            VStack(spacing: 0) {
                Divider()
                
                HStack(spacing: 12) {
                    // Cancel button
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    .frame(width: 80)
                    
                    Spacer()
                    
                    // Loading indicator
                    if viewModel.isLoading {
                        HStack(spacing: 8) {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Creating...")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Create button
                    Button("Create") {
                        Task {
                            await createCategory()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(width: 80)
                    .disabled(categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color(NSColor.windowBackgroundColor))
            }
        }
        .frame(width: 400, height: 450)
        .onChange(of: categoryName) { _, newValue in
            // カテゴリ名が変更されたらエラーをクリア
            clearValidationError()
            viewModel.clearError()
        }
        .task {
            // ViewModelのカテゴリ一覧を読み込み（重複チェック用）
            await viewModel.loadCategories()
        }
    }
    
    // MARK: - Private Methods
    
    private func createCategory() async {
        let trimmedName = categoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // バリデーション
        guard validateInput(name: trimmedName) else {
            return
        }
        
        // カテゴリ作成
        await viewModel.createCategory(name: trimmedName, color: selectedColor)
        
        // 作成が成功した場合（エラーがない場合）
        if !viewModel.hasError {
            // 作成されたカテゴリを見つけて通知
            if let createdCategory = viewModel.categories.first(where: { $0.name == trimmedName }) {
                onCategoryCreated?(createdCategory)
            }
            dismiss()
        }
    }
    
    private func validateInput(name: String) -> Bool {
        // 名前が空でないかチェック
        guard viewModel.isValidCategoryName(name) else {
            showValidationError(message: "Please enter a category name")
            return false
        }
        
        // 重複チェック
        guard !viewModel.isDuplicateCategoryName(name) else {
            showValidationError(message: "Category name already exists")
            return false
        }
        
        return true
    }
    
    private func showValidationError(message: String) {
        validationErrorMessage = message
        showValidationError = true
    }
    
    private func clearValidationError() {
        showValidationError = false
        validationErrorMessage = ""
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    CreateCategoryView { category in
        print("Created category: \(category.name) with color: \(category.color ?? "default")")
    }
}