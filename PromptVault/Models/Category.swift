//
//  Category.swift
//  PromptVault
//
//  Created by Kazuma Sakaguchi on 2025/07/03.
//

import Foundation

struct Category: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let color: String?
    let createdAt: Date
    
    init(id: String = UUID().uuidString, name: String, color: String? = nil, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.color = color
        self.createdAt = createdAt
    }
}

extension Category {
    static let defaultCategories = [
        Category(name: "コード生成", color: "#007AFF"),
        Category(name: "デバッグ", color: "#FF3B30"),
        Category(name: "説明", color: "#34C759"),
        Category(name: "レビュー", color: "#FF9500")
    ]
}