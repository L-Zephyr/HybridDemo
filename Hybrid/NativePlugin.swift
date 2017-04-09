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
}

class NativePlugin: NSObject, NativePluginProtocol {
    
    class func pluginName() -> String! {
        return "alert"
    }
    
    func showAlert(message: String) {
        let alert = UIAlertView(title: "", message: message, delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "ok", "")
        alert.show()
    }
}
