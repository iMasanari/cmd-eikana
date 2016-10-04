//
//  ViewController.swift
//  ⌘英かな
//
//  MIT License
//  Copyright (c) 2016 iMasanari
//

import Cocoa

var selectKeyTextField: (textField: KeyTextField, key: KeyboardShortcut?)?

var tableDataIndex: [String: CGKeyCode] = [:]

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    let userDefaults = UserDefaults.standard
    
    var tableData: [[String: (String, CGKeyCode)]] = []
    
    @IBOutlet weak var tableView: NSTableView!
    
    @IBOutlet weak var showIcon: NSButton!
    @IBOutlet weak var lunchAtStartup: NSButton!
    @IBOutlet weak var checkUpdateAtlaunch: NSButton!
    @IBOutlet weak var updateButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let showIconState = userDefaults.object(forKey: "showIcon")
        showIcon.state = showIconState == nil ? 1 : showIconState as! Int
        
        if #available(OSX 10.12, *) {
        } else {
            showIcon.title += "（macOS Sierraのみ）"
            showIcon.isEnabled = false
        }
        
        lunchAtStartup.state = userDefaults.integer(forKey: "lunchAtStartup")
        checkUpdateAtlaunch.state = userDefaults.integer(forKey: "checkUpdateAtlaunch")
        
        tableData = [
            [
                "key": ("シフトキー", 0),
                "left": (getKeyboardShortcutStr(56), 56),
                "right": (getKeyboardShortcutStr(60), 60)
            ], [
                "key": ("コントロールキー", 0),
                "left": (getKeyboardShortcutStr(59), 59),
                "right": (getKeyboardShortcutStr(62), 62)
            ], [
                "key": ("オプションキー", 0),
                "left": (getKeyboardShortcutStr(58), 58),
                "right": (getKeyboardShortcutStr(61), 61)
            ], [
                "key": ("コマンドキー", 0),
                "left": (getKeyboardShortcutStr(55), 55),
                "right": (getKeyboardShortcutStr(54), 54)
            ], [
                "key": ("fnキー", 0),
                "right": (getKeyboardShortcutStr(63), 63)
            ],
        ];
    }
    
    func getKeyboardShortcutStr(_ modifierKeyCode: CGKeyCode) -> String {
        
        if let shortcut = oneShotModifiers[modifierKeyCode] {
            return KeyboardShortcut(keyCode: shortcut.keyCode, flags: shortcut.flags).toString()
        }
        
        return ""
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func numberOfRows(in aTableView: NSTableView) -> Int {
        let numberOfRows:Int = tableData.count
        
        return numberOfRows
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let id = tableColumn!.identifier
        
        if let value = tableData[row][id] , let cell = tableView.make(withIdentifier: id, owner: nil) as? NSTableCellView {
//            let textField = cell.textField!
            let textField = cell.subviews[0] as! NSTextField
            
            textField.stringValue = value.0
            textField.identifier = "\(id)-\(row)"
            
            tableDataIndex[textField.identifier!] = value.1
            
            return cell
        }
        return nil
    }
    
    // func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
    //     dataArray[row].setObject(object!, forKey: (tableColumn?.identifier)! as NSCopying)
    // }
    
    override func mouseDown(with event: NSEvent) {
        selectKeyTextField?.textField.window?.makeFirstResponder(nil)
    }

    @available(OSX 10.12, *)
    @IBAction func clickShowIcon(_ sender: AnyObject) {
        statusItem.isVisible = (showIcon.state == NSOnState)
        userDefaults.set(showIcon.state, forKey: "showIcon")
    }
    @IBAction func clickLunchAtStartup(_ sender: AnyObject) {
        setLaunchAtStartup(lunchAtStartup.state == NSOnState)
        userDefaults.set(lunchAtStartup.state, forKey: "lunchAtStartup")
    }
    @IBAction func clickCheckUpdateAtlaunch(_ sender: AnyObject) {
        userDefaults.set(checkUpdateAtlaunch.state, forKey: "checkUpdateAtlaunch")
    }
    
    @IBAction func quit(_ sender: AnyObject) {
        NSApplication.shared().terminate(self)
    }
    
    @IBAction func checkUpdateButton(_ sender: AnyObject) {
        updateButton.isEnabled = false
        checkUpdate({ (isNewVer: Bool?) -> Void in
            self.updateButton.isEnabled = true
            if isNewVer == nil {
                let alert = NSAlert()
                
                alert.messageText = "通信に失敗しました"
                alert.informativeText = "時間をおいて試してください"
                
                alert.runModal()
            }
            else if isNewVer == false {
                let alert = NSAlert()
                
                alert.messageText = "最新バージョンです"
                let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
                alert.informativeText = "ver.\(version)"
                
                alert.runModal()
            }
        })
    }
}

