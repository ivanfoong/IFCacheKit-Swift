//
//  IFDiskCache.swift
//  IFCacheKit
//
//  Created by Ivan Foong on 7/9/15.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

import Foundation

public class IFDiskCache<Key: NSObject, Value: NSObject where Key: protocol<NSCoding, Hashable, NSCopying>, Value: protocol<NSCoding, NSCopying>> : IFCacheProtocol {
    typealias K = Key
    typealias V = Value
    
    var cacheDirectoryPath:String
    var _index:Dictionary<K, IFDiskCacheFileIndex>
    
    init(cacheDirectoryPath: String) {
        self.cacheDirectoryPath = cacheDirectoryPath
        NSFileManager.defaultManager().createDirectoryAtPath(self.cacheDirectoryPath, withIntermediateDirectories: true, attributes: nil, error: nil)
        _index = Dictionary<K, IFDiskCacheFileIndex>()
    }
    
    public func all() -> Dictionary<K, V> {
        return get(Set(_index.keys.array))
    }
    
    public func get(keys: Set<K>) -> Dictionary<K, V> {
        var results = Dictionary<K, V>()
        for key in keys {
            if let fileIndex = _index[key] {
                if fileIndexExpired(fileIndex) {
                    remove([key])
                }
                else {
                    let filepath = "\(self.cacheDirectoryPath)/\(fileIndex.filename)"
                    if let cacheItem = NSKeyedUnarchiver.unarchiveObjectWithFile(filepath) as? Dictionary<K, IFDiskCacheItem> {
                        if let value = cacheItem[key]?.item as? V {
                            results.updateValue(value, forKey: key)
                        }
                    }
                }
            }
        }
        return results
    }
    
    public func remove(keys: Set<K>) -> Self {
        for key in keys {
            if let fileIndex = _index[key] {
                let filepath = "\(self.cacheDirectoryPath)/\(fileIndex.filename)"
                var cacheItem = unarchiveFromFile(filepath)
                if cacheItem != nil && cacheItem![key] != nil {
                    if cacheItem!.count > 1 {
                        cacheItem!.removeValueForKey(key)
                        archiveToFile(filepath, object: cacheItem!)
                    }
                    else {
                        var error:NSError?
                        NSFileManager.defaultManager().removeItemAtPath(filepath, error: &error)
                    }
                }
            }
            
            _index.removeValueForKey(key)
        }
        return self
    }
    
    public func clear() -> Self {
        return remove(Set(_index.keys.array))
    }
    
    public func put(key: K, value: V) -> Self {
        return put(key, value: value, expiryDate: nil)
    }
    
    public func put(key: K, value: V, expiryDate: NSDate?) -> Self {
        let filename = generateFilename(key)
        let filepath = "\(cacheDirectoryPath)/\(filename)"
        
        var item = Dictionary<K, IFDiskCacheItem>()
        if let archivedItem = unarchiveFromFile(filepath) {
            item = archivedItem
        }
        item.updateValue(IFDiskCacheItem(item: value, expiryDate: expiryDate), forKey: key)
        archiveToFile(filepath, object: item)
        
        let fileIndex = IFDiskCacheFileIndex(filename: filename, expiryDate: expiryDate)
        _index.updateValue(fileIndex, forKey: key)
        
        return self
    }
    
    public func size() -> Int {
        return all().count
    }
    
    func dataToHexString(data: NSData) -> String {
        var bytes = [UInt8](count: data.length, repeatedValue: 0)
        data.getBytes(&bytes, length: data.length)
        
        let hexString = NSMutableString()
        for byte in bytes {
            hexString.appendFormat("%02x", UInt(byte))
        }
        
        return String(hexString)
    }
    
    func generateFilename(object: NSCoding) -> String {
        let data = NSKeyedArchiver.archivedDataWithRootObject(object)
        let hexString = dataToHexString(data)
        var filename = hexString
        if count(filename) > 100 {
            let index = advance(filename.endIndex, -100)
            filename = filename.substringFromIndex(index)
        }
        while (count(filename) < 100) {
            filename = "0\(filename)"
        }
        filename = "\(filename).kar"
        return filename
    }
    
    func unarchiveFromFile(filepath: String) -> Dictionary<K, IFDiskCacheItem>? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(filepath) as? Dictionary<K, IFDiskCacheItem>
    }
    
    func archiveToFile(filepath: String, object: Dictionary<K, IFDiskCacheItem>) {
        NSKeyedArchiver.archiveRootObject(object, toFile: filepath)
    }
    
    func fileIndexExpired(fileIndex: IFDiskCacheFileIndex) -> Bool {
        if let expiryDate = fileIndex.expiryDate {
            return NSDate().compare(expiryDate) == NSComparisonResult.OrderedDescending || NSDate().compare(expiryDate) == NSComparisonResult.OrderedSame
        }
        return false
    }
}

class IFDiskCacheItem : NSObject, NSCoding {
    var item: NSCoding
    var expiryDate:NSDate?
    
    init(item: NSCoding, expiryDate: NSDate?) {
        self.item = item
        self.expiryDate = expiryDate
    }
    
    @objc func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.item, forKey: "item")
        aCoder.encodeObject(self.expiryDate, forKey: "expiry_date")
    }
    
    @objc required convenience init(coder aDecoder: NSCoder) {
        let item = aDecoder.decodeObjectForKey("item") as! NSCoding
        let expiryDate = aDecoder.decodeObjectForKey("expiry_date") as? NSDate
        self.init(item: item, expiryDate: expiryDate)
    }
}

class IFDiskCacheFileIndex : NSObject, NSCoding {
    var filename:String
    var expiryDate:NSDate?
    
    init(filename: String, expiryDate: NSDate?) {
        self.filename = filename
        self.expiryDate = expiryDate
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.filename, forKey: "filename")
        aCoder.encodeObject(self.expiryDate, forKey: "expiry_date")
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let filename = aDecoder.decodeObjectForKey("filename") as! String
        let expiryDate = aDecoder.decodeObjectForKey("expiry_date") as? NSDate
        self.init(filename: filename, expiryDate: expiryDate)
    }
}
