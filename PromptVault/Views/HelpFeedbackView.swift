//
//  HelpFeedbackView.swift
//  PromptVault
//
//  Created by Kazuma Sakaguchi on 2025/07/02.
//

import SwiftUI

/// ヘルプとフィードバック画面のView
/// アプリの使用方法やサポート情報、フィードバック送信機能を提供する画面
struct HelpFeedbackView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            PageHeaderView(title: "Help & Feedback")
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

#Preview {
    HelpFeedbackView()
}