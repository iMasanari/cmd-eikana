//
//  KeyEvent.swift
//  ⌘英かな
//
//  MIT License
//  Copyright (c) 2016 iMasanari
//

// myCGEventCallbackをクラスの中に入れ、CGEvent.tapCreateのcallbackに設定すると
// `A C function pointer can only be formed from a reference to a 'func' or a literal closure`
// エラーが出たため、myCGEventCallback、keyCodeなどをクラスの外に

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
    
    func inputJisEisuuKey() {
        print("英数")
        
        let loc = CGEventTapLocation.cghidEventTap
        
        CGEvent(keyboardEventSource: nil, virtualKey: 102, keyDown: true)?.post(tap: loc)
        CGEvent(keyboardEventSource: nil, virtualKey: 102, keyDown: false)?.post(tap: loc)
    }
    
    func inputJisKanaKey() {
        print("かな")
        
        let loc = CGEventTapLocation.cghidEventTap
        
        CGEvent(keyboardEventSource: nil, virtualKey: 104, keyDown: true)?.post(tap: loc)
        CGEvent(keyboardEventSource: nil, virtualKey: 104, keyDown: false)?.post(tap: loc)
    }
    
    func watch() {
        /////////////////////////////////////////
        // To monitor the command key
        /////////////////////////////////////////
        
        let flagsChangedHandler = {(evevt: NSEvent!) -> Void in
            if evevt.keyCode == 55 { // left command key
                if evevt.modifierFlags.contains(.command) {
                    KeyEventKeyCode = 55
                }
                else if KeyEventKeyCode == 55 {
                    self.inputJisEisuuKey()
                }
            }
            else if evevt.keyCode == 54 { // right command key
                if evevt.modifierFlags.contains(.command) {
                    KeyEventKeyCode = 54
                }
                else if KeyEventKeyCode == 54 {
                    self.inputJisKanaKey()
                }
            }
            else {
                KeyEventKeyCode = nil
            }
        }
        
        NSEvent.addGlobalMonitorForEvents(matching: NSEventMask.flagsChanged, handler: flagsChangedHandler)
        NSEvent.addLocalMonitorForEvents(matching: NSEventMask.flagsChanged, handler: {(evevt: NSEvent!) -> NSEvent? in
            flagsChangedHandler(evevt)
            return evevt
        })
        
        /////////////////////////////////////////
        // To monitor the another action
        /////////////////////////////////////////
        
        let eventMaskList = [
            CGEventType.keyDown,
            CGEventType.keyUp,
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
                                               callback: watchAnotherActionCallback,
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

func watchAnotherActionCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
    KeyEventKeyCode = nil
    
    return Unmanaged.passRetained(event)
}
