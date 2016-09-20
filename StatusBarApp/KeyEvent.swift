//
//  KeyEvent.swift
//  ⌘英かな
//
//  Created by eikana on 2016/07/18.
//  Copyright © 2016年 eikana. All rights reserved.
//

import Cocoa

class KeyEvent: NSObject {
    var keyCode: UInt16? = nil
    
    override init() {
        super.init()
        
        let checkOptionPrompt = kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString
        let options: CFDictionary = [checkOptionPrompt: true]
        
        if !AXIsProcessTrustedWithOptions(options) {
            // アクセシビリティに設定されていない場合、設定されるまでループで待つ
            NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(KeyEvent.watchAXIsProcess(_:)), userInfo: nil, repeats: true)
            
        } else {
            self.watch()
        }
    }
    
    func watchAXIsProcess(timer: NSTimer) {
        if AXIsProcessTrusted() {
            timer.invalidate()
            print("アクセシビリティに設定されました")
            
            self.watch()
            
            addLaunchAtStartup()
            loginItem.state = 1
        }
    }
    
    func watch () {
        let masks = [
            NSEventMask.KeyDownMask,
            NSEventMask.KeyUpMask,
            NSEventMask.LeftMouseDownMask,
            NSEventMask.LeftMouseUpMask,
            NSEventMask.RightMouseDownMask,
            NSEventMask.RightMouseUpMask,
            NSEventMask.OtherMouseDownMask,
            NSEventMask.OtherMouseUpMask,
            NSEventMask.ScrollWheelMask
            // NSEventMask.MouseMovedMask,
        ]
        let handler = {(evt: NSEvent!) -> Void in
            self.keyCode = nil
        }
        
        for mask in masks {
            NSEvent.addGlobalMonitorForEventsMatchingMask(mask, handler: handler)
        }
        
        NSEvent.addGlobalMonitorForEventsMatchingMask(NSEventMask.FlagsChangedMask, handler: {(evevt: NSEvent!) -> Void in
            if evevt.keyCode == 55 { // 右コマンドキー
                if evevt.modifierFlags.contains(.CommandKeyMask) {
                    self.keyCode = 55
                }
                else if self.keyCode == 55 {
                    print("英数")
                    
                    let loc = CGEventTapLocation.CGHIDEventTap
                    
                    CGEventPost(loc, CGEventCreateKeyboardEvent(nil, 102, true))
                    CGEventPost(loc, CGEventCreateKeyboardEvent(nil, 102, false))
                }
            }
            else if evevt.keyCode == 54 { // 左コマンドキー
                if evevt.modifierFlags.contains(.CommandKeyMask) {
                    self.keyCode = 54
                }
                else if self.keyCode == 54 {
                    print("かな")
                    
                    let loc = CGEventTapLocation.CGHIDEventTap
                    
                    CGEventPost(loc, CGEventCreateKeyboardEvent(nil, 104, true))
                    CGEventPost(loc, CGEventCreateKeyboardEvent(nil, 104, false))
                }
            }
            else {
                self.keyCode = nil
            }
        })
        
    }
}
