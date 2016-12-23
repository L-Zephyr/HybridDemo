//
//  Config.swift
//  Hybrid
//
//  Created by LZephyr on 2016/12/13.
//  Copyright © 2016年 LZephyr. All rights reserved.
//

import UIKit

class Config {
    /// 打包在bundle中包含离线资源的目录
    static var webRoot: String? = nil
    
    /// 本地缓存目录,默认为 Applcation Support/HybridCache
    static var cachePath: String = CacheManager.shared.cachePath {
        didSet {
            CacheManager.shared.cachePath = cachePath
        }
    }
    
    /// 服务器地址
    static var serverAddress: String? = nil
    
    /// 缓存类型白名单
    static var cacheTypeWhiteList: [String] = ["js", "css", "html", "png", "jpg", "jpeg", "webp"]
    
    /// 缓存类型黑名单
    static var cacheTypeBlackList: [String] = []
    
    /// 资源包更新完毕立即生效, 默认为下次启动时生效
    static var updateWhenFinishDownload: Bool = false
}
