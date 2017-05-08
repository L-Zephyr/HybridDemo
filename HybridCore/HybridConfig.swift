//
//  HybridConfig.swift
//  Hybrid
//
//  Created by LZephyr on 2016/12/13.
//  Copyright © 2016年 LZephyr. All rights reserved.
//

import UIKit

public class HybridConfig {
    /// 路由表文件路径，json文件
    static var routeFilePath: String = "" {
        didSet {
            Router.shared.routeFilePath = routeFilePath
        }
    }
    
    /// 预先打包到App中的资源包路径
    static var resourcePreloadPath: String = "" {
        didSet {
            ResourceManager.shared.resourcePreloadPath = resourcePreloadPath
        }
    }
    
    /// 日志等级
    static var logLevel: Logger.LoggerLevel = .Info {
        didSet {
            LogLevel = logLevel
        }
    }
}
