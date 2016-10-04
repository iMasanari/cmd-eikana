//
//  KeyEvent.swift
//  ⌘英かな
//
//  MIT License
//  Copyright (c) 2016 iMasanari
//

import Cocoa

class KeyEvent: NSObject {
    var keyCode: CGKeyCode? = nil
    
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
        }
    }
    
    func watch() {
        let eventMaskList = [
            CGEventType.keyDown,
            CGEventType.keyUp,
            CGEventType.flagsChanged,
            CGEventType.leftMouseDown,
            CGEventType.leftMouseUp,
            CGEventType.rightMouseDown,
            CGEventType.rightMouseUp,
            CGEventType.otherMouseDown,
            CGEventType.otherMouseUp,
            CGEventType.scrollWheel,
            // CGEventType.MouseMovedMask,
        ]
        var eventMask: UInt32 = 0
        
        for mask in eventMaskList {
            eventMask |= (1 << mask.rawValue)
        }
        
        let observer = UnsafeMutableRawPointer(Unmanaged.passRetained(self).toOpaque())
        
        guard let eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: { (proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? in
                if let observer = refcon {
                    let mySelf = Unmanaged<KeyEvent>.fromOpaque(observer).takeUnretainedValue()
                    return mySelf.callback(proxy: proxy, type: type, event: event, refcon: nil)
                }
                return Unmanaged.passRetained(event)
            },
            userInfo: observer
        ) else {
                print("failed to create event tap")
                exit(1)
        }
        
        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
        CFRunLoopRun()
    }
    
    func callback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
        // if type == CGEventType.keyDown {print(KeyboardShortcut(event).toString())}
        
        if let textFeild = selectKeyTextField {
            self.keyCode = nil
            
            if type == CGEventType.keyDown {
                textFeild.textField.stringValue = KeyboardShortcut(event).toString()
                
                selectKeyTextField = (
                    textField: textFeild.textField,
                    KeyboardShortcut(keyCode: CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode)), flags: event.flags)
                )
                
                return nil
            }
        }
        
        if type == CGEventType.flagsChanged {
            let keyCode = CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode))
            
            if let shortcut = oneShotModifiers[keyCode] {
                if event.flags.rawValue & modifierMasks[keyCode]!.rawValue != 0 {
                    self.keyCode = keyCode
                }
                else if keyCode == self.keyCode {
                    shortcut.postEvent()
                }
            }
        }
        else {
            self.keyCode = nil
        }
        return Unmanaged.passRetained(event)
    }
}

