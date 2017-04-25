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
    public var routeFileUrl: String = "" {
        didSet {
            if !FileManager.default.fileExists(atPath: routeFileUrl) {
                LogError("Route file not exist at: \(routeFileUrl)")
                routeTable = [:]
                return
            }
            
            if let routes = Util.loadJsonObject(fromUrl: URL(fileURLWithPath: routeFileUrl)) as? [[String : String]] {
                var table: [String : [String : String]] = [:]
                for routeItem in routes {
                    if let routeUrl = routeItem[Constant.RouteUrl] { // 将route url作为key
                        table[routeUrl] = routeItem
                    } else {
                        LogWarning("路由表:'\(routeFileUrl)'缺少'\(Constant.RouteUrl)'")
                    }
                }
                routeTable = table
                downloadOrUpdatePackage()
            } else {
                routeTable = [:]
            }
        }
    }
    
    /// 根据url获取一个ViewController
    ///
    /// - Parameter routeUrl: webapp的url，唯一标示一个Hybrid页面
    /// - Returns:            一个用于展示该页面的WebViewController实例
    public func webViewController(routeUrl: String) -> WebViewController? {
        return webViewController(routeUrl: routeUrl, params: [:])
    }
    
    public func webViewController(routeUrl: String, params: [String : Any]) -> WebViewController? {
        if let webView = webView(routeUrl: routeUrl, params: params) {
            return WebViewController(webView: webView)
        } else {
            return nil
        }
    }
    
    /// 根据route_url获取一个WebView
    ///
    /// - Parameter routeUrl: 路由URL，唯一标识一个页面
    /// - Returns:            用于展示该页面的WebView
    public func webView(routeUrl: String) -> WebView? {
        return webView(routeUrl: routeUrl, params: [:])
    }
        
    public func webView(routeUrl: String, params: [String : Any]) -> WebView? {
        if routeTable.keys.contains(routeUrl) {
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
    fileprivate func downloadOrUpdatePackage() {
        for (_, routeItem) in routeTable {
            guard let version = routeItem[Constant.Version], let routeUrl = routeItem[Constant.RouteUrl], let download = routeItem[Constant.DownloadUrl] else {
                LogError("路由文件的信息不完整")
                return
            }
            
            // 当前为最新版
            if let webapp = ResourceManager.shared.webapp(withRoute: routeUrl), webapp.version >= version {
                continue
            }
            
            if let donwloadUrl = URL(string: download) {
                ResourceManager.shared.downloadPackage(url: donwloadUrl, success: nil, failure: nil)
            } else {
                LogError("无效的下载链接")
            }
        }
    }
}
