//
//  PageHeaderView.swift
//  PromptVault
//
//  Created by Kazuma Sakaguchi on 2025/07/02.
//

import SwiftUI

/// 再利用可能なページヘッダーコンポーネント
/// タイトルをプロパティとして受け取り、統一されたスタイルでヘッダーを表示する
struct PageHeaderView: View {
    let title: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
                .padding(.top, 15)
                .padding(.leading, 10)
            
            // タイトル下のボーダー
            Rectangle()
                .fill(Color(NSColor.separatorColor))
                .frame(height: 1)
                .padding(.top, 15)
        }
    }
}

#Preview {
    PageHeaderView(title: "Sample Title")
}