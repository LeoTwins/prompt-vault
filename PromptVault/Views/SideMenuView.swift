//
//  SideMenuView.swift
//  PromptVault
//
//  Created by Kazuma Sakaguchi on 2025/07/02.
//

import SwiftUI

/// サイドメニューのUI
struct SideMenuView: View {
    @EnvironmentObject var viewModel: SideMenuViewModel
    
    var body: some View {
        if viewModel.isVisible {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(viewModel.menuItems) { item in
                    Button(action: {
                        viewModel.selectMenuItem(item)
                    }) {
                        HStack(spacing: 10) {
                            // アイコン表示
                            Image(systemName: item.iconName)
                                .foregroundColor(isSelected(item) ? .white : .primary)
                                .frame(width: 20, height: 20)
                            
                            // メニュー項目名表示
                            Text(item.title)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(isSelected(item) ? .white : .primary)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Rectangle()
                                .fill(isSelected(item) ? Color.accentColor : Color.clear)
                                .cornerRadius(8)
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                }
                
                Spacer()
            }
            .padding(.top, 40)
            .frame(width: 240)
            .background(Color(NSColor.windowBackgroundColor))
        }
    }
    
    private func isSelected(_ item: MenuItem) -> Bool {
        viewModel.selectedMenuItem?.id == item.id
    }
}

#Preview {
    SideMenuView()
        .environmentObject(SideMenuViewModel())
}