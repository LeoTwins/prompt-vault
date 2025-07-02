//
//  GeneralView.swift
//  PromptVault
//
//  Created by Kazuma Sakaguchi on 2025/07/02.
//

import SwiftUI

/// General設定画面のView
/// 一般的なアプリケーション設定を管理する画面
struct GeneralView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            PageHeaderView(title: "General")
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

#Preview {
    GeneralView()
}