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
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            PageHeaderView(title: "Prompts")
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

#Preview {
    PromptsView()
}