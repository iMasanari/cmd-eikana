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
        
        #if DEBUG
            print("\(key): \(val.input.toString()) => \(val.output.toString())")
        #endif
    }
}

class ShortcutsController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet weak var tableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func mouseDown(with event: NSEvent) {
        activeKeyTextField?.blur()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return keyMappingList.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let id = tableColumn!.identifier

        if let cell = tableView.makeView(withIdentifier: id, owner: nil) as? NSTableCellView {
            if id.rawValue == "input" || id.rawValue == "output" {
                let value = id.rawValue == "input" ? keyMappingList[row].input : keyMappingList[row].output
                
                // let textField = cell.textField!
                let textField = cell.subviews[0] as! KeyTextField
                
                textField.stringValue = value.toString()
                textField.shortcut = value
                textField.saveAddress = (row: row, id: id.rawValue)
                textField.isAllowModifierOnly = id.rawValue == "input"
            }
            if id.rawValue == "mapping-menu" {
                let button = cell.subviews[0] as! MappingMenu
                
                button.row = row
                
                button.target = self
                button.action = #selector(ShortcutsController.remove(_:))
            }
        
            return cell
        }
        return nil
    }
    @objc func remove(_ sender: MappingMenu) {
        activeKeyTextField?.blur()
        
        switch sender.selectedItem!.title {
        case "この項目を削除", "remove":
            sender.remove()
            break
        case "最上部に移動", "move to the top":
            sender.move(0)
            break
        case "1つ上に移動", "move one up":
            sender.move(sender.row! - 1)
            break
        case "1つ下に移動", "move one down":
            sender.move(sender.row! + 1)
            break
        case "最下部に移動", "move to bottom":
            sender.move(keyMappingList.count - 1)
            break
        default:
            break
        }
        
        tableRreload()
    }
    
    func tableRreload() {
        tableView.reloadData()
        keyMappingListToShortcutList()
        saveKeyMappings()
    }
    
    @IBAction func quit(_ sender: AnyObject) {
        NSApplication.shared.terminate(self)
    }
    
    @IBAction func addRow(_ sender: AnyObject) {
        keyMappingList.append(KeyMapping())
        tableRreload()
    }
}
