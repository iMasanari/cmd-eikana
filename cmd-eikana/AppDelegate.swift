//
//  AppDelegate.swift
//  ⌘英かな
//
//  MIT License
//  Copyright (c) 2016 iMasanari
//

import Cocoa

var statusItem = NSStatusBar.system().statusItem(withLength: CGFloat(NSVariableStatusItemLength))
var loginItem = NSMenuItem()

var oneShotModifiers: [CGKeyCode: KeyboardShortcut] = [:]

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var windowController : NSWindowController?
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
//        resetUserDefault() // デバッグ用
        
        let userDefaults = UserDefaults.standard
        
        if userDefaults.object(forKey: "lunchAtStartup") == nil {
            setLaunchAtStartup(true)
            userDefaults.set(1, forKey: "lunchAtStartup")
        }
        
        let checkUpdateState = userDefaults.object(forKey: "checkUpdateAtlaunch")
        
        if checkUpdateState == nil {
            userDefaults.set(1, forKey: "checkUpdateAtlaunch")
            checkUpdate()
        }
        else if checkUpdateState as! Int == 1 {
            checkUpdate()
        }
        
        if let oneShotModifiersData = userDefaults.object(forKey: "oneShotModifiers") {
            oneShotModifiers = [:]
            
            (oneShotModifiersData as! [AnyObject]).forEach({ (val) in
                let input = CGKeyCode(val["input"] as! Int)
                let output = KeyboardShortcut(dictionary: val["output"] as! [AnyHashable: Any])
                
                oneShotModifiers[input] = output
            })
            
        }
        else {
            oneShotModifiers = [
                55: KeyboardShortcut(keyCode: 102),
                54: KeyboardShortcut(keyCode: 104)
            ]
            
            saveKeyMappings()
        }
        
        let menu = NSMenu()
        statusItem.title = "⌘"
        statusItem.highlightMode = true
        statusItem.menu = menu
        
//        loginItem = menu.addItem(withTitle: "ログイン時に開く", action: #selector(AppDelegate.launch(_:)), keyEquivalent: "")
//        loginItem.state = applicationIsInStartUpItems() ? 1 : 0
//        
//        menu.addItem(NSMenuItem.separator())
        
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        
        menu.addItem(withTitle: "About ⌘英かな " + version, action: #selector(AppDelegate.open(_:)), keyEquivalent: "")
        menu.addItem(withTitle: "Preferences...", action: #selector(AppDelegate.openPreferencesSerector(_:)), keyEquivalent: "")
        menu.addItem(withTitle: "Quit", action: #selector(AppDelegate.quit(_:)), keyEquivalent: "")
        
        _ = KeyEvent()
        
//        openPreferences()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationDidResignActive(_ notification: Notification) {
        selectKeyTextField?.textField.window?.makeFirstResponder(nil)
        selectKeyTextField = nil
    }
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        openPreferences()
        return false
    }
    
    func openPreferences() {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateController(withIdentifier: "MainWindow") as? ViewController
        let window = NSWindow(contentViewController: vc!)
        
        window.makeKeyAndOrderFront(self)
        
        self.windowController = NSWindowController(window: window)
        self.windowController!.showWindow(self)
    }
    
    // 保存されたUserDefaultを全削除する。
    func resetUserDefault() {
        let appDomain:String = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: appDomain)
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
    @IBAction func openPreferencesSerector(_ sender: NSButton) {
        openPreferences()
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @IBAction func launch(_ sender: NSButton) {
        if sender.state == 0 {
            sender.state = 1
//            addLaunchAtStartup()
        }
        else {
            sender.state = 0
//            removeLaunchAtStartup()
        }
    }
    
    @IBAction func quit(_ sender: NSButton) {
        NSApplication.shared().terminate(self)
    }
}

func saveKeyMappings() {
    UserDefaults.standard.set(oneShotModifiers.map {[
        "input": Int($0.0),
        "output": $0.1.toDictionary()
        ]} , forKey: "oneShotModifiers")
}
