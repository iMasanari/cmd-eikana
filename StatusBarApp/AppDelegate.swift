//
//  AppDelegate.swift
//  ⌘英かな
//
//  Created by eikana on 2016/07/15.
//  Copyright © 2016年 eikana. All rights reserved.
//

import Cocoa
//import ServiceManagement

var loginItem = NSMenuItem()

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(CGFloat(NSVariableStatusItemLength))
    
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        _ = KeyEvent()
        
        let menu = NSMenu()
        self.statusItem.title = "⌘"
        self.statusItem.highlightMode = true
        self.statusItem.menu = menu
        
        loginItem = menu.addItemWithTitle("ログイン時に開く", action: #selector(AppDelegate.launch(_:)), keyEquivalent: "")!
        loginItem.state = applicationIsInStartUpItems() ? 1 : 0
        
        menu.addItem(NSMenuItem.separatorItem())
        
        menu.addItemWithTitle("About ⌘英かな 1.0.1", action: #selector(AppDelegate.open(_:)), keyEquivalent: "")
        menu.addItemWithTitle("Quit", action: #selector(AppDelegate.quit(_:)), keyEquivalent: "")
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    @IBAction func open(sender: NSButton) {
        if let checkURL = NSURL(string: "https://ei-kana.appspot.com") {
            if NSWorkspace.sharedWorkspace().openURL(checkURL) {
                print("url successfully opened")
            }
        } else {
            print("invalid url")
        }
    }
    
    @IBAction func launch(sender: NSButton) {
        if sender.state == 0 {
            sender.state = 1
            addLaunchAtStartup()
        }
        else {
            sender.state = 0
            removeLaunchAtStartup()
        }
    }
    
    @IBAction func quit(sender: NSButton) {
        NSApplication.sharedApplication().terminate(self)
    }
}
