//
//  KeyEvent.swift
//  ⌘英かな
//
//  MIT License
//  Copyright (c) 2016 iMasanari
//

import Cocoa

var activeAppsList: [AppData] = []
var exclusionAppsList: [AppData] = []

var exclusionAppsDict: [String: String] = [:]

class KeyEvent: NSObject {
    var keyCode: CGKeyCode? = nil
    var isExclusionApp = false
    let bundleId = Bundle.main.infoDictionary?["CFBundleIdentifier"] as! String
    
    override init() {
        super.init()
        
        NSWorkspace.shared().notificationCenter.addObserver(self,
                                                            selector: #selector(KeyEvent.setActiveApp(_:)),
                                                            name: NSNotification.Name.NSWorkspaceDidActivateApplication,
                                                            object:nil)
        
        let checkOptionPrompt = kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString
        let options: CFDictionary = [checkOptionPrompt: true] as NSDictionary
        
        if !AXIsProcessTrustedWithOptions(options) {
            // アクセシビリティに設定されていない場合、設定されるまでループで待つ
            Timer.scheduledTimer(timeInterval: 1.0,
                                 target: self,
                                 selector: #selector(KeyEvent.watchAXIsProcess(_:)),
                                 userInfo: nil,
                                 repeats: true)
        }
        else {
            self.watch()
        }
    }
    
    func watchAXIsProcess(_ timer: Timer) {
        if AXIsProcessTrusted() {
            timer.invalidate()
            
            self.watch()
        }
    }
    
    func setActiveApp(_ notification: NSNotification) {
        let app = notification.userInfo!["NSWorkspaceApplicationKey"] as! NSRunningApplication
        
        if let name = app.localizedName, let id = app.bundleIdentifier {
            isExclusionApp = exclusionAppsDict[id] != nil
            
            if (id != bundleId && !isExclusionApp) {
                activeAppsList = activeAppsList.filter {$0.id != id}
                activeAppsList.insert(AppData(name: name, id: id), at: 0)
                
                if activeAppsList.count > 10 {
                    activeAppsList.removeLast()
                }
            }
        }
    }
    
    func watch() {
        let eventMaskList = [
            CGEventType.keyDown.rawValue,
            CGEventType.keyUp.rawValue,
            CGEventType.flagsChanged.rawValue,
            CGEventType.leftMouseDown.rawValue,
            CGEventType.leftMouseUp.rawValue,
            CGEventType.rightMouseDown.rawValue,
            CGEventType.rightMouseUp.rawValue,
            CGEventType.otherMouseDown.rawValue,
            CGEventType.otherMouseUp.rawValue,
            CGEventType.scrollWheel.rawValue,
            UInt32(NX_SYSDEFINED) // Media key Event
        ]
        var eventMask: UInt32 = 0
        
        for mask in eventMaskList {
            eventMask |= (1 << mask)
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
                    return mySelf.eventCallback(proxy: proxy, type: type, event: event)
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
    
    func eventCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        if isExclusionApp {
            return Unmanaged.passRetained(event)
        }
        
        if let mediaKeyEvent = MediaKeyEvent(event) {
            return mediaKeyEvent.keyDown ? mediaKeyDown(mediaKeyEvent) : mediaKeyUp(mediaKeyEvent)
        }
        
        switch type {
        case CGEventType.flagsChanged:
            let keyCode = CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode))
            
            if modifierMasks[keyCode] == nil {
                return Unmanaged.passRetained(event)
            }
            return event.flags.rawValue & modifierMasks[keyCode]!.rawValue != 0 ?
                modifierKeyDown(event) : modifierKeyUp(event)
        
        case CGEventType.keyDown:
            return keyDown(event)
        
        case CGEventType.keyUp:
            return keyUp(event)
        
        default:
            self.keyCode = nil
            
            return Unmanaged.passRetained(event)
        }
    }
    
    func keyDown(_ event: CGEvent) -> Unmanaged<CGEvent>? {
        #if DEBUG
            // print("keyCode: \(KeyboardShortcut(event).keyCode)")
             print(KeyboardShortcut(event).toString())
        #endif
        
        self.keyCode = nil
        
        if let keyTextField = activeKeyTextField {
            keyTextField.shortcut = KeyboardShortcut(event)
            keyTextField.stringValue = keyTextField.shortcut!.toString()
            
            return nil
        }
        
        if let event = getConvertedEvent(event) {
            return Unmanaged.passRetained(event)
        }
        
        return Unmanaged.passRetained(event)
    }
    
    func keyUp(_ event: CGEvent) -> Unmanaged<CGEvent>? {
        self.keyCode = nil
        
        if let event = getConvertedEvent(event) {
            return Unmanaged.passRetained(event)
        }
        
        return Unmanaged.passRetained(event)
    }
    
    func modifierKeyDown(_ event: CGEvent) -> Unmanaged<CGEvent>? {
        #if DEBUG
            print(KeyboardShortcut(event).toString())
        #endif

        self.keyCode = CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode))
        
        if let keyTextField = activeKeyTextField, keyTextField.isAllowModifierOnly {
            let shortcut = KeyboardShortcut(event)
            
            keyTextField.shortcut = shortcut
            keyTextField.stringValue = shortcut.toString()
        }
        
        return Unmanaged.passRetained(event)
    }
    
    func modifierKeyUp(_ event: CGEvent) -> Unmanaged<CGEvent>? {
        if activeKeyTextField != nil {
            self.keyCode = nil
        }
        else if self.keyCode == CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode)) {
            if let convertedEvent = getConvertedEvent(event) {
                KeyboardShortcut(convertedEvent).postEvent()
            }
        }
        
        self.keyCode = nil
        
        return Unmanaged.passRetained(event)
    }
    
    func mediaKeyDown(_ mediaKeyEvent: MediaKeyEvent) -> Unmanaged<CGEvent>? {
        #if DEBUG
            print(KeyboardShortcut(keyCode: CGKeyCode(1000 + Int(mediaKeyEvent.keyCode)),
                                flags: CGEventFlags(rawValue: UInt64(mediaKeyEvent.flags))).toString())
        #endif
        
        self.keyCode = nil
        
        if let keyTextField = activeKeyTextField {
            if keyTextField.isAllowModifierOnly {
                keyTextField.shortcut = KeyboardShortcut(keyCode: CGKeyCode(1000 + Int(mediaKeyEvent.keyCode)),
                                                         flags: CGEventFlags(rawValue: UInt64(mediaKeyEvent.flags)))
                keyTextField.stringValue = keyTextField.shortcut!.toString()
            }
            
            return nil
        }
        
        if let event = getConvertedEvent(mediaKeyEvent.event, keyCode: CGKeyCode(1000 + Int(mediaKeyEvent.keyCode)), keyDown: true) {
            event.post(tap: CGEventTapLocation.cghidEventTap)
            return nil
        }
        
        return Unmanaged.passRetained(mediaKeyEvent.event)
    }
    func mediaKeyUp(_ mediaKeyEvent: MediaKeyEvent) -> Unmanaged<CGEvent>? {
        
        if let event = getConvertedEvent(mediaKeyEvent.event, keyCode: CGKeyCode(1000 + Int(mediaKeyEvent.keyCode)), keyDown: false) {
            event.post(tap: CGEventTapLocation.cghidEventTap)
            return nil
        }
        
        return Unmanaged.passRetained(mediaKeyEvent.event)
    }
    
    func getConvertedEvent(_ event: CGEvent, keyCode: CGKeyCode? = nil, keyDown: Bool = false) -> CGEvent? {
        let event = event.type.rawValue == UInt32(NX_SYSDEFINED) ?
            CGEvent(keyboardEventSource: nil, virtualKey: 0, keyDown: keyDown)! : event.copy()!
        
        let shortcht = KeyboardShortcut(event)
        
        if let mappingList = shortcutList[keyCode ?? shortcht.keyCode] {
            for mappings in mappingList {
                if shortcht.isCover(mappings.input) {
                    event.setIntegerValueField(.keyboardEventKeycode, value: Int64(mappings.output.keyCode))
                    event.flags = CGEventFlags(
                        rawValue: (event.flags.rawValue & ~mappings.input.flags.rawValue) | mappings.output.flags.rawValue
                    )
                    
                    return event
                }
            }
        }
        return nil
    }
}

let modifierMasks: [CGKeyCode: CGEventFlags] = [
    54: CGEventFlags.maskCommand,
    55: CGEventFlags.maskCommand,
    56: CGEventFlags.maskShift,
    60: CGEventFlags.maskShift,
    59: CGEventFlags.maskControl,
    62: CGEventFlags.maskControl,
    58: CGEventFlags.maskAlternate,
    61: CGEventFlags.maskAlternate,
    63: CGEventFlags.maskSecondaryFn,
    57: CGEventFlags.maskAlphaShift
]
