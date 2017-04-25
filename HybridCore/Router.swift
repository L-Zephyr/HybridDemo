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
    
    /// 根据资源包的`download_url`获取`route_url`
    ///
    /// - Parameter downloadUrl: 资源包下载url
    /// - Returns:               该资源包的的路由
    public func routeUrl(with downloadUrl: URL) -> String? {
        for (_, routeItem) in routeTable {
            if let download = routeItem[Constant.DownloadUrl], downloadUrl.absoluteString == download {
                return routeItem[Constant.RouteUrl]
            }
        }
        return nil
    }
    
    /// 根据路由URL获取资源包的下载URL
    ///
    /// - Parameter routeUrl: 路由URL字符串
    /// - Returns:            资源包下载URL
    public func downloadUrl(with routeUrl: String) -> URL? {
        for (_, routeItem) in routeTable {
            if let route = routeItem[Constant.RouteUrl], routeUrl == route, let download = routeItem[Constant.DownloadUrl] {
                return URL(string: download)
            }
        }
        return nil
    }
    
    /// 获取指定资源包的版本
    ///
    /// - Parameter routeUrl: 资源包的路由URL
    /// - Returns:            该资源包的版本号
    public func version(for routeUrl: String) -> String? {
        for (_, routeItem) in routeTable {
            if let route = routeItem[Constant.RouteUrl], routeUrl == route, let version = routeItem[Constant.Version] {
                return version
            }
        }
        return nil
    }
    
    /// 设置路由表的本地路径
    public var routeTableUrl: String = "" {
        didSet {
            if !FileManager.default.fileExists(atPath: routeTableUrl) {
                LogError("Route file not exist at: \(routeTableUrl)")
                routeTable = [:]
                return
            }
            
            if let routes = Util.loadJsonObject(fromUrl: URL(string: routeTableUrl)) as? [[String : String]] {
                var table: [String : [String : String]] = [:]
                for routeItem in routes {
                    if let routeUrl = routeItem[Constant.RouteUrl] { // 将route url作为key
                        table[routeUrl] = routeItem
                    } else {
                        LogWarning("路由表:'\(routeTableUrl)'缺少'\(Constant.RouteUrl)'")
                    }
                }
                routeTable = table
                precachePackage()
            } else {
                routeTable = [:]
            }
        }
    }
    
    /// 根据url获取一个ViewController
    ///
    /// - Parameter url: webapp的url，唯一标示一个Hybrid页面
    /// - Returns:       一个用于展示该页面的WebViewController实例
    public func webViewController(routeUrl: String) -> WebViewController? {
        return webViewController(routeUrl: routeUrl, params: [:])
    }
    
    public func webViewController(routeUrl: String, params: [String : Any]) -> WebViewController? {
        return nil
    }
    
    /// 根据route_url获取一个WebView
    ///
    /// - Parameter url: route url，唯一标识一个页面
    /// - Returns:       用于展示该页面的WebView
    public func webView(routeUrl: String) -> WebView? {
        return webView(routeUrl: routeUrl, params: [:])
    }
        
    public func webView(routeUrl: String, params: [String : Any]) -> WebView? {
        if let routeItem = routeTable[routeUrl] {
//            if let localPath = ResourceManager.shared.localPath(withRoute: routeUrl) { // 资源包已下载
//                return WebView(frame: CGRect.zero, url: localPath)
//            } else if let download = routeItem[Constant.DownloadUrl], let donwloadUrl = URL(string: download) { // 否则下载
//                ResourceManager.shared.downloadPackage(url: donwloadUrl, success: { (desUrl) in
//                    
//                }, failure: { (error) in
//                    LogError("Download package fail: \(error)")
//                })
//            }
            let webView = WebView()
            webView.load(routeUrl: routeUrl)
            return webView
        } else {
            LogError("Route url '\(routeUrl)' not exist")
        }
        return nil
    }
    
    // MARK: - Private
    
    struct Constant {
        static let RouteUrl = "route_url"
        static let DownloadUrl = "download_url"
        static let Version = "version"
    }
    
    fileprivate var routeTable: [String : [String : String]] = [:]; // 路由表
    
    /// 预缓存资源包
    fileprivate func precachePackage() {
        for (_, routeItem) in routeTable {
            if let download = routeItem[Constant.DownloadUrl], let donwloadUrl = URL(string: download) {
                ResourceManager.shared.downloadPackage(url: donwloadUrl, success: nil, failure: nil)
            }
        }
    }
    
    /// 检查更新
    fileprivate func checkUpdate() {
        
    }
}
