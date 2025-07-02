//
//  ContentView.swift
//  PromptVault
//
//  Created by Kazuma Sakaguchi on 2025/07/01.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "doc.text")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("PromptVault Dashboard")
                .font(.title)
            Text("プロンプト管理ダッシュボード")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: 600, height: 400)
    }
}

#Preview {
    ContentView()
}
