//
//  ExclusionAppsController.swift
//  ⌘英かな
//
//  MIT License
//  Copyright (c) 2016 iMasanari
//

import Cocoa

class ExclusionAppsController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet weak var tableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(ExclusionAppsController.tableReload),
                                               name: NSApplication.didBecomeActiveNotification,
                                               object: nil)
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return exclusionAppsList.count + activeAppsList.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        let id = tableColumn!.identifier
        
        let isExclusion =  row < exclusionAppsList.count
        
        if id.rawValue == "checkbox" {
            return isExclusion
        }
        
        let value = isExclusion ? exclusionAppsList[row] : activeAppsList[row - exclusionAppsList.count]
        
        if id.rawValue == "appName" {
            return value.name
        }
        if id.rawValue == "appId" {
            return value.id
        }
        
        return nil
    }
    func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        let id = tableColumn!.identifier
        let isExclusion =  row < exclusionAppsList.count
        
        if id != NSUserInterfaceItemIdentifier(rawValue: "checkbox") {
            return
        }
        
        if isExclusion {
            let item = exclusionAppsList.remove(at: row)
            activeAppsList.insert(item, at: 0)
        }
        else {
            let item = activeAppsList.remove(at: row - exclusionAppsList.count)
            exclusionAppsList.append(item)
        }
        
        exclusionAppsDict = [:]
        
        for val in exclusionAppsList {
            exclusionAppsDict[val.id] = val.name
        }
        
        tableReload()
        saveExclusionApps()
    }
    
    @objc func tableReload() {
        tableView.reloadData()
    }
    
    func saveExclusionApps() {
        UserDefaults.standard.set(exclusionAppsList.map {$0.toDictionary()} , forKey: "exclusionApps")
    }
}
