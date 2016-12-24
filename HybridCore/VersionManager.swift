//
//  VersionManager.swift
//  Hybrid
//
//  Created by LZephyr on 2016/12/15.
//  Copyright © 2016年 LZephyr. All rights reserved.
//

import UIKit

class VersionManager {
    
    // MARK: - Public
    
    static let shared = VersionManager()
    
    /// 当前版本
    internal var currentVersion: String? = nil
    
    /// 默认版本
    internal var defaultVersion: String? = nil
    
    /// 加载版本信息
    internal func loadVersionInfo() {
        currentVersion = CacheManager.shared.webappInfo()?.currentVersion
    }
    
    // MARK: - Private
    
    fileprivate var latestVersion: String? = nil
    
    init() {
        
    }
    
    /// 请求版本信息
    fileprivate func requestVersionInfo() {
        // test
        latestVersion = "20161212"
    }
}
