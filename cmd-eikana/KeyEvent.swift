//
//  KeyEvent.swift
//  ⌘英かな
//
//  MIT License
//  Copyright (c) 2016 iMasanari
//

// watchCGEventCallbackをクラスの中に入れ、CGEvent.tapCreateのcallbackに設定すると
// `A C function pointer can only be formed from a reference to a 'func' or a literal closure`
// エラーが出たため、watchCGEventCallback、keyCodeなどをクラスの外に

import Cocoa

var KeyEventKeyCode: Int64? = nil

class KeyEvent: NSObject {
    
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
        
        guard let eventTap = CGEvent.tapCreate(tap: .cgSessionEventTap,
                                               place: .headInsertEventTap,
                                               options: .defaultTap,
                                               eventsOfInterest: CGEventMask(eventMask),
                                               callback: KeyEventWatchCGEventCallback,
                                               userInfo: nil)
            else {
                print("failed to create event tap")
                exit(1)
        }
        
        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
        CFRunLoopRun()
    }
}

func inputCommandSpace() {
    print("前の入力ソースを選択")
    
    let loc = CGEventTapLocation.cghidEventTap
    let keyDownEvent = CGEvent(keyboardEventSource: nil, virtualKey: 0x31, keyDown: true)!
    let keyUpEvent = CGEvent(keyboardEventSource: nil, virtualKey: 0x31, keyDown: false)!
    
    keyDownEvent.flags = CGEventFlags.maskCommand
    keyUpEvent.flags = CGEventFlags(rawValue: 0)
    
    keyDownEvent.post(tap: loc)
    keyUpEvent.post(tap: loc)
}

func inputJisEisuuKey() {
    print("英数")
    
    let loc = CGEventTapLocation.cghidEventTap
    let keyDownEvent = CGEvent(keyboardEventSource: nil, virtualKey: 102, keyDown: true)!
    let keyUpEvent = CGEvent(keyboardEventSource: nil, virtualKey: 102, keyDown: false)!
    
    keyDownEvent.flags = CGEventFlags(rawValue: 0)
    keyUpEvent.flags = CGEventFlags(rawValue: 0)
    
    keyDownEvent.post(tap: loc)
    keyUpEvent.post(tap: loc)
}

func inputJisKanaKey() {
    print("かな")
    
    let loc = CGEventTapLocation.cghidEventTap
    let keyDownEvent = CGEvent(keyboardEventSource: nil, virtualKey: 104, keyDown: true)!
    let keyUpEvent = CGEvent(keyboardEventSource: nil, virtualKey: 104, keyDown: false)!
    
    keyDownEvent.flags = CGEventFlags(rawValue: 0)
    keyUpEvent.flags = CGEventFlags(rawValue: 0)
    
    keyDownEvent.post(tap: loc)
    keyUpEvent.post(tap: loc)
}

func KeyEventWatchCGEventCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
    if [.flagsChanged].contains(type) {
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        let flags = event.flags.rawValue
        
        if keyCode == 55 { // left command key
            if flags & CGEventFlags.maskCommand.rawValue != 0 {
                KeyEventKeyCode = keyCode
            }
            else if keyCode == KeyEventKeyCode {
                inputJisEisuuKey()
                // inputCommandSpace()
            }
        }
        else if keyCode == 54 { // right command key
            if flags & CGEventFlags.maskCommand.rawValue != 0 {
                KeyEventKeyCode = keyCode
            }
            else if keyCode == KeyEventKeyCode {
                inputJisKanaKey()
            }
        }
    }
    else {
        KeyEventKeyCode = nil
    }
    
    return Unmanaged.passRetained(event)
}

