//
//  IFMemoryCacheTests.swift
//  IFCacheKit
//
//  Created by Ivan Foong on 7/9/15.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

import Quick
import Nimble
import IFCacheKit

class IFMemoryCacheSpec: QuickSpec {
    override func spec() {
        describe("the memory cache") {
            it("can put items") {
                let capacity = 1
                var cache = IFMemoryCache<Author, Book>(capacity: capacity)
                let authors = self.sampleAuthors()
                let books = self.sampleBooks()
                
                cache.put(authors[0], value: books[0])
                expect(cache._cache[authors[0]]?.value) == books[0]
                
                cache.put(authors[1], value: books[1])
                expect(cache._cache[authors[1]]?.value) == books[1]
                
                expect(cache._cache[authors[0]]).to(beNil()) // due to overflow
            }
            
            it("can get items") {
                let capacity = 1
                var cache = IFMemoryCache<Author, Book>(capacity: capacity)
                let authors = self.sampleAuthors()
                let books = self.sampleBooks()
                
                let node = IFMemoryCacheNode<Author, Book>(key: authors[0], value: books[0], expiryDate: nil)
                cache._cache.updateValue(node, forKey: authors[0])
                expect(cache.get(Set([authors[0]]))[authors[0]]) == books[0]
                
                let now = NSDate()
                let expiredNode = IFMemoryCacheNode<Author, Book>(key: authors[0], value: books[0], expiryDate: now)
                cache._cache.updateValue(expiredNode, forKey: authors[0])
                expect(cache.get(Set([authors[0]])).count) == 0 // due to expiry
            }
            
            it("can get all items") {
                let capacity = 1
                var cache = IFMemoryCache<Author, Book>(capacity: capacity)
                let authors = self.sampleAuthors()
                let books = self.sampleBooks()
                
                let node = IFMemoryCacheNode<Author, Book>(key: authors[0], value: books[0], expiryDate: nil)
                cache._cache.updateValue(node, forKey: authors[0])
                
                let now = NSDate()
                let expiredNode = IFMemoryCacheNode<Author, Book>(key: authors[1], value: books[1], expiryDate: now)
                cache._cache.updateValue(expiredNode, forKey: authors[1])
                
                let result = cache.all()
                expect(result.count) == 1
                expect(result[authors[0]]) == books[0]
            }
            
            it("can get item count") {
                let capacity = 2
                var cache = IFMemoryCache<Author, Book>(capacity: capacity)
                let authors = self.sampleAuthors()
                let books = self.sampleBooks()
                
                let node = IFMemoryCacheNode<Author, Book>(key: authors[0], value: books[0], expiryDate: nil)
                cache._cache.updateValue(node, forKey: authors[0])
                
                let now = NSDate()
                let expiredNode = IFMemoryCacheNode<Author, Book>(key: authors[1], value: books[1], expiryDate: now)
                cache._cache.updateValue(expiredNode, forKey: authors[1])
                
                expect(cache.size()) == 1
            }
            
            it("can remove items") {
                let capacity = 1
                var cache = IFMemoryCache<Author, Book>(capacity: capacity)
                let authors = self.sampleAuthors()
                let books = self.sampleBooks()
                
                let node = IFMemoryCacheNode<Author, Book>(key: authors[0], value: books[0], expiryDate: nil)
                cache._cache.updateValue(node, forKey: authors[0])
                cache.remove(Set([authors[0]]))
                expect(cache._cache.count) == 0
            }
            
            it("can clear all items") {
                let capacity = 2
                var cache = IFMemoryCache<Author, Book>(capacity: capacity)
                let authors = self.sampleAuthors()
                let books = self.sampleBooks()
                
                let node = IFMemoryCacheNode<Author, Book>(key: authors[0], value: books[0], expiryDate: nil)
                cache._cache.updateValue(node, forKey: authors[0])
                
                let node2 = IFMemoryCacheNode<Author, Book>(key: authors[1], value: books[1], expiryDate: nil)
                cache._cache.updateValue(node2, forKey: authors[1])
                
                cache.clear()
                expect(cache._cache.count) == 0
            }
        }
    }
    
    func sampleAuthors() -> [Author] {
        return [Author(name: "Ivan Foong"), Author(name: "Jon Doe"), Author(name: "John Smith")]
    }
    
    func sampleBooks() -> [Book] {
        return [Book(title: "Swift Caching"), Book(title: "Gingerbread Man"), Book(title: "Stick Man")]
    }
}
