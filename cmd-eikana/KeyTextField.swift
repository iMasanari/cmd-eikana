//
//  KeyTextField.swift
//  ⌘英かな
//
//  MIT License
//  Copyright (c) 2016 iMasanari
//

import Cocoa

class KeyTextField: NSComboBox {
    /// Custom delegate with other methods than NSTextFieldDelegate.
    
    override func becomeFirstResponder() -> Bool {
        let became = super.becomeFirstResponder();
        if (became) {
            if let shortcut = oneShotModifiers[tableDataIndex[self.identifier!]!] {
                selectKeyTextField = (textField: self, shortcut)
            }
            else {
                selectKeyTextField = (textField: self, key: nil)
            }
        }
        return became;
    }
    
//    override func resignFirstResponder() -> Bool {
//        let resigned = super.resignFirstResponder();
//        if (resigned) {
//        }
//        return resigned;
//    }
    
    override func textDidEndEditing(_ obj: Notification) {
        super.textDidEndEditing(obj)
        
        switch self.stringValue {
            case "（削除）":
                self.stringValue = ""
                
                if selectKeyTextField != nil {
                    selectKeyTextField!.key = nil
                    // selectKeyTextField!.key = KeyboardShortcut(keyCode: 57)
                }
                break
            case "JIS_EISUU":
                selectKeyTextField = (textField: self, KeyboardShortcut(keyCode: 102))
                break
            case "JIS_KANA":
                selectKeyTextField = (textField: self, KeyboardShortcut(keyCode: 104))
                break
            case "⌘SPACE":
                selectKeyTextField = (textField: self, KeyboardShortcut(keyCode: 49, flags: CGEventFlags.maskCommand))
                break
            case "⌃SPACE":
                selectKeyTextField = (textField: self, KeyboardShortcut(keyCode: 49, flags: CGEventFlags.maskControl))
                break
            default:
                break
        }
        
        let key = tableDataIndex[self.identifier!]!
        
        if let shortcut = selectKeyTextField?.key {
            self.stringValue = shortcut.toString()
            oneShotModifiers[key] = shortcut
        }
        else {
            oneShotModifiers.removeValue(forKey: key)
        }
        
        saveKeyMappings()
        
        if selectKeyTextField?.textField.identifier == self.identifier {
            selectKeyTextField = nil
        }
    }
}
