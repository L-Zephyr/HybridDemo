//
//  Router.swift
//  Hybrid
//
//  Created by LZephyr on 2017/4/19.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import UIKit

class Router: NSObject {
    
    // MARK: - Public
    
    public static let shared = Router()
    
    /// 根据url获取一个ViewController
    ///
    /// - Parameter url: webapp的url，唯一标示一个Hybrid页面
    /// - Returns:       一个用于展示该页面的WebViewController实例
    public func webViewController(url: String) -> WebViewController? {
        return nil
    }
    
    public func webViewController(url: String, params: [String : Any]) -> WebViewController? {
        return nil
    }
}
