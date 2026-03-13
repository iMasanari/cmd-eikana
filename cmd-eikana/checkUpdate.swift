//
//  checkUpdate.swift
//  ⌘英かな
//
//  MIT License
//  Copyright (c) 2016 iMasanari
//

// TODO: アップデートチェック機能の改善
// NSURLConnection.sendAsynchronousRequestはdeprecatedのためURLSessionに置き換え
// メインスレッドでのUI操作をDispatchQueue.main.asyncで対応

import Cocoa

func checkUpdate(_ callback: ((_ isNewVer: Bool?) -> Void)? = nil) {
    let url = URL(string: "https://ei-kana.appspot.com/update.json")!
    let request = URLRequest(url: url)
    
    let handler = { (data:Data?, res:URLResponse?, error:Error?) -> Void in
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        var newVersion = ""
        var description = ""
        var url = "https://ei-kana.appspot.com"
        
        do {
            if let data = data {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                newVersion = json["version"] as! String
                description = json["description"] as! String
                
                if let NSURLDownload = json["url"] as? String {
                    url = NSURLDownload
                }
            }
        } catch let error as NSError {
            print(error.debugDescription)
            return;
        }
        
        let isAbleUpdate: Bool? = (newVersion == "") ? nil : newVersion != version
        
        if isAbleUpdate == true {
            DispatchQueue.main.async {
                let alert = NSAlert()
                alert.messageText = "⌘英かな ver.\(newVersion) が利用可能です"
                alert.informativeText = description
                alert.addButton(withTitle: "Download")
                alert.addButton(withTitle: "Cancel")
                // alert.showsSuppressionButton = true;
                let ret = alert.runModal()
                
                if (ret == NSApplication.ModalResponse.alertFirstButtonReturn) {
                    NSWorkspace.shared.open(URL(string: url)!)
                }
            }
        }
        
        if let callback = callback {
            DispatchQueue.main.async {
                callback(isAbleUpdate)
            }
        }
    }
    
    URLSession.shared.dataTask(with: request, completionHandler: handler).resume()
}
