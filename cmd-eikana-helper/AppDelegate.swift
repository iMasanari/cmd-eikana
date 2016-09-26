//
//  AppDelegate.swift
//  cmd-eikana-helper
//
//  Created by 岩田将成 on 2016/09/26.
//  Copyright © 2016年 eikana. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Check whether the main application is running and active
        var running = false
        var active = false
        let applications = NSRunningApplication.runningApplications(withBundleIdentifier: "io.github.imasanari.cmd-eikana")
        
        if applications.count > 0 {
            let application = applications.first!
            running = true
            active = application.isActive
        }
        if !running && !active {
            // Launch main application
            let applicationURL = URL(string: "io.github.imasanari.cmd-eikana://")!
            NSWorkspace.shared().open(applicationURL)
        }
        // Quit
        NSApplication.shared().terminate(self)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

