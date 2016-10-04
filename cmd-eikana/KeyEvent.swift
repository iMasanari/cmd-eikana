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
    var isFlagsChanged = false
    
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
            
            self.watch()
        }
    }
    
    func watch() {
        /*
         watch modifier
         */
        NSEvent.addGlobalMonitorForEvents(matching: NSEventMask.flagsChanged, handler: flagsChangedCallback)
        NSEvent.addLocalMonitorForEvents(matching: NSEventMask.flagsChanged, handler: {(evevt: NSEvent!) -> NSEvent? in
            self.flagsChangedCallback(evevt)
            
            return (selectKeyTextField == nil) ? evevt : nil
        })
        
        /*
         watch another action
         */
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
                    return mySelf.anotherActionCallback(proxy: proxy, type: type, event: event, refcon: nil)
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
    
    func flagsChangedCallback(_ event: NSEvent!){
        if !isFlagsChanged {
            return
        }
        
        isFlagsChanged = false
        
        let keyCode = CGKeyCode(event.keyCode)
        
        if let shortcut = oneShotModifiers[keyCode] {
            if event.modifierFlags.contains(modifierMasks[keyCode]!) {
                self.keyCode = keyCode
            }
            else if keyCode == self.keyCode {
                shortcut.postEvent()
            }
        }
    }
    func anotherActionCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
        #if DEBUG
            if type == CGEventType.keyDown {print(KeyboardShortcut(event).toString())}
        #endif
        
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
            isFlagsChanged = true
        }
        else {
            self.keyCode = nil
        }
        return Unmanaged.passRetained(event)
    }
}

let modifierMasks: [CGKeyCode: NSEventModifierFlags] = [
    54: NSEventModifierFlags.command,
    55: NSEventModifierFlags.command,
    56: NSEventModifierFlags.shift,
    60: NSEventModifierFlags.shift,
    59: NSEventModifierFlags.control,
    62: NSEventModifierFlags.control,
    58: NSEventModifierFlags.option,
    61: NSEventModifierFlags.option,
    63: NSEventModifierFlags.function
]
