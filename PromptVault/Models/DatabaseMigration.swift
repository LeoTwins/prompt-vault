//
//  DatabaseMigration.swift
//  PromptVault
//
//  Created by Kazuma Sakaguchi on 2025/07/03.
//

import Foundation
import CoreData

class DatabaseMigration {
    private static let dbVersionKey = "db_version"
    private static let currentVersion = 1
    
    /// データベースマイグレーションのメイン処理
    /// Core Dataでは自動マイグレーションを使用するため、主にデータの初期化を行う
    static func migrate() throws {
        let currentStoredVersion = UserDefaults.standard.integer(forKey: dbVersionKey)
        
        print("Current database version: \(currentStoredVersion)")
        print("Target database version: \(currentVersion)")
        
        // Core Dataでは、データモデルの変更は自動マイグレーションで処理される
        // ここではアプリケーションレベルでのデータ初期化を行う
        if currentStoredVersion < 1 {
            try migrateToVersion1()
        }
        
        UserDefaults.standard.set(currentVersion, forKey: dbVersionKey)
        print("Database migration completed to version \(currentVersion)")
    }
    
    /// データベースバージョン1へのマイグレーション
    /// Core Dataコンテキストの初期化確認とデフォルトデータの作成確認
    /// Hotkeyエンティティの追加も含む
    private static func migrateToVersion1() throws {
        print("Migrating to version 1: Initializing Core Data with Hotkey support")
        
        // DatabaseManagerの初期化により、デフォルトカテゴリが作成される
        let _ = DatabaseManager.shared
        print("✅ Core Data stack initialized")
        print("✅ Default categories will be created if needed")
        print("✅ Hotkey entity available for use")
    }
}