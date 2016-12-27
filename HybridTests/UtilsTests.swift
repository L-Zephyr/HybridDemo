//
//  UtilsTests.swift
//  Hybrid
//
//  Created by LZephyr on 2016/12/24.
//  Copyright © 2016年 LZephyr. All rights reserved.
//

import XCTest
@testable import Hybrid

class UtilsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
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
    
    // 测试相对路径计算
    func testRelativePath() {
        //test1
        var path = "/aaa/bbb/ccc/ddd.zip"
        var anchorPath = "/aaa/bbb"
        
        var result = path.relativePath(toPath: anchorPath)
        XCTAssert(result == "/ccc/ddd.zip", "error result: \(result)")
        
        // test2
        path = "aaa/bbb/ccc/ddd"
        anchorPath = "/aaa/bbb/ccc/ddd"
        result = path.relativePath(toPath: anchorPath)
        XCTAssert(result == "", "error result: \(result)")
    }
}
