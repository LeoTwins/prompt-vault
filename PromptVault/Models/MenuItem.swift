//
//  MenuItem.swift
//  PromptVault
//
//  Created by Kazuma Sakaguchi on 2025/07/02.
//

import Foundation

/// サイドメニューの各項目を表すデータモデル
struct MenuItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let iconName: String
    let type: MenuItemType
    
    /// メニュー項目の種類を定義する列挙型
    enum MenuItemType: String, CaseIterable {
        case general = "general"
        case prompts = "prompts"
        case helpFeedback = "help_feedback"
        
        /// 各メニュー項目の表示用タイトルを返す
        var displayTitle: String {
            switch self {
            case .general:
                return "General"
            case .prompts:
                return "Prompts"
            case .helpFeedback:
                return "Help & Feedback"
            }
        }
        
        /// 各メニュー項目のSF Symbolsアイコン名を返す
        var iconName: String {
            switch self {
            case .general:
                return "gearshape"
            case .prompts:
                return "doc.text"
            case .helpFeedback:
                return "questionmark.circle"
            }
        }
    }
    
    /// デフォルトで表示するメニュー項目のリスト
    static let defaultItems: [MenuItem] = [
        MenuItem(title: MenuItemType.general.displayTitle, iconName: MenuItemType.general.iconName, type: .general),
        MenuItem(title: MenuItemType.prompts.displayTitle, iconName: MenuItemType.prompts.iconName, type: .prompts),
        MenuItem(title: MenuItemType.helpFeedback.displayTitle, iconName: MenuItemType.helpFeedback.iconName, type: .helpFeedback)
    ]
}