//
//  MediaKeyEvent.swift
//  ⌘英かな
//
//  MIT License
//  Copyright (c) 2016 iMasanari
//

import Cocoa

class MediaKeyEvent: NSObject {
    let event: CGEvent
    let nsEvent: NSEvent
    
    var keyCode: Int
    var flags: CGEventFlags
    var keyDown: Bool
    
    init?(_ event: CGEvent) {
        if event.type.rawValue != UInt32(NX_SYSDEFINED) {
            return nil
        }
        
        if let nsEvent = NSEvent(cgEvent: event), nsEvent.subtype.rawValue == 8 {
            self.nsEvent = nsEvent
        }
        else {
            return nil
        }
        
        self.event = event
        keyCode = (nsEvent.data1 & 0xffff0000) >> 16
        flags = event.flags
        keyDown = ((nsEvent.data1 & 0xff00) >> 8) == 0xa
        
        super.init()
    }
}

let mediaKeyDic = [
    NX_KEYTYPE_SOUND_UP: "Sound_up",
    NX_KEYTYPE_SOUND_DOWN: "Sound_down",
    NX_KEYTYPE_BRIGHTNESS_UP: "Brightness_up",
    NX_KEYTYPE_BRIGHTNESS_DOWN: "Brightness_down",
    NX_KEYTYPE_CAPS_LOCK: "CapsLock",
    NX_KEYTYPE_HELP: "HELP",
    NX_POWER_KEY: "PowerKey",
    NX_KEYTYPE_MUTE: "mute",
    NX_KEYTYPE_NUM_LOCK: "NUM_LOCK",
    NX_KEYTYPE_CONTRAST_UP: "CONTRAST_UP",
    NX_KEYTYPE_CONTRAST_DOWN: "CONTRAST_DOWN",
    NX_KEYTYPE_LAUNCH_PANEL: "LAUNCH_PANEL",
    NX_KEYTYPE_EJECT: "EJECT",
    NX_KEYTYPE_VIDMIRROR: "VIDMIRROR",
    NX_KEYTYPE_PLAY: "Play",
    NX_KEYTYPE_NEXT: "NEXT",
    NX_KEYTYPE_PREVIOUS: "PREVIOUS",
    NX_KEYTYPE_FAST: "Fast",
    NX_KEYTYPE_REWIND: "Rewind",
    NX_KEYTYPE_ILLUMINATION_UP: "Illumination_up",
    NX_KEYTYPE_ILLUMINATION_DOWN: "Illumination_down",
    NX_KEYTYPE_ILLUMINATION_TOGGLE: "ILLUMINATION_TOGGLE"
]
