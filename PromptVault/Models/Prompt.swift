//
//  Prompt.swift
//  PromptVault
//
//  Created by Kazuma Sakaguchi on 2025/07/03.
//

import Foundation

struct Prompt: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let content: String
    let categoryId: String
    let createdAt: Date
    let updatedAt: Date
    let usageCount: Int
    let hotkeyId: String?
    
    init(
        id: String = UUID().uuidString,
        title: String,
        content: String,
        categoryId: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        usageCount: Int = 0,
        hotkeyId: String? = nil
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.categoryId = categoryId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.usageCount = usageCount
        self.hotkeyId = hotkeyId
    }
}

extension Prompt {
    func withUpdatedUsage() -> Prompt {
        return Prompt(
            id: id,
            title: title,
            content: content,
            categoryId: categoryId,
            createdAt: createdAt,
            updatedAt: Date(),
            usageCount: usageCount + 1,
            hotkeyId: hotkeyId
        )
    }
    
    func withUpdatedContent(title: String? = nil, content: String? = nil, hotkeyId: String? = nil) -> Prompt {
        return Prompt(
            id: id,
            title: title ?? self.title,
            content: content ?? self.content,
            categoryId: categoryId,
            createdAt: createdAt,
            updatedAt: Date(),
            usageCount: usageCount,
            hotkeyId: hotkeyId ?? self.hotkeyId
        )
    }
}