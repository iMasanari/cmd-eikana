//
//  checkUpdate.swift
//  ⌘英かな
//
//  MIT License
//  Copyright (c) 2016 iMasanari
//

// TODO: NSURLSessionでの書き直し
// NSURLConnection.sendAsynchronousRequestはdeprecatedだが
// NSURLSessionを使うと実行時にalert.runModal()でエラーが出たため
// NSURLConnectionで代用中

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
        
        if let callback = callback {
            DispatchQueue.main.async {
                callback(isAbleUpdate)
            }
        }
    }
    
    //NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main, completionHandler: handler)
    let config = URLSessionConfiguration.default
    let session = URLSession(configuration: config)
    let task = session.dataTask(with: request, completionHandler: handler)
    task.resume()
}
