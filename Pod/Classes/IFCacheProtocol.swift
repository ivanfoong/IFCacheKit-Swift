//
//  IFCacheProtocol.swift
//  IFCacheKit
//
//  Created by Ivan Foong on 7/9/15.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

import Foundation

protocol IFCacheProtocol {
    typealias K: NSCoding, Hashable, NSCopying
    typealias V: NSCoding, NSCopying
    
    public func all() -> Dictionary<K, V>
    public func get(keys: Set<K>) -> Dictionary<K, V>
    public func remove(keys: Set<K>) -> Self
    public func clear() -> Self
    public func put(key: K, value: V) -> Self
    public func put(key: K, value: V, expiryDate: NSDate?) -> Self
    public func size() -> Int
}