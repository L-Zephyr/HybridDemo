//
//  HybridConfig.swift
//  Hybrid
//
//  Created by LZephyr on 2016/12/13.
//  Copyright © 2016年 LZephyr. All rights reserved.
//

import UIKit

class HybridConfig {
    /// 资源包更新完毕立即生效, 默认为下次启动时生效
    static var updateWhenFinishDownload: Bool = false
    
    /// 日志等级
    static var logLevel: Logger.LoggerLevel = .Info {
        didSet {
            LogLevel = logLevel
        }
    }
}
