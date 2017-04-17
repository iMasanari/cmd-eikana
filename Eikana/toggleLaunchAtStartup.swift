//
//  toggleLaunchAtStartup.swift
//  ⌘英かな
//
//  MIT License
//  Copyright (c) 2016 iMasanari
//

// ログイン項目に追加、またはそこから削除するための関数

import Cocoa
import ServiceManagement

func setLaunchAtStartup(_ enabled: Bool) {
    let appBundleIdentifier = "io.github.imasanari.cmd-eikana-helper"
    
    if SMLoginItemSetEnabled(appBundleIdentifier as CFString, enabled) {
        if enabled {
            print("Successfully add login item.")
        } else {
            print("Successfully remove login item.")
        }
    } else {
        print("Failed to add login item.")
    }
}
