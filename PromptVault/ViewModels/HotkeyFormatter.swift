//
//  HotkeyFormatter.swift
//  PromptVault
//
//  Created by Kazuma Sakaguchi on 2025/07/04.
//

import Foundation

/// ホットキー表示用のフォーマッター
/// Swift 6 Strict Concurrency対応のため、@MainActorから分離
struct HotkeyFormatter {
    
    /// macOS公式仮想キーコードから文字への変換
    /// 参考: HIToolbox/Events.h (kVK_* constants)
    static func keyCodeToChar(keyCode: Int16) -> String {
        switch keyCode {
        // ANSI Keyboard Letters (kVK_ANSI_*)
        case 0x00: return "A"
        case 0x01: return "S" 
        case 0x02: return "D"
        case 0x03: return "F"
        case 0x04: return "H"
        case 0x05: return "G"
        case 0x06: return "Z"
        case 0x07: return "X"
        case 0x08: return "C"
        case 0x09: return "V"
        case 0x0B: return "B"
        case 0x0C: return "Q"
        case 0x0D: return "W"
        case 0x0E: return "E"
        case 0x0F: return "R"
        case 0x10: return "Y"
        case 0x11: return "T"
        case 0x20: return "U"
        case 0x22: return "I"
        case 0x1F: return "O"
        case 0x23: return "P"
        case 0x25: return "L"
        case 0x26: return "J"
        case 0x28: return "K"
        case 0x29: return ";"
        case 0x27: return "'"
        case 0x2A: return "\\"
        case 0x2C: return "/"
        case 0x2E: return "N"
        case 0x2D: return "M"
        case 0x2B: return ","
        case 0x2F: return "."
        
        // ANSI Keyboard Numbers (kVK_ANSI_*)
        case 0x12: return "1"
        case 0x13: return "2" 
        case 0x14: return "3"
        case 0x15: return "4"
        case 0x17: return "5"
        case 0x16: return "6"
        case 0x1A: return "7"
        case 0x1C: return "8"
        case 0x19: return "9"
        case 0x1D: return "0"
        case 0x1B: return "-"
        case 0x18: return "="
        case 0x21: return "["
        case 0x1E: return "]"
        case 0x32: return "`"
        
        // Function and Control Keys
        case 0x24: return "⏎"      // Return (kVK_Return)
        case 0x30: return "⇥"      // Tab (kVK_Tab)
        case 0x31: return "Space"  // Space (kVK_Space)
        case 0x33: return "⌫"      // Delete (kVK_Delete)
        case 0x35: return "⎋"      // Escape (kVK_Escape)
        case 0x39: return "⇪"      // Caps Lock (kVK_CapsLock)
        
        // Function Keys (kVK_F1 - kVK_F20)
        case 0x7A: return "F1"
        case 0x78: return "F2"
        case 0x63: return "F3"
        case 0x76: return "F4"
        case 0x60: return "F5"
        case 0x61: return "F6"
        case 0x62: return "F7"
        case 0x64: return "F8"
        case 0x65: return "F9"
        case 0x6D: return "F10"
        case 0x67: return "F11"
        case 0x6F: return "F12"
        case 0x69: return "F13"
        case 0x6B: return "F14"
        case 0x71: return "F15"
        case 0x6A: return "F16"
        case 0x40: return "F17"
        case 0x4F: return "F18"
        case 0x50: return "F19"
        case 0x5A: return "F20"
        
        // Arrow Keys (kVK_*Arrow)
        case 0x7B: return "←"      // Left Arrow (kVK_LeftArrow)
        case 0x7C: return "→"      // Right Arrow (kVK_RightArrow)
        case 0x7D: return "↓"      // Down Arrow (kVK_DownArrow)
        case 0x7E: return "↑"      // Up Arrow (kVK_UpArrow)
        
        // Keypad Keys (kVK_ANSI_Keypad*)
        case 0x41: return "."      // Keypad Decimal (kVK_ANSI_KeypadDecimal)
        case 0x43: return "*"      // Keypad Multiply (kVK_ANSI_KeypadMultiply)
        case 0x45: return "+"      // Keypad Plus (kVK_ANSI_KeypadPlus)
        case 0x47: return "⌧"      // Keypad Clear (kVK_ANSI_KeypadClear)
        case 0x4B: return "/"      // Keypad Divide (kVK_ANSI_KeypadDivide)
        case 0x4C: return "⌤"      // Keypad Enter (kVK_ANSI_KeypadEnter)
        case 0x4E: return "-"      // Keypad Minus (kVK_ANSI_KeypadMinus)
        case 0x51: return "="      // Keypad Equals (kVK_ANSI_KeypadEquals)
        case 0x52: return "0"      // Keypad 0 (kVK_ANSI_Keypad0)
        case 0x53: return "1"      // Keypad 1 (kVK_ANSI_Keypad1)
        case 0x54: return "2"      // Keypad 2 (kVK_ANSI_Keypad2)
        case 0x55: return "3"      // Keypad 3 (kVK_ANSI_Keypad3)
        case 0x56: return "4"      // Keypad 4 (kVK_ANSI_Keypad4)
        case 0x57: return "5"      // Keypad 5 (kVK_ANSI_Keypad5)
        case 0x58: return "6"      // Keypad 6 (kVK_ANSI_Keypad6)
        case 0x59: return "7"      // Keypad 7 (kVK_ANSI_Keypad7)
        case 0x5B: return "8"      // Keypad 8 (kVK_ANSI_Keypad8)
        case 0x5C: return "9"      // Keypad 9 (kVK_ANSI_Keypad9)
        
        // Additional Control Keys
        case 0x72: return "Help"   // Help (kVK_Help)
        case 0x73: return "Home"   // Home (kVK_Home)
        case 0x74: return "PgUp"   // Page Up (kVK_PageUp)
        case 0x75: return "⌦"      // Forward Delete (kVK_ForwardDelete)
        case 0x77: return "End"    // End (kVK_End)
        case 0x79: return "PgDn"   // Page Down (kVK_PageDown)
        
        default: return "Key\(keyCode)"
        }
    }
    
    /// 修飾キーと仮想キーコードから表示名を生成
    /// 
    /// 注意: keyCodeは物理キーの位置を表し、Command/Shift/Option/Controlキー自体は
    /// modifiersビットフラグで管理される。例：⌘+V は modifiers=256, keyCode=0x09
    static func generateDisplayName(keyCode: Int16, modifiers: Int16) -> String {
        var displayName = ""
        
        // 修飾キーの順序: Control, Option, Shift, Command (macOS標準)
        if modifiers & Hotkey.ModifierKeys.control != 0 { displayName += "⌃" }   // Control
        if modifiers & Hotkey.ModifierKeys.option != 0 { displayName += "⌥" }    // Option
        if modifiers & Hotkey.ModifierKeys.shift != 0 { displayName += "⇧" }     // Shift
        if modifiers & Hotkey.ModifierKeys.command != 0 { displayName += "⌘" }   // Command
        
        // 物理キーの文字を追加
        displayName += keyCodeToChar(keyCode: keyCode)
        
        return displayName
    }
}
