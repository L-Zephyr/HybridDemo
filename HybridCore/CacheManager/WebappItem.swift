//
//  WebappItem.swift
//  Hybrid
//
//  Created by LZephyr on 2017/4/24.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import UIKit

internal class WebappItem: NSObject {
    
    /// 资源包的路由URL
    public var routeUrl: String = ""
    
    /// 资源包压缩包的位置
    public var zipPath: String = ""
    
    /// 解压后的本地保存位置
    public var localPath: String = ""
    
    /// 本地保存位置的URL
    public var localUrl: URL {
        return URL(fileURLWithPath: localPath)
    }
    
    /// 资源包的版本
    public var version: String = ""
}
