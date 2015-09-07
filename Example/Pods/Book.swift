//
//  Book.swift
//  IFCacheKit
//
//  Created by Ivan Foong on 7/9/15.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

import Foundation

class Book : NSObject, NSCoding, Hashable, NSCopying {
    var title:String?
    
    init(title: String?) {
        self.title = title
    }
    
    @objc func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.title, forKey: "title")
    }
    
    @objc required convenience init(coder aDecoder: NSCoder) {
        let title = aDecoder.decodeObjectForKey("title") as? String
        self.init(title: title)
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        return Book(title: self.title)
    }
    
    override var hashValue: Int {
        get {
            return self.title?.hashValue ?? 0
        }
    }
}

func == (lhs: Book, rhs: Book) -> Bool {
    return lhs.hashValue == rhs.hashValue
}