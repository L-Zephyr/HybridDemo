//
//  NativePlugin.swift
//  Hybrid
//
//  Created by LZephyr on 2017/4/9.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import UIKit

@objc protocol NativePluginProtocol: PluginExport {
    func showAlert(message: String)
    
    func doCallback(_ callback: RJBCallback)
    
    func add(_ a: Int, _ b: Int) -> Int
}

class NativePlugin: NSObject, NativePluginProtocol {
    
    class func pluginName() -> String! {
        return "alert"
    }
    
    func doCallback(_ callback: ([Any]?) -> Void) {
        callback(["callback value"])
    }
    
    func showAlert(message: String) {
        let alert = UIAlertView(title: "", message: message, delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "ok", "")
        alert.show()
    }
    
    func add(_ a: Int, _ b: Int) -> Int {
        return a + b
    }
}
