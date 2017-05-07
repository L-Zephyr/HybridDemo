//
//  HybridTests.swift
//  HybridTests
//
//  Created by LZephyr on 2016/12/11.
//  Copyright © 2016年 LZephyr. All rights reserved.
//

import XCTest
import JavaScriptCore
@testable import Hybrid

public var invokeFlag: Int = 0

@objc protocol PluginProtocol: PluginExport {
    func nativeMehtod()
    func nativeMehtod2(_ param: String)
}

class NativePlugin: NSObject, PluginProtocol {
    
    class func pluginName() -> String! {
        return "pluginTest"
    }
    
    func nativeMehtod() {
    }
    
    func nativeMehtod2(_ param: String) {
        
    }
}

class HybridTests: XCTestCase {
    
    var context: JSContext?
    var plugin: PluginInstance?
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        context = JSContext()
        context?.exceptionHandler = { (context, value) -> Void in
            XCTAssert(false, "JSContext错误")
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        context = nil
    }
    
//    func testExample() {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//    }
//    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
    func testCallNativeMethod() {
        let instance = PluginInstance(with: NativePlugin.self)
        
    }
    
}
