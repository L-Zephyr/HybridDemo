//
//  CacheManagerTests.swift
//  Hybrid
//
//  Created by LZephyr on 2016/12/21.
//  Copyright © 2016年 LZephyr. All rights reserved.
//

import XCTest
@testable import Hybrid

class CacheManagerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let dbpath = HybridConfig.cachePath + "/cache.db"
        if FileManager.default.fileExists(atPath: dbpath) {
            try? FileManager.default.removeItem(atPath: dbpath)
        }
        CacheManager.shared.databaseInitialize()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    // MARK: - WebappFilesTable test
    
    // insert test
    func testFilesTableInsert() {
        let item = createFileItem(withIndex: 1)
        XCTAssert(CacheManager.shared.insert(fileItem: item), "insert item to files table fail")
    }
    
    // select test
    func testFilesTableSelect() {
        let item = createFileItem(withIndex: 1)
        
        XCTAssert(CacheManager.shared.insert(fileItem: item), "insert item fali")
        
        let resultItem = CacheManager.shared.selectFileItem(forKey: item.key)
        XCTAssert(resultItem != nil, "select from files table fail")
        
        XCTAssert(resultItem!.key == item.key, "select wrong data")
        XCTAssert(resultItem!.fullUrl == item.fullUrl, "select wrong data")
        XCTAssert(resultItem!.localRelativePath == item.localRelativePath, "select wrong data")
        XCTAssert(resultItem!.size == item.size, "select wrong data")
    }
    
    // select all test
    func testFilesTableSelectAll() {
        let item1 = createFileItem(withIndex: 1)
        let item2 = createFileItem(withIndex: 2)
        
        XCTAssert(CacheManager.shared.insert(fileItem: item1))
        XCTAssert(CacheManager.shared.insert(fileItem: item2))
        
        let items = CacheManager.shared.selectAllFileItems()
        
        XCTAssert(items.count == 2, "select all fail \(items.count)")
        
        // item1 content
        XCTAssert(item1 == items[0], "select all wrong data")
        XCTAssert(item2 == items[1], "select all wrong data")
    }
    
    // delete test
    func testFilesTableDelete() {
        let item1 = createFileItem(withIndex: 1)
        let item2 = createFileItem(withIndex: 2)
        
        XCTAssert(CacheManager.shared.insert(fileItem: item1))
        XCTAssert(CacheManager.shared.insert(fileItem: item2))
        
        XCTAssert(CacheManager.shared.deleteFileItem(forKey: item1.key), "delete fail")
        
        let items = CacheManager.shared.selectAllFileItems()
        
        XCTAssert(items.contains(item2), "delete wrong data")
        XCTAssert(!items.contains(item1), "delete wrong data")
    }
    
    func createFileItem(withIndex index: Int) -> WebAppFileItem {
        var item = WebAppFileItem()
        item.key = "key\(index)"
        item.fullUrl = "fullurl\(index)"
        item.localRelativePath = "localpath\(index)"
        item.size = "size\(index)"
        return item
    }
    
    // MARK: - WebappInfoTable test
    
    func testInfoTableInsert() {
        let info = createWebappInfo(withIndex: 1)
        XCTAssert(CacheManager.shared.updateWebappInfo(info), "insert webapp info fail")
    }
    
    func testInfoTableSelect() {
        let info = createWebappInfo(withIndex: 1)
        XCTAssert(CacheManager.shared.updateWebappInfo(info), "insert webapp info fail")
        
        guard let selectInfo = CacheManager.shared.webappInfo() else {
            XCTAssert(false)
            return
        }
        
        XCTAssert(selectInfo == info, "select wrong data")
    }
    
    func createWebappInfo(withIndex index: Int) -> WebAppInfo {
        let info = WebAppInfo()
        info.name = "name\(index)"
        info.currentVersion = "currentVersion\(index)"
        info.latestVersion = "latestVersion\(index)"
        info.remoteUrl = "remoteUrl\(index)"
        info.localPath = "localPath\(index)"
        info.size = "size\(index)"
        return info
    }
}
