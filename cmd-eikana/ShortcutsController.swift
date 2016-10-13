//
//  ShortcutsController.swift
//  ⌘英かな
//
//  MIT License
//  Copyright (c) 2016 iMasanari
//

import Cocoa


var shortcutList: [CGKeyCode: [KeyMapping]] = [:]

var keyMappingList: [KeyMapping] = []

func saveKeyMappings() {
    UserDefaults.standard.set(keyMappingList.map {$0.toDictionary()} , forKey: "mappings")
}

func keyMappingListToShortcutList() {
    shortcutList = [:]
    
    for val in keyMappingList {
        let key = val.input.keyCode
        
        if shortcutList[key] == nil {
            shortcutList[key] = []
        }
        
        shortcutList[key]?.append(val)
        print("\(key): \(val.input.toString()) => \(val.output.toString())")
    }
}

class ShortcutsController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet weak var tableView: NSTableView!
    @IBAction func addRow(_ sender: AnyObject) {
        keyMappingList.append(KeyMapping())
        tableView.reloadData()
        saveKeyMappings()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
//        tableView.delegate = self
//        tableView.dataSource = self
    }
    func applicationDidResignActive(_ notification: Notification) {
        tableView.reloadData()
    }
    
    func numberOfRows(in aTableView: NSTableView) -> Int {
        return keyMappingList.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let id = tableColumn!.identifier

        if let cell = tableView.make(withIdentifier: id, owner: nil) as? NSTableCellView {
            if id == "input" || id == "output" {
                let value = id == "input" ? keyMappingList[row].input : keyMappingList[row].output
                
                // let textField = cell.textField!
                let textField = cell.subviews[0] as! KeyTextField
                
                textField.stringValue = value.toString()
                textField.shortcut = value
                textField.saveAddress = (row: row, id: id)
                textField.isAllowModifierOnly = id == "input"
            }
            if id == "remove" {
                let button = cell.subviews[0] as! RemoveButton
                
                button.row = row
                
                button.target = self
                button.action = #selector(ShortcutsController.remove(_:))
            }
        
            return cell
        }
        return nil
    }
    func remove(_ sender: RemoveButton) {
        activeKeyTextField?.blur()
        
        keyMappingList.remove(at: sender.row!)
        tableView.reloadData()
        saveKeyMappings()
    }
    override func mouseDown(with event: NSEvent) {
        activeKeyTextField?.blur()
    }
}

/// Target-Action helper.
class RemoveButton: NSButton {
    var row: Int?
}
