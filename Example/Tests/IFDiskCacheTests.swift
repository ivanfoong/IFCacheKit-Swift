//
//  IFDiskCacheTests.swift
//  IFCacheKit
//
//  Created by Ivan Foong on 7/9/15.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

import Quick
import Nimble
import IFCacheKit

class IFDiskCacheSpec: QuickSpec {
    
    var cacheDirectoryPath = "\(NSTemporaryDirectory())disk_cache"
    
    override func spec() {
        describe("the disk cache") {
            it("can put items") {
                var cache = IFDiskCache<Author, Book>(cacheDirectoryPath: self.cacheDirectoryPath)
                let authors = self.sampleAuthors()
                let books = self.sampleBooks()
                
                cache.put(authors[0], value: books[0])
                expect(cache._index[authors[0]]).toNot(beNil())
            }
            
            it("can get items") {
                var cache = IFDiskCache<Author, Book>(cacheDirectoryPath: self.cacheDirectoryPath)
                let authors = self.sampleAuthors()
                let books = self.sampleBooks()
                
                cache.put(authors[0], value: books[0])
                expect(cache.get(Set([authors[0]]))[authors[0]]) == books[0]
                
                let now = NSDate()
                cache.put(authors[0], value: books[0], expiryDate: now)
                expect(cache.get(Set([authors[0]])).count) == 0 // due to expiry
            }
            
            it("can get all items") {
                var cache = IFDiskCache<Author, Book>(cacheDirectoryPath: self.cacheDirectoryPath)
                let authors = self.sampleAuthors()
                let books = self.sampleBooks()
                
                cache.put(authors[0], value: books[0])
                let now = NSDate()
                cache.put(authors[1], value: books[1], expiryDate: now)
                
                let result = cache.all()
                expect(result.count) == 1
                expect(result[authors[0]]) == books[0]
            }
            
            it("can get item count") {
                var cache = IFDiskCache<Author, Book>(cacheDirectoryPath: self.cacheDirectoryPath)
                let authors = self.sampleAuthors()
                let books = self.sampleBooks()
                
                cache.put(authors[0], value: books[0])
                let now = NSDate()
                cache.put(authors[1], value: books[1], expiryDate: now)
                
                expect(cache.size()) == 1
            }
            
            it("can remove items") {
                var cache = IFDiskCache<Author, Book>(cacheDirectoryPath: self.cacheDirectoryPath)
                let authors = self.sampleAuthors()
                let books = self.sampleBooks()
                
                cache.put(authors[0], value: books[0])
                cache.remove(Set([authors[0]]))
                expect(cache.size()) == 0
            }
            
            it("can clear all items") {
                var cache = IFDiskCache<Author, Book>(cacheDirectoryPath: self.cacheDirectoryPath)
                let authors = self.sampleAuthors()
                let books = self.sampleBooks()
                
                cache.put(authors[0], value: books[0])
                cache.put(authors[1], value: books[1])
                
                cache.clear()
                expect(cache.size()) == 0
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