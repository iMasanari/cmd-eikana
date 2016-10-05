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
    
    init(keyCode: CGKeyCode, flags: CGEventFlags = CGEventFlags()) {
        self.keyCode = keyCode
        self.flags = flags
        
        super.init()
    }
    init?(dictionary: [AnyHashable: Any]) {
        if let keyCodeInt = dictionary["keyCode"] as? Int, let eventFlagsInt = dictionary["flags"] as? Int {
            self.flags = CGEventFlags(rawValue: UInt64(eventFlagsInt))
            self.keyCode = CGKeyCode(keyCodeInt)
            
            super.init()
        } else {
            self.keyCode = 0
            self.flags = CGEventFlags(rawValue: UInt64(0))
            
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
        let flags = self.flags.rawValue
        
        if flags & CGEventFlags.maskCommand.rawValue != 0 && keyCode != 54 && keyCode != 55 {
            flagString += "⌘"
        }
        
        if flags & CGEventFlags.maskShift.rawValue != 0 && keyCode != 56 && keyCode != 60 {
            flagString += "⇧"
        }
        
        if flags & CGEventFlags.maskControl.rawValue != 0 && keyCode != 59 && keyCode != 62 {
            flagString += "⌃"
        }
        
        if flags & CGEventFlags.maskAlternate.rawValue != 0 && keyCode != 58 && keyCode != 61 {
            flagString += "⌥"
        }
        
        if flags & CGEventFlags.maskSecondaryFn.rawValue != 0 && keyCode != 63 {
            flagString += "fn"
        }
        // capslock ⇪
        
        return flagString + key!
    }
    
    func postEvent() -> Void {
        let loc = CGEventTapLocation.cghidEventTap
        let keyDownEvent = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: true)!
        let keyUpEvent = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: false)!
        
        keyDownEvent.flags = CGEventFlags(rawValue: keyDownEvent.flags.rawValue | flags.rawValue)
        keyUpEvent.flags = CGEventFlags()
        
        keyDownEvent.post(tap: loc)
        keyUpEvent.post(tap: loc)
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
    52: "ENTER_POWERBOOK",
    53: "⎋",
    54: "COMMAND_R",
    55: "COMMAND_L",
    56: "SHIFT_L",
    57: "CAPSLOCK",
    58: "OPTION_L",
    59: "CONTROL_L",
    60: "SHIFT_R",
    61: "OPTION_R",
    62: "CONTROL_R",
    63: "FN",
    64: "F17",
    65: "KEYPAD_DOT",
    67: "KEYPAD_MULTIPLY",
    69: "KEYPAD_PLUS",
    71: "KEYPAD_CLEAR",
    75: "KEYPAD_SLASH",
    76: "⌤",
    78: "KEYPAD_MINUS",
    79: "F18",
    80: "F19",
    81: "KEYPAD_EQUAL",
    82: "KEYPAD_0",
    83: "KEYPAD_1",
    84: "KEYPAD_2",
    85: "KEYPAD_3",
    86: "KEYPAD_4",
    87: "KEYPAD_5",
    88: "KEYPAD_6",
    89: "KEYPAD_7",
    91: "KEYPAD_8",
    92: "KEYPAD_9",
    93: "¥",
    94: "_",
    95: "KEYPAD_COMMA",
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
    114: "HELP",
    115: "↖",
    116: "PgUp",
    117: "⌦",
    118: "F4",
    119: "↘",
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
    131: "LAUNCHPAD",
    144: "BRIGHTNESS_UP",
    145: "BRIGHTNESS_DOWN",
    160: "EXPOSE_ALL"
]
