//
//  SideMenuViewModel.swift
//  PromptVault
//
//  Created by Kazuma Sakaguchi on 2025/07/02.
//

import Foundation
import SwiftUI

/// サイドメニューの状態管理を行うViewModel
/// メニューの表示/非表示、選択状態、メニュー項目の管理を担当
class SideMenuViewModel: ObservableObject {
    @Published var isVisible: Bool = true
    @Published var selectedMenuItem: MenuItem?
    @Published var menuItems: [MenuItem] = MenuItem.defaultItems
    
    init() {
        selectedMenuItem = menuItems.first
    }
    
    func selectMenuItem(_ item: MenuItem) {
        selectedMenuItem = item
    }
    
    func toggleVisibility() {
        isVisible.toggle()
    }
    
    func hideMenu() {
        isVisible = false
    }
    
    func showMenu() {
        isVisible = true
    }
}