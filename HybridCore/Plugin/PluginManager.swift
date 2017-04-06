//
//  PluginManager.swift
//  Hybrid
//
//  Created by LZephyr on 2017/4/6.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import UIKit

internal class PluginManager: NSObject {
    
    /// 单例对象
    public static let shared = PluginManager()
    
    /// 将所有插件加载到Bridge中
    ///
    /// - Parameter bridge: WebView对应的Bridge
    public func registerPlugin(bridge: ReflectJavascriptBridge) {
        
    }
    
    /// 注销Bridge中的插件，在WebView销毁时调用
    ///
    /// - Parameter bridge: WebView对应的Bridge
    public func unregisterPlugin(bridge: ReflectJavascriptBridge) {
        
    }
    
    /// 获取Native的对象实例
    ///
    /// - Parameters:
    ///   - identifier: 对象唯一标识
    ///   - bridge:     对象实例所属的bridge
    /// - Returns:      返回Native的对象实例
    public func instance(identifier: String, bridge: ReflectJavascriptBridge) -> AnyObject? {
        return nil
    }
    
    // MARK: - Private
    
    /// 插件类列表
    fileprivate var pluginClasses: [AnyClass] = []
}
