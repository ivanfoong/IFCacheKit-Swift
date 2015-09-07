//
//  IFMemoryCache.swift
//  IFCacheKit
//
//  Created by Ivan Foong on 7/9/15.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

import Foundation

public class IFMemoryCache<Key: protocol<NSCoding, Hashable, NSCopying>, Value: protocol<NSCoding, NSCopying>> : IFCacheProtocol {
    typealias K = Key
    typealias V = Value
    
    var capacity:Int
    var _cache:Dictionary<Key, IFMemoryCacheNode<K, V>>
    var headNode, tailNode: IFMemoryCacheNode<K, V>?
    
    public init(capacity: Int) {
        self.capacity = capacity
        _cache = Dictionary<K, IFMemoryCacheNode<K, V>>()
    }
    
    public func all() -> Dictionary<K, V> {
        return get(Set(_cache.keys.array))
    }
    
    public func get(keys: Set<K>) -> Dictionary<K, V> {
        var results = Dictionary<K, V>()
        for key in keys {
            if let node = _cache[key] {
                if !nodeExpired(node) {
                    setHeadNode(node)
                    results.updateValue(node.value, forKey: key)
                }
                else {
                    removeNode(node)
                }
            }
        }
        return results
    }
    
    public func remove(keys: Set<K>) -> Self {
        for key in keys {
            if let node = node(key) {
                removeNode(node)
            }
        }
        return self
    }
    
    public func clear() -> Self {
        remove(Set(_cache.keys.array))
        return self
    }
    
    public func put(key: K, value: V) -> Self {
        return put(key, value: value, expiryDate: nil)
    }
    
    public func put(key: K, value: V, expiryDate: NSDate?) -> Self {
        setNode(key, value: value, expiryDate: expiryDate)
        return self
    }
    
    public func size() -> Int {
        return all().count
    }
    
    func node(key: K) -> IFMemoryCacheNode<K, V>? {
        if let node = _cache[key] {
            setHeadNode(node)
            return node
        }
        return nil
    }
    
    func removeNode(node: IFMemoryCacheNode<K, V>) {
        _cache.removeValueForKey(node.key)
        
        if node.previous != nil {
            node.previous?.next = node.next
        }
        else {
            self.headNode = node.next
        }
        
        if node.next != nil {
            node.next?.previous = node.previous
        }
        else {
            self.tailNode = node.previous
        }
    }
    
    func setHeadNode(node: IFMemoryCacheNode<K, V>) {
        if _cache[node.key] == nil {
            _cache.updateValue(node, forKey: node.key)
        }
        
        var previousNode = node.previous
        var nextNode = node.next
        
        if nextNode != nil && previousNode != nil {
            previousNode?.next = nextNode
            nextNode?.previous = previousNode
        }
        else if previousNode != nil {
            previousNode?.next = nil
        }
        else if nextNode != nil {
            nextNode?.previous = nil
        }
        
        if let tailNode = self.tailNode where tailNode == node {
            self.tailNode = previousNode
        }
        
        node.next = self.headNode
        node.previous = nil
        
        if self.headNode != nil {
            self.headNode?.previous = node
        }
        
        self.headNode = node
        
        if self.tailNode == nil {
            self.tailNode = self.headNode
        }
    }
    
    func setNode(key: K, value: V, expiryDate: NSDate?) {
        if let node = _cache[key] {
            removeNode(node)
        }
        
        let node = IFMemoryCacheNode<K, V>(key: key, value: value, expiryDate: expiryDate)
        if _cache.count >= self.capacity {
            if let tailNode = self.tailNode {
                removeNode(tailNode)
            }
        }
        
        setHeadNode(node)
    }
    
    func nodeExpired(node: IFMemoryCacheNode<K, V>) -> Bool {
        if let expiryDate = node.expiryDate {
            return NSDate().compare(expiryDate) == NSComparisonResult.OrderedDescending || NSDate().compare(expiryDate) == NSComparisonResult.OrderedSame
        }
        return false
    }
}

class IFMemoryCacheNode<K:Hashable, V> : Equatable {
    var key:K
    var value:V
    var expiryDate:NSDate?
    var previous:IFMemoryCacheNode?
    var next:IFMemoryCacheNode?
    
    init(key: K, value: V, expiryDate: NSDate?) {
        self.key = key
        self.value = value
        self.expiryDate = expiryDate
    }
}

func == <K:Hashable, V>(lhs: IFMemoryCacheNode<K, V>, rhs: IFMemoryCacheNode<K, V>) -> Bool {
    return lhs.key == rhs.key
}