//
//  Author.swift
//  IFCacheKit
//
//  Created by Ivan Foong on 7/9/15.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

import Foundation

class Author : NSObject, NSCoding, Hashable, NSCopying {
    var name:String?
    
    init(name: String?) {
        self.name = name
    }
    
    @objc func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.name, forKey: "name")
    }
    
    @objc required convenience init(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObjectForKey("name") as? String
        self.init(name: name)
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        return Author(name: self.name)
    }
    
    override var hashValue: Int {
        get {
            return self.name?.hashValue ?? 0
        }
    }
}

func == (lhs: Author, rhs: Author) -> Bool {
    return lhs.hashValue == rhs.hashValue
}