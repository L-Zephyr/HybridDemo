//
//  CacheManager.swift
//  Hybrid
//
//  Created by LZephyr on 2016/12/11.
//  Copyright © 2016年 LZephyr. All rights reserved.
//

import UIKit

class CacheManager {
    static let shared = CacheManager()
    
    // MARK: - Public Property
    
    /// 允许缓存
    var cacheEnable: Bool = true
    
    /// 缓存最大磁盘占用,0为无限制
    var maxDiskCacheSize: Int = 0
    
    /// 缓存最大内存占用
    var maxMermoryCacheSize: Int = 0
    
    /// 缓存路径
    var cachePath: String = ""
    
    // MARK: - Public Method
    
    /// 获取文件的本地缓存,nil表示本地缓存不存在
    public func localFile(withPath path: String) -> String? {
        return nil
    }
    
    /// 将文件保存到本地
    public func saveFile(withPath path: String) {
        
    }
    
    // MARK: - Private
    
    // TODO: 内存缓存和磁盘缓存实现，LRU缓存淘汰算法处理缓存过期
}
