//
//  AppDelegate.swift
//  ⌘英かな
//
//  MIT License
//  Copyright (c) 2016 iMasanari
//

import Cocoa
import Sparkle

var statusItem = NSStatusBar.system().statusItem(withLength: CGFloat(NSVariableStatusItemLength))
var loginItem = NSMenuItem()

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var windowController : NSWindowController?
    var preferenceWindowController: PreferenceWindowController!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
//         resetUserDefault() // デバッグ用
        
        ////////////////////////////
        // 保存データの読み込み
        ////////////////////////////
        
        let userDefaults = UserDefaults.standard
        
        // 「ログイン後にこのアプリを起動」
        if userDefaults.object(forKey: "lunchAtStartup") == nil {
            setLaunchAtStartup(true)
            userDefaults.set(1, forKey: "lunchAtStartup")
        }
        
        // 「起動時にアップデートを確認」
        let checkUpdateState = userDefaults.object(forKey: "checkUpdateAtlaunch")
        let updater = SUUpdater.shared()!
        
        updater.feedURL = URL(string: "https://imasanari.github.io/cmd-eikana/appcast.xml")
        
        if checkUpdateState == nil {
            userDefaults.set(1, forKey: "checkUpdateAtlaunch")
            updater.checkForUpdatesInBackground()
        }
        else if checkUpdateState as! Int == 1 {
            updater.checkForUpdatesInBackground()
        }
        
        // 除外アプリ設定
        if let exclusionAppsListData = userDefaults.object(forKey: "exclusionApps") as? [[AnyHashable: Any]] {
            for val in exclusionAppsListData {
                if let exclusionApps = AppData(dictionary: val) {
                    exclusionAppsList.append(exclusionApps)
                }
            }
            
            for val in exclusionAppsList {
                exclusionAppsDict[val.id] = val.name
            }
        }
        
        // ショートカット設定
        if let keyMappingListData = userDefaults.object(forKey: "mappings") as? [[AnyHashable: Any]] {
            for val in keyMappingListData {
                if let mapping = KeyMapping(dictionary: val) {
                    keyMappingList.append(mapping)
                }
            }
            
            keyMappingListToShortcutList()
        }
        else {
            if let oneShotModifiersData = userDefaults.object(forKey: "oneShotModifiers") as? [AnyObject] {
                // v2.0.xからの引き継ぎ
                for val in oneShotModifiersData {
                    if let inputKeyCodeInt = val["input"] as? Int,
                        let outputDic = val["output"] as? [AnyHashable: Any],
                        let output = KeyboardShortcut(dictionary: outputDic)
                    {
                        keyMappingList.append(KeyMapping(input: KeyboardShortcut(keyCode: CGKeyCode(inputKeyCodeInt)),
                                                         output: output))
                    }
                }
                
                userDefaults.removeObject(forKey: "oneShotModifiers")
            }
            else {
                // 初期設定（左右のコマンドキー単体で英数/かな）
                keyMappingList = [
                    KeyMapping(input: KeyboardShortcut(keyCode: 55), output: KeyboardShortcut(keyCode: 102)),
                    KeyMapping(input: KeyboardShortcut(keyCode: 54), output: KeyboardShortcut(keyCode: 104))
                ]
            }
            
            saveKeyMappings()
            keyMappingListToShortcutList()
        }
        
        ////////////////////////////
        // UIの初期化
        ////////////////////////////
        
        preferenceWindowController = PreferenceWindowController.getInstance()
        // preferenceWindowController.showAndActivate(self)
        
        let menu = NSMenu()
        statusItem.title = "⌘"
        statusItem.highlightMode = true
        statusItem.menu = menu
        
//        loginItem = menu.addItem(withTitle: "ログイン時に開く", action: #selector(AppDelegate.launch(_:)), keyEquivalent: "")
//        loginItem.state = applicationIsInStartUpItems() ? 1 : 0
//        
//        menu.addItem(NSMenuItem.separator())
        
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        
        menu.addItem(withTitle: "About ⌘英かな \(version)", action: #selector(AppDelegate.open(_:)), keyEquivalent: "")
        menu.addItem(withTitle: "Preferences...", action: #selector(AppDelegate.openPreferencesSerector(_:)), keyEquivalent: "")
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Restart", action: #selector(AppDelegate.restart(_:)), keyEquivalent: "")
        menu.addItem(withTitle: "Quit", action: #selector(AppDelegate.quit(_:)), keyEquivalent: "")
        
        _ = KeyEvent()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationDidResignActive(_ notification: Notification) {
        activeKeyTextField?.blur()
    }
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        preferenceWindowController.showAndActivate(self)
        return false
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
        preferenceWindowController.showAndActivate(self)
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
    
    @IBAction func restart(_ sender: NSButton) {
        let url = URL(fileURLWithPath: Bundle.main.resourcePath!)
        let path = url.deletingLastPathComponent().deletingLastPathComponent().absoluteString
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = [path]
        task.launch()
        NSApplication.shared().terminate(self)
    }
    
    @IBAction func quit(_ sender: NSButton) {
        NSApplication.shared().terminate(self)
    }
}

