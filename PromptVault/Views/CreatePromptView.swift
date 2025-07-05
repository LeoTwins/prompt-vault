//
//  CreatePromptView.swift
//  PromptVault
//
//  Created by Claude Code on 2025/07/05.
//

import SwiftUI

/// プロンプト新規作成画面
/// プロンプトのタイトル、コンテンツ、カテゴリを入力・選択するUIレイアウト
struct CreatePromptView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var promptsViewModel = PromptsViewModel()
    @State private var categoryViewModel = CategoryViewModel()
    @State private var hotkeyViewModel = HotkeyViewModel()
    
    // UI状態管理
    @State private var promptTitle = ""
    @State private var promptContent = ""
    @State private var selectedCategoryId: String = ""
    @State private var showingCreateCategory = false
    @State private var showValidationError = false
    @State private var validationErrorMessage = ""
    
    // ホットキー関連
    @State private var hotkeyEnabled = false
    @State private var isCapturingHotkey = false
    @State private var capturedKeyCode: Int16 = 0
    @State private var capturedModifiers: Int16 = 0
    @State private var hotkeyDisplayName = "Click to set hotkey"
    @FocusState private var hotkeyFieldFocused: Bool
    
    // カテゴリ作成完了時のコールバック（他のViewに作成完了を通知するため）
    let onCategoryCreated: ((Category) -> Void)?
    
    // プロンプト作成完了時のコールバック（他のViewに作成完了を通知するため）
    let onPromptCreated: ((Prompt) -> Void)?
    
    // イニシャライザー
    init(onCategoryCreated: ((Category) -> Void)? = nil, onPromptCreated: ((Prompt) -> Void)? = nil) {
        self.onCategoryCreated = onCategoryCreated
        self.onPromptCreated = onPromptCreated
    }
    
    private let addNewCategoryOption = "+ Add New Category"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            PageHeaderView(title: "Create New Prompt")
            
            // スクロール可能なフォーム本体
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                            
                            // Title input
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Title")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                TextField("Enter prompt title", text: $promptTitle)
                                    .font(.system(size: 14))
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(height: 36)
                            }
                            
                            // Category selection
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Category")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                HStack {
                                    Picker("Select category", selection: $selectedCategoryId) {
                                        if categoryViewModel.categories.isEmpty {
                                            Text("Loading...").tag("")
                                        } else {
                                            ForEach(categoryViewModel.categories, id: \.id) { category in
                                                Text(category.name).tag(category.id)
                                            }
                                            
                                            Divider()
                                            
                                            Text(addNewCategoryOption)
                                                .tag(addNewCategoryOption)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .frame(width: 200)
                                    .onChange(of: selectedCategoryId) { _, newValue in
                                        if newValue == addNewCategoryOption {
                                            showingCreateCategory = true
                                            // Reset to previous valid category
                                            selectedCategoryId = categoryViewModel.categories.first?.id ?? ""
                                        }
                                    }
                                    
                                    Spacer()
                                }
                            }
                            
                            // Content input
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Prompt Content")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                TextEditor(text: $promptContent)
                                    .font(.system(size: 14))
                                    .frame(height: 140)
                                    .padding(8)
                                    .background(Color(NSColor.textBackgroundColor))
                                    .cornerRadius(6)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                                    )
                            }
                            
                            // Hotkey input
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Hotkey (Optional)")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Toggle("Enable", isOn: $hotkeyEnabled)
                                        .font(.system(size: 12))
                                }
                                
                                if hotkeyEnabled {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack(spacing: 12) {
                                            ZStack {
                                                // 非表示のテキストフィールド（キー入力キャプチャ用）
                                                TextField("", text: .constant(""))
                                                    .opacity(0)
                                                    .frame(width: 0, height: 0)
                                                    .focused($hotkeyFieldFocused)
                                                    .onKeyPress { keyPress in
                                                        if isCapturingHotkey {
                                                            return handleKeyPress(keyPress)
                                                        }
                                                        return .ignored
                                                    }
                                                
                                                // 表示用ボタン
                                                Button(action: {
                                                    startCapturingHotkey()
                                                }) {
                                                    HStack {
                                                        if isCapturingHotkey {
                                                            Text("Press key combination...")
                                                                .foregroundColor(.blue)
                                                        } else if capturedModifiers != 0 || capturedKeyCode != 0 {
                                                            Text(hotkeyDisplayName)
                                                                .foregroundColor(.primary)
                                                        } else {
                                                            Text("Click to set hotkey")
                                                                .foregroundColor(.secondary)
                                                        }
                                                    }
                                                    .font(.system(size: 14))
                                                    .frame(width: 200, height: 32)
                                                    .background(Color(NSColor.controlBackgroundColor))
                                                    .cornerRadius(6)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 6)
                                                            .stroke(isCapturingHotkey ? Color.blue : Color(NSColor.separatorColor), lineWidth: 1)
                                                    )
                                                }
                                                .buttonStyle(.plain)
                                            }
                                            
                                            if capturedModifiers != 0 || capturedKeyCode != 0 {
                                                Button("Clear") {
                                                    clearHotkey()
                                                }
                                                .font(.system(size: 12))
                                                .buttonStyle(.bordered)
                                            }
                                            
                                            Spacer()
                                        }
                                        
                                        if capturedModifiers != 0 || capturedKeyCode != 0 {
                                            HStack {
                                                Image(systemName: "info.circle")
                                                    .foregroundColor(.blue)
                                                    .font(.system(size: 12))
                                                Text("Hotkey: \(hotkeyDisplayName)")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(.secondary)
                                                Spacer()
                                            }
                                        }
                                    }
                                }
                            }
                        
                        // Error message display (validation errors)
                        if showValidationError {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                    .font(.system(size: 14))
                                
                                Text(validationErrorMessage)
                                    .font(.system(size: 14))
                                    .foregroundColor(.red)
                                
                                Spacer()
                                
                                Button("Close") {
                                    showValidationError = false
                                }
                                .font(.system(size: 12))
                                .foregroundColor(.blue)
                            }
                            .padding(12)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(6)
                        }
                        
                        // Repository error message
                        if promptsViewModel.errorMessage != nil {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                    .font(.system(size: 14))
                                
                                Text(promptsViewModel.errorMessage ?? "Unknown error occurred")
                                    .font(.system(size: 14))
                                    .foregroundColor(.red)
                                
                                Spacer()
                                
                                Button("Close") {
                                    promptsViewModel.clearError()
                                }
                                .font(.system(size: 12))
                                .foregroundColor(.blue)
                            }
                            .padding(12)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(6)
                        }
                        
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 100) // フッターボタンエリアのためのスペース
            }
            
            // 下部固定ボタンエリア
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color(NSColor.separatorColor))
                    .frame(height: 1)
                
                HStack(spacing: 12) {
                    // Cancel button
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    .frame(width: 100)
                    
                    Spacer()
                    
                    // Form status display
                    if promptsViewModel.isLoading {
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
                            await createPrompt()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(width: 100)
                    .disabled(!isFormValid || promptsViewModel.isLoading)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color(NSColor.windowBackgroundColor))
            }
        }
        .navigationTitle("Create New Prompt")
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showingCreateCategory) {
            CreateCategoryView { category in
                // Add new category to the list
                Task {
                    await categoryViewModel.loadCategories()
                    selectedCategoryId = category.id
                }
                onCategoryCreated?(category)
            }
        }
        .task {
            // カテゴリ一覧を読み込み
            await categoryViewModel.loadCategories()
            // 最初のカテゴリを選択
            if selectedCategoryId.isEmpty, let firstCategory = categoryViewModel.categories.first {
                selectedCategoryId = firstCategory.id
            }
        }
        .onChange(of: promptTitle) { _, _ in
            clearValidationError()
            promptsViewModel.clearError()
        }
        .onChange(of: promptContent) { _, _ in
            clearValidationError()
            promptsViewModel.clearError()
        }
    }
    
    // MARK: - Computed Properties
    
    private var isFormValid: Bool {
        !promptTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !promptContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !selectedCategoryId.isEmpty
    }
    
    // MARK: - Private Methods
    
    private func createPrompt() async {
        let trimmedTitle = promptTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedContent = promptContent.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // バリデーション
        guard validateInput(title: trimmedTitle, content: trimmedContent) else {
            return
        }
        
        // ホットキーバリデーション
        if hotkeyEnabled && !validateHotkey() {
            return
        }
        
        // ホットキー作成（必要な場合）
        var hotkeyId: String?
        if hotkeyEnabled && (capturedModifiers != 0 || capturedKeyCode != 0) {
            // 重複チェック
            if !hotkeyViewModel.isValidKeyCodeAndModifiers(keyCode: capturedKeyCode, modifiers: capturedModifiers) {
                showValidationError(message: "This hotkey combination already exists")
                return
            }
            
            // ホットキー作成
            hotkeyViewModel.createHotkey(keyCode: capturedKeyCode, modifiers: capturedModifiers)
            
            if let error = hotkeyViewModel.error {
                showValidationError(message: error)
                return
            }
            
            // 作成されたホットキーのIDを取得
            if let createdHotkey = hotkeyViewModel.hotkeys.last {
                hotkeyId = createdHotkey.id?.uuidString
            }
        }
        
        // カテゴリを設定
        if let selectedCategory = categoryViewModel.categories.first(where: { $0.id == selectedCategoryId }) {
            promptsViewModel.selectCategory(selectedCategory)
        }
        
        // フォームデータを設定
        promptsViewModel.newPromptTitle = trimmedTitle
        promptsViewModel.newPromptContent = trimmedContent
        
        // プロンプト作成（ホットキーIDを含む）
        await createPromptWithHotkey(hotkeyId: hotkeyId)
        
        // 作成が成功した場合（エラーがない場合）
        if promptsViewModel.errorMessage == nil {
            // 作成されたプロンプトを通知
            if let createdPrompt = promptsViewModel.prompts.first {
                onPromptCreated?(createdPrompt)
            }
            dismiss()
        }
    }
    
    private func createPromptWithHotkey(hotkeyId: String?) async {
        // カテゴリを取得
        guard let selectedCategory = categoryViewModel.categories.first(where: { $0.id == selectedCategoryId }) else {
            showValidationError(message: "Please select a category")
            return
        }
        
        // Promptを直接作成してRepositoryに送信
        let newPrompt = Prompt(
            title: promptsViewModel.newPromptTitle,
            content: promptsViewModel.newPromptContent,
            categoryId: selectedCategory.id,
            hotkeyId: hotkeyId
        )
        
        // PromptsViewModelのrepositoryを使用してプロンプト作成
        do {
            let createdPrompt = try await promptsViewModel.repositoryAccess.create(newPrompt)
            promptsViewModel.prompts.insert(createdPrompt, at: 0)
        } catch {
            promptsViewModel.errorMessage = "プロンプトの作成に失敗しました: \(error.localizedDescription)"
        }
    }
    
    private func validateInput(title: String, content: String) -> Bool {
        if title.isEmpty {
            showValidationError(message: "Please enter a prompt title")
            return false
        }
        
        if content.isEmpty {
            showValidationError(message: "Please enter prompt content")
            return false
        }
        
        if selectedCategoryId.isEmpty {
            showValidationError(message: "Please select a category")
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
    
    // MARK: - Hotkey Methods
    
    private func startCapturingHotkey() {
        isCapturingHotkey = true
        hotkeyFieldFocused = true
        capturedKeyCode = 0
        capturedModifiers = 0
        hotkeyDisplayName = "Press key combination..."
    }
    
    private func handleKeyPress(_ keyPress: KeyPress) -> KeyPress.Result {
        guard isCapturingHotkey else { return .ignored }
        
        // Escapeキーでキャンセル
        if keyPress.key == .escape {
            cancelCapturingHotkey()
            return .handled
        }
        
        // KeyEquivalentからキーコードに変換
        capturedKeyCode = keyEquivalentToKeyCode(keyPress.key)
        capturedModifiers = eventModifiersToInt16(keyPress.modifiers)
        
        // 修飾キーのみの場合は無視
        if capturedModifiers == 0 && isModifierOnlyKey(keyPress.key) {
            return .handled
        }
        
        // 表示名を生成
        hotkeyDisplayName = HotkeyFormatter.generateDisplayName(
            keyCode: capturedKeyCode,
            modifiers: capturedModifiers
        )
        
        isCapturingHotkey = false
        hotkeyFieldFocused = false
        return .handled
    }
    
    private func isModifierOnlyKey(_ key: KeyEquivalent) -> Bool {
        // 修飾キーのみかどうかをチェック
        // KeyEquivalentの文字列表現をチェック
        let keyString = String(describing: key).lowercased()
        
        // 修飾キー単体の場合
        return keyString == "cmd" || 
               keyString == "shift" || 
               keyString == "option" || 
               keyString == "alt" ||
               keyString == "control" || 
               keyString == "ctrl"
    }
    
    private func cancelCapturingHotkey() {
        isCapturingHotkey = false
        hotkeyFieldFocused = false
        hotkeyDisplayName = capturedModifiers != 0 || capturedKeyCode != 0 ? 
            HotkeyFormatter.generateDisplayName(keyCode: capturedKeyCode, modifiers: capturedModifiers) : 
            "Click to set hotkey"
    }
    
    // MARK: - Helper Methods for Key Conversion
    
    private func keyEquivalentToKeyCode(_ key: KeyEquivalent) -> Int16 {
        // KeyEquivalentからキーコードへの変換
        switch key {
        case .space: return 0x31
        case .delete: return 0x33
        case .deleteForward: return 0x75
        case .return: return 0x24
        case .tab: return 0x30
        case .escape: return 0x35
        case .upArrow: return 0x7E
        case .downArrow: return 0x7D
        case .leftArrow: return 0x7B
        case .rightArrow: return 0x7C
        default:
            // 文字キーの場合は、文字から推測
            let keyString = String(describing: key).lowercased()
            return stringToKeyCode(keyString)
        }
    }
    
    private func stringToKeyCode(_ string: String) -> Int16 {
        // 文字列からキーコードへの変換（簡易版）
        switch string.first {
        case "a": return 0x00
        case "s": return 0x01
        case "d": return 0x02
        case "f": return 0x03
        case "h": return 0x04
        case "g": return 0x05
        case "z": return 0x06
        case "x": return 0x07
        case "c": return 0x08
        case "v": return 0x09
        case "b": return 0x0B
        case "q": return 0x0C
        case "w": return 0x0D
        case "e": return 0x0E
        case "r": return 0x0F
        case "y": return 0x10
        case "t": return 0x11
        case "1": return 0x12
        case "2": return 0x13
        case "3": return 0x14
        case "4": return 0x15
        case "6": return 0x16
        case "5": return 0x17
        case "=": return 0x18
        case "9": return 0x19
        case "7": return 0x1A
        case "-": return 0x1B
        case "8": return 0x1C
        case "0": return 0x1D
        case "]": return 0x1E
        case "o": return 0x1F
        case "u": return 0x20
        case "[": return 0x21
        case "i": return 0x22
        case "p": return 0x23
        case "l": return 0x25
        case "j": return 0x26
        case "'": return 0x27
        case "k": return 0x28
        case ";": return 0x29
        case "\\": return 0x2A
        case ",": return 0x2B
        case "/": return 0x2C
        case "n": return 0x2E
        case "m": return 0x2D
        case ".": return 0x2F
        case "`": return 0x32
        default: return 0x00
        }
    }
    
    private func eventModifiersToInt16(_ modifiers: EventModifiers) -> Int16 {
        var result: Int16 = 0
        
        if modifiers.contains(.command) {
            result |= Hotkey.ModifierKeys.command
        }
        if modifiers.contains(.shift) {
            result |= Hotkey.ModifierKeys.shift
        }
        if modifiers.contains(.option) {
            result |= Hotkey.ModifierKeys.option
        }
        if modifiers.contains(.control) {
            result |= Hotkey.ModifierKeys.control
        }
        
        return result
    }
    
    private func clearHotkey() {
        capturedKeyCode = 0
        capturedModifiers = 0
        hotkeyDisplayName = "Click to set hotkey"
        isCapturingHotkey = false
        hotkeyFieldFocused = false
    }
    
    private func validateHotkey() -> Bool {
        if hotkeyEnabled && capturedKeyCode == 0 && capturedModifiers == 0 {
            showValidationError(message: "Please set a hotkey or disable hotkey option")
            return false
        }
        return true
    }
}

#Preview {
    CreatePromptView(
        onCategoryCreated: { category in
            print("Created category: \(category.name)")
        },
        onPromptCreated: { prompt in
            print("Created prompt: \(prompt.title)")
        }
    )
}