//
//  CardView.swift
//  PromptVault
//
//  Created by Kazuma Sakaguchi on 2025/07/02.
//

import SwiftUI

/// 再利用可能なカードコンポーネント
/// 呼び出し側から中身（content）を渡して使用する共通UI
struct CardView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .padding(16)
        .background(Color(NSColor.windowBackgroundColor).opacity(0.4))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(NSColor.separatorColor), lineWidth: 1.0)
        )
    }
}

#Preview {
    CardView {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Sample Title")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                Text("Sample description text")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: .constant(true))
                .toggleStyle(SwitchToggleStyle())
                .scaleEffect(1.2)
                .labelsHidden()
        }
    }
    .padding()
}