//
//  KeyEvent.swift
//  ⌘英かな
//
//  MIT License
//  Copyright (c) 2016 iMasanari
//

import Cocoa

let singleModifierKeyUpActions: [Int64: () -> Void] = [
    55 /* left command */: postKeyboardEvent(102 /* jis-eisuu */),
    54 /* right command */: postKeyboardEvent(104 /* jis-kana */),
    // 59 /* left control */: postKeyboardEvent(49 /* space */, flags: CGEventFlags.maskCommand)
]

class KeyEvent: NSObject {
    var keyCode: Int64? = nil
    
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
        if [.flagsChanged].contains(type) {
            let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
            
            if let action = singleModifierKeyUpActions[keyCode] {
                if event.flags.rawValue & modifierMasks[keyCode]!.rawValue != 0 {
                    self.keyCode = keyCode
                }
                else if keyCode == self.keyCode {
                    action()
                }
            }
        }
        else {
            self.keyCode = nil
        }
        
        return Unmanaged.passRetained(event)
    }
}

let modifierMasks: [Int64: CGEventFlags] = [
    54: CGEventFlags.maskCommand,
    55: CGEventFlags.maskCommand,
    56: CGEventFlags.maskShift,
    60: CGEventFlags.maskShift,
    59: CGEventFlags.maskControl,
    62: CGEventFlags.maskControl,
    58: CGEventFlags.maskAlternate,
    61: CGEventFlags.maskAlternate,
    63: CGEventFlags.maskSecondaryFn
]

func postKeyboardEvent(_ virtualKey: CGKeyCode, flags: CGEventFlags = CGEventFlags()) -> () -> Void {
    let loc = CGEventTapLocation.cghidEventTap
    let keyDownEvent = CGEvent(keyboardEventSource: nil, virtualKey: virtualKey, keyDown: true)!
    let keyUpEvent = CGEvent(keyboardEventSource: nil, virtualKey: virtualKey, keyDown: false)!
    
    keyDownEvent.flags = flags
    keyUpEvent.flags = CGEventFlags()
    
    return { () -> Void in
        keyDownEvent.post(tap: loc)
        keyUpEvent.post(tap: loc)
    }
}
