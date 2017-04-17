//
//  PreferenceWindowController.swift
//  ⌘英かな
//
//  MIT License
//  Copyright (c) 2016 iMasanari
//

import Cocoa

class PreferenceWindowController: NSWindowController, NSWindowDelegate {
    static func getInstance() -> PreferenceWindowController {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateController(withIdentifier: "Preference") as! PreferenceWindowController
        
        controller.window?.title = "Eikana"
        
        return controller
    }
    
    func showAndActivate(_ sender: AnyObject?) {
        self.showWindow(sender)
        self.window?.makeKeyAndOrderFront(sender)
        NSApp.activate(ignoringOtherApps: true)
    }
    override func mouseDown(with event: NSEvent) {
        activeKeyTextField?.blur()
    }
}
