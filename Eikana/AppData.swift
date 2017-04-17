//
//  AppData.swift
//  ⌘英かな
//
//  MIT License
//  Copyright (c) 2016 iMasanari
//

import Cocoa

class AppData : NSObject {
    var name: String
    var id: String
    
    init(name: String, id: String) {
        self.name = name
        self.id = id
        
        super.init()
    }
    
    override init() {
        self.name = ""
        self.id = ""
        
        super.init()
    }
    
    init?(dictionary : [AnyHashable: Any]) {
        if let name = dictionary["name"] as? String, let id = dictionary["id"] as? String {
            self.name = name
            self.id = id
            
            super.init()
        }
        else {
            return nil
        }
    }
    
    func toDictionary() -> [AnyHashable: Any] {
        return [
            "name": self.name,
            "id": self.id
        ]
    }
}


