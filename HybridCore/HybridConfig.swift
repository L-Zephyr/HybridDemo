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
    
    /// 资源包MD5值的解密秘钥，若设置了该值则表明启用资源包防篡改校验，资源包中的webapp_info.json文件中需要带上DES加密后的MD5值
    static var encryptionKey: String? = nil
    
    /// 日志等级
    static var logLevel: Logger.LoggerLevel = .Warning {
        didSet {
            LogLevel = logLevel
        }
    }
}
