//
//  KeyEvent.swift
//  ⌘英かな
//
//  MIT License
//  Copyright (c) 2016 iMasanari
//

import Cocoa

class KeyEvent: NSObject {
    var keyCode: UInt16? = nil
    
    override init() {
        super.init()
        
        let checkOptionPrompt = kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString
        let options: CFDictionary = [checkOptionPrompt: true] as NSDictionary
        
        if !AXIsProcessTrustedWithOptions(options) {
            // アクセシビリティに設定されていない場合、設定されるまでループで待つ
            Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(KeyEvent.watchAXIsProcess(_:)), userInfo: nil, repeats: true)
            
        } else {
            self.watch()
        }
    }
    
    func watchAXIsProcess(_ timer: Timer) {
        if AXIsProcessTrusted() {
            timer.invalidate()
            print("アクセシビリティに設定されました")
            
            self.watch()
            
//            addLaunchAtStartup()
            loginItem.state = 1
        }
    }
    
    func watch () {
        let masks = [
            NSEventMask.keyDown,
            NSEventMask.keyUp,
            NSEventMask.leftMouseDown,
            NSEventMask.leftMouseUp,
            NSEventMask.rightMouseDown,
            NSEventMask.rightMouseUp,
            NSEventMask.otherMouseDown,
            NSEventMask.otherMouseUp,
            NSEventMask.scrollWheel
            // NSEventMask.MouseMovedMask,
        ]
        let handler = {(evt: NSEvent!) -> Void in
            self.keyCode = nil
        }
        
        for mask in masks {
            NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler)
        }
        
        NSEvent.addGlobalMonitorForEvents(matching: NSEventMask.flagsChanged, handler: {(evevt: NSEvent!) -> Void in
            if evevt.keyCode == 55 { // 右コマンドキー
                if evevt.modifierFlags.contains(.command) {
                    self.keyCode = 55
                }
                else if self.keyCode == 55 {
                    print("英数")
                    
                    let loc = CGEventTapLocation.cghidEventTap
                    
                    CGEvent(keyboardEventSource: nil, virtualKey: 102, keyDown: true)?.post(tap: loc)
                    CGEvent(keyboardEventSource: nil, virtualKey: 102, keyDown: false)?.post(tap: loc)
                }
            }
            else if evevt.keyCode == 54 { // 左コマンドキー
                if evevt.modifierFlags.contains(.command) {
                    self.keyCode = 54
                }
                else if self.keyCode == 54 {
                    print("かな")
                    
                    let loc = CGEventTapLocation.cghidEventTap
                    
                    CGEvent(keyboardEventSource: nil, virtualKey: 104, keyDown: true)?.post(tap: loc)
                    CGEvent(keyboardEventSource: nil, virtualKey: 104, keyDown: false)?.post(tap: loc)
                }
            }
            else {
                self.keyCode = nil
            }
        })
        
    }
}
