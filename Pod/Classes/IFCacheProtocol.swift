//
//  IFCacheProtocol.swift
//  IFCacheKit
//
//  Created by Ivan Foong on 7/9/15.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

import Foundation

protocol IFCacheProtocol {
    typealias K: NSObject, NSCoding, Hashable, NSCopying
    typealias V: NSObject, NSCoding, NSCopying
    
    func all() -> Dictionary<K, V>
    func get(keys: Set<K>) -> Dictionary<K, V>
    func remove(keys: Set<K>) -> Self
    func clear() -> Self
    func put(key: K, value: V) -> Self
    func put(key: K, value: V, expiryDate: NSDate?) -> Self
    func size() -> Int
}