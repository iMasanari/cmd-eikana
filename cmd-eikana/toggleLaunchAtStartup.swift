//
//  toggleLaunchAtStartup.swift
//  ⌘英かな
//
//  Created by eikana on 2016/07/17.
//  Copyright © 2016年 eikana. All rights reserved.
//

// ログイン項目に追加、またはそこから削除するための関数

// LSSharedFileListCreateなどが非推奨で、長くはサポートしないらしいが
// KarabinerがSierra対応するまでは大丈夫だろうと思い採用
// 時間あるときに他の方法に直す予定

import Cocoa

func applicationIsInStartUpItems() -> Bool {
    return (itemReferencesInLoginItems().existingReference != nil)
}

func itemReferencesInLoginItems() -> (existingReference: LSSharedFileListItemRef?, lastReference: LSSharedFileListItemRef?) {
    let itemUrl : UnsafeMutablePointer<Unmanaged<CFURL>?> = UnsafeMutablePointer<Unmanaged<CFURL>?>.alloc(1)
    
    if let appUrl : NSURL = NSURL.fileURLWithPath(NSBundle.mainBundle().bundlePath) {
        let loginItemsRef = LSSharedFileListCreate(
            nil,
            kLSSharedFileListSessionLoginItems.takeRetainedValue(),
            nil
            ).takeRetainedValue() as LSSharedFileListRef?
        
        if loginItemsRef != nil {
            let loginItems: NSArray = LSSharedFileListCopySnapshot(loginItemsRef, nil).takeRetainedValue() as NSArray
            // print("There are \(loginItems.count) login items")
            let lastItemRef: LSSharedFileListItemRef = loginItems.lastObject as! LSSharedFileListItemRef
            
            for i in 0 ..< loginItems.count {
                let currentItemRef: LSSharedFileListItemRef = loginItems.objectAtIndex(i) as! LSSharedFileListItemRef
                if LSSharedFileListItemResolve(currentItemRef, 0, itemUrl, nil) == noErr {
                    if let urlRef: NSURL =  itemUrl.memory?.takeRetainedValue() {
                        // print("URL Ref: \(urlRef.lastPathComponent)")
                        if urlRef.isEqual(appUrl) {
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
        ).takeRetainedValue() as LSSharedFileListRef?
    
    
    if let appUrl : CFURLRef = NSURL.fileURLWithPath(NSBundle.mainBundle().bundlePath) {
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
        ).takeRetainedValue() as LSSharedFileListRef?
    
    if let itemRef = itemReferences.existingReference {
        LSSharedFileListItemRemove(loginItemsRef,itemRef);
        print("Application was removed from login items")
    }
}
