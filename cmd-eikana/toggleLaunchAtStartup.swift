//
//  toggleLaunchAtStartup.swift
//  ⌘英かな
//
//  MIT License
//  Copyright (c) 2016 iMasanari
//

// ログイン項目に追加、またはそこから削除するための関数

// LSSharedFileListCreateなどが非推奨で、長くはサポートしないらしいが
// KarabinerがSierra対応するまでは大丈夫だろうと思い採用
// 時間あるときに他の方法に直す予定

import Cocoa

func applicationIsInStartUpItems() -> Bool {
    return (itemReferencesInLoginItems().existingReference != nil)
}

func itemReferencesInLoginItems() -> (existingReference: LSSharedFileListItem?, lastReference: LSSharedFileListItem?) {
    let itemUrl : UnsafeMutablePointer<Unmanaged<CFURL>?> = UnsafeMutablePointer<Unmanaged<CFURL>?>.allocate(capacity: 1)
    
    if let appUrl : URL = URL(fileURLWithPath: Bundle.main.bundlePath) {
        let loginItemsRef = LSSharedFileListCreate(
            nil,
            kLSSharedFileListSessionLoginItems.takeRetainedValue(),
            nil
            ).takeRetainedValue() as LSSharedFileList?
        
        if loginItemsRef != nil {
            let loginItems: NSArray = LSSharedFileListCopySnapshot(loginItemsRef, nil).takeRetainedValue() as NSArray
            // print("There are \(loginItems.count) login items")
            let lastItemRef: LSSharedFileListItem = loginItems.lastObject as! LSSharedFileListItem
            
            for i in 0 ..< loginItems.count {
                let currentItemRef: LSSharedFileListItem = loginItems.object(at: i) as! LSSharedFileListItem
                if LSSharedFileListItemResolve(currentItemRef, 0, itemUrl, nil) == noErr {
                    if let urlRef: URL =  itemUrl.pointee?.takeRetainedValue() as URL? {
                        // print("URL Ref: \(urlRef.lastPathComponent)")
                        if urlRef == appUrl {
                            return (currentItemRef, lastItemRef)
                        }
                    }
                } else {
                    print("Unknown login application")
                }
            }
            //The application was not found in the startup list
            return (nil, lastItemRef)
        }
    }
    return (nil, nil)
}

func addLaunchAtStartup() {
    let itemReferences = itemReferencesInLoginItems()
    let loginItemsRef = LSSharedFileListCreate(
        nil,
        kLSSharedFileListSessionLoginItems.takeRetainedValue(),
        nil
        ).takeRetainedValue() as LSSharedFileList?
    
    
    if let appUrl : CFURL = URL(fileURLWithPath: Bundle.main.bundlePath) as CFURL? {
        LSSharedFileListInsertItemURL(
            loginItemsRef,
            itemReferences.lastReference,
            nil,
            nil,
            appUrl,
            nil,
            nil
        )
        print("Application was added to login items")
    }
}


func removeLaunchAtStartup() {
    let itemReferences = itemReferencesInLoginItems()
    let loginItemsRef = LSSharedFileListCreate(
        nil,
        kLSSharedFileListSessionLoginItems.takeRetainedValue(),
        nil
        ).takeRetainedValue() as LSSharedFileList?
    
    if let itemRef = itemReferences.existingReference {
        LSSharedFileListItemRemove(loginItemsRef,itemRef);
        print("Application was removed from login items")
    }
}
