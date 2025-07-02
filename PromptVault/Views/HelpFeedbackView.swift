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
    private let supportEmail = "test@example.com"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            PageHeaderView(title: "Help & Feedback")
            
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    // Support Email カード
                    CardView {
                        HStack {
                            Text("Support Email:")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            HStack(spacing: 8) {
                                Text(supportEmail)
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                
                                Button(action: {
                                    copyToClipboard(supportEmail)
                                }) {
                                    Image(systemName: "doc.on.doc")
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                }
                                .buttonStyle(.plain)
                                .help("Copy email address")
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 15)
                .padding(.top, 20)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
    
    private func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
}

#Preview {
    HelpFeedbackView()
}