//
//  KeyboardShortcut.swift
//  ⌘英かな
//
//  MIT License
//  Copyright (c) 2016 iMasanari
//

import Cocoa

class KeyboardShortcut: NSObject {
    var keyCode: CGKeyCode
    var flags: CGEventFlags
    
    init(_ event: CGEvent) {
        self.keyCode = CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode))
        self.flags = event.flags
        
        super.init()
    }
    override init() {
        self.keyCode = 0
        self.flags = CGEventFlags(rawValue: 0)
        
        super.init()
    }
    
    init(keyCode: CGKeyCode, flags: CGEventFlags = CGEventFlags()) {
        self.keyCode = keyCode
        self.flags = flags
        
        super.init()
    }
    init?(dictionary: [AnyHashable: Any]) {
        if let keyCodeInt = dictionary["keyCode"] as? Int,
            let eventFlagsInt = dictionary["flags"] as? Int {
            
            self.flags = CGEventFlags(rawValue: UInt64(eventFlagsInt))
            self.keyCode = CGKeyCode(keyCodeInt)
            
            super.init()
        } else {
            self.keyCode = 0
            self.flags = CGEventFlags(rawValue: 0)
            
            super.init()
            return nil
        }
    }
    
    func toDictionary() -> [AnyHashable: Any] {
        return [
            "keyCode": Int(keyCode),
            "flags": Int(flags.rawValue)
        ]
    }
    
    func toString() -> String {
        let key = keyCodeDictionary[keyCode]
        
        if key == nil {
            return ""
        }
        
        var flagString = ""
        
        if isSecondaryFnDown() {
            flagString += "(fn)"
        }
        
        if isCapslockDown() {
            flagString += "⇪"
        }
        
        if isCommandDown() {
            flagString += "⌘"
        }
        
        if isShiftDown() {
            flagString += "⇧"
        }
        
        if isControlDown() {
            flagString += "⌃"
        }
        
        if isAlternateDown() {
            flagString += "⌥"
        }
        
        return flagString + key!
    }
    
    func isCommandDown() -> Bool {
        return self.flags.rawValue & CGEventFlags.maskCommand.rawValue != 0 && keyCode != 54 && keyCode != 55
    }
    
    func isShiftDown() -> Bool {
        return self.flags.rawValue & CGEventFlags.maskShift.rawValue != 0 && keyCode != 56 && keyCode != 60
    }
    
    func isControlDown() -> Bool {
        return self.flags.rawValue & CGEventFlags.maskControl.rawValue != 0 && keyCode != 59 && keyCode != 62
    }
    
    func isAlternateDown() -> Bool {
        return self.flags.rawValue & CGEventFlags.maskAlternate.rawValue != 0 && keyCode != 58 && keyCode != 61
    }
    
    func isSecondaryFnDown() -> Bool {
        return self.flags.rawValue & CGEventFlags.maskSecondaryFn.rawValue != 0 && keyCode != 63
    }
    
    func isCapslockDown() -> Bool {
        return self.flags.rawValue & CGEventFlags.maskAlphaShift.rawValue != 0 && keyCode != 57
    }
    
    func postEvent() -> Void {
        let loc = CGEventTapLocation.cghidEventTap
        
        let keyDownEvent = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: true)!
        let keyUpEvent = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: false)!
        
        keyDownEvent.flags = flags
        keyUpEvent.flags = CGEventFlags()
        
        keyDownEvent.post(tap: loc)
        keyUpEvent.post(tap: loc)
    }
    
    func isCover(_ shortcut: KeyboardShortcut) -> Bool {
        if shortcut.isCommandDown() && !self.isCommandDown() ||
            shortcut.isShiftDown() && !self.isShiftDown() ||
            shortcut.isControlDown() && !self.isControlDown() ||
            shortcut.isAlternateDown() && !self.isAlternateDown() ||
            shortcut.isSecondaryFnDown() && !self.isSecondaryFnDown() ||
            shortcut.isCapslockDown() && !self.isCapslockDown()
        {
            return false
        }
        
        return true
    }
}

let keyCodeDictionary: Dictionary<CGKeyCode, String> = [
    0: "A",
    1: "S",
    2: "D",
    3: "F",
    4: "H",
    5: "G",
    6: "Z",
    7: "X",
    8: "C",
    9: "V",
    10: "DANISH_DOLLAR",
    11: "B",
    12: "Q",
    13: "W",
    14: "E",
    15: "R",
    16: "Y",
    17: "T",
    18: "1",
    19: "2",
    20: "3",
    21: "4",
    22: "6",
    23: "5",
    24: "=",
    25: "9",
    26: "7",
    27: "-",
    28: "8",
    29: "0",
    30: "]",
    31: "O",
    32: "U",
    33: "[",
    34: "I",
    35: "P",
    36: "⏎",
    37: "L",
    38: "J",
    39: "'",
    40: "K",
    41: ";",
    42: "\\",
    43: ",",
    44: "/",
    45: "N",
    46: "M",
    47: ".",
    48: "⇥",
    49: "Space",
    50: "`",
    51: "⌫",
    52: "Enter_POWERBOOK",
    53: "⎋",
    54: "Command_R",
    55: "Command_L",
    56: "Shift_L",
    57: "CapsLock",
    58: "Option_L",
    59: "Control_L",
    60: "Shift_R",
    61: "Option_R",
    62: "Control_R",
    63: "Fn",
    64: "F17",
    65: "Keypad_Dot",
    67: "Keypad_Multiply",
    69: "Keypad_Plus",
    71: "Keypad_Clear",
    75: "Keypad_Slash",
    76: "⌤",
    78: "Keypad_Minus",
    79: "F18",
    80: "F19",
    81: "Keypad_Equal",
    82: "Keypad_0",
    83: "Keypad_1",
    84: "Keypad_2",
    85: "Keypad_3",
    86: "Keypad_4",
    87: "Keypad_5",
    88: "Keypad_6",
    89: "Keypad_7",
    90: "F20",
    91: "Keypad_8",
    92: "Keypad_9",
    93: "¥",
    94: "_",
    95: "Keypad_Comma",
    96: "F5",
    97: "F6",
    98: "F7",
    99: "F3",
    100: "F8",
    101: "F9",
    102: "英数",
    103: "F11",
    104: "かな",
    105: "F13",
    106: "F16",
    107: "F14",
    109: "F10",
    110: "App",
    111: "F12",
    113: "F15",
    114: "Help",
    115: "Home", // "↖",
    116: "PgUp",
    117: "⌦",
    118: "F4",
    119: "End", // "↘",
    120: "F2",
    121: "PgDn",
    122: "F1",
    123: "←",
    124: "→",
    125: "↓",
    126: "↑",
    127: "PC_POWER",
    128: "GERMAN_PC_LESS_THAN",
    130: "DASHBOARD",
    131: "Launchpad",
    144: "BRIGHTNESS_UP",
    145: "BRIGHTNESS_DOWN",
    160: "Expose_All",
    
    // media key (bata)
    999: "Disable",
    1000 + UInt16(NX_KEYTYPE_SOUND_UP): "Sound_up",
    1000 + UInt16(NX_KEYTYPE_SOUND_DOWN): "Sound_down",
    1000 + UInt16(NX_KEYTYPE_BRIGHTNESS_UP): "Brightness_up",
    1000 + UInt16(NX_KEYTYPE_BRIGHTNESS_DOWN): "Brightness_down",
    1000 + UInt16(NX_KEYTYPE_CAPS_LOCK): "CapsLock",
    1000 + UInt16(NX_KEYTYPE_HELP): "HELP",
    1000 + UInt16(NX_POWER_KEY): "PowerKey",
    1000 + UInt16(NX_KEYTYPE_MUTE): "mute",
    1000 + UInt16(NX_KEYTYPE_NUM_LOCK): "NUM_LOCK",
    1000 + UInt16(NX_KEYTYPE_CONTRAST_UP): "CONTRAST_UP",
    1000 + UInt16(NX_KEYTYPE_CONTRAST_DOWN): "CONTRAST_DOWN",
    1000 + UInt16(NX_KEYTYPE_LAUNCH_PANEL): "LAUNCH_PANEL",
    1000 + UInt16(NX_KEYTYPE_EJECT): "EJECT",
    1000 + UInt16(NX_KEYTYPE_VIDMIRROR): "VIDMIRROR",
    1000 + UInt16(NX_KEYTYPE_PLAY): "Play",
    1000 + UInt16(NX_KEYTYPE_NEXT): "NEXT",
    1000 + UInt16(NX_KEYTYPE_PREVIOUS): "PREVIOUS",
    1000 + UInt16(NX_KEYTYPE_FAST): "Fast",
    1000 + UInt16(NX_KEYTYPE_REWIND): "Rewind",
    1000 + UInt16(NX_KEYTYPE_ILLUMINATION_UP): "Illumination_up",
    1000 + UInt16(NX_KEYTYPE_ILLUMINATION_DOWN): "Illumination_down",
    1000 + UInt16(NX_KEYTYPE_ILLUMINATION_TOGGLE): "ILLUMINATION_TOGGLE"
]
