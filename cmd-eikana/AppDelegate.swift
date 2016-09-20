//
//  AppDelegate.swift
//  ⌘英かな
//
//  MIT License
//  Copyright (c) 2016 iMasanari
//

import Cocoa
//import ServiceManagement

var loginItem = NSMenuItem()

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var statusItem = NSStatusBar.system().statusItem(withLength: CGFloat(NSVariableStatusItemLength))
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        _ = KeyEvent()
        
        let menu = NSMenu()
        self.statusItem.title = "⌘"
        self.statusItem.highlightMode = true
        self.statusItem.menu = menu
        
        loginItem = menu.addItem(withTitle: "ログイン時に開く", action: #selector(AppDelegate.launch(_:)), keyEquivalent: "")
        loginItem.state = applicationIsInStartUpItems() ? 1 : 0
        
        menu.addItem(NSMenuItem.separator())
        
        menu.addItem(withTitle: "About ⌘英かな 1.0.1", action: #selector(AppDelegate.open(_:)), keyEquivalent: "")
        menu.addItem(withTitle: "Quit", action: #selector(AppDelegate.quit(_:)), keyEquivalent: "")
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @IBAction func open(_ sender: NSButton) {
        if let checkURL = URL(string: "https://ei-kana.appspot.com") {
            if NSWorkspace.shared().open(checkURL) {
                print("url successfully opened")
            }
        } else {
            print("invalid url")
        }
    }
    
    @IBAction func launch(_ sender: NSButton) {
        if sender.state == 0 {
            sender.state = 1
            addLaunchAtStartup()
        }
        else {
            sender.state = 0
            removeLaunchAtStartup()
        }
    }
    
    @IBAction func quit(_ sender: NSButton) {
        NSApplication.shared().terminate(self)
    }
}
