//
//  IFCache.swift
//  IFCacheKit
//
//  Created by Ivan Foong on 7/9/15.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

import Foundation

public class IFCache<Key: NSObject, Value: NSObject where Key: protocol<NSCoding, Hashable, NSCopying>, Value: protocol<NSCoding, NSCopying>> : IFCacheProtocol {
    typealias K = Key
    typealias V = Value
    
    public let diskCache:IFDiskCache<K, V>
    public let memoryCache:IFMemoryCache<K, V>
    
    public init(cacheDirectoryPath: String, lruItemSize: Int) {
        self.diskCache = IFDiskCache(cacheDirectoryPath: cacheDirectoryPath)
        self.memoryCache = IFMemoryCache(capacity: lruItemSize)
    }
    
    public func all() -> Dictionary<K, V> {
        return get(Set(self.diskCache._index.keys.array))
    }
    
    public func get(keys: Set<K>) -> Dictionary<K, V> {
        var results = Dictionary<K, V>()
        var memoryCacheResults = self.memoryCache.get(keys)
        let cacheMissedKeys = keys.subtract(Set(memoryCacheResults.keys.array))
        
        var diskCacheResults = self.diskCache.get(cacheMissedKeys)
        
        // add memory cache missed items into memory cache
        for (k, v) in diskCacheResults {
            self.memoryCache.put(k, value: v)
        }
        
        results = self.unionDictionary(memoryCacheResults, rightDictionary: diskCacheResults)
        
        return results
    }
    
    public func remove(keys: Set<K>) -> Self {
        self.memoryCache.remove(keys)
        self.diskCache.remove(keys)
        return self
    }
    
    public func clear() -> Self {
        self.memoryCache.clear()
        self.diskCache.clear()
        return self;
    }
    
    public func put(key: K, value: V) -> Self {
        return put(key, value: value, expiryDate: nil)
    }
    
    public func put(key: K, value: V, expiryDate: NSDate?) -> Self {
        self.memoryCache.put(key, value: value, expiryDate: expiryDate)
        self.diskCache.put(key, value: value, expiryDate: expiryDate)
        return self;
    }
    
    public func size() -> Int {
        return all().count
    }
    
    func unionDictionary<K, V>(leftDictionary: Dictionary<K, V>, rightDictionary: Dictionary<K, V>) -> Dictionary<K, V> {
        var resultDictionary = Dictionary<K, V>()
        for (k, v) in leftDictionary {
            resultDictionary.updateValue(v, forKey: k)
        }
        for (k, v) in rightDictionary {
            resultDictionary.updateValue(v, forKey: k)
        }
        return resultDictionary
    }
}