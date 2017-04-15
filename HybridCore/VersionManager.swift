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
    
    /// 检查更新
    public func checkUpdate() {
        if webapp == nil {
            webapp = CacheManager.shared.webappInfo()
        }
        
        guard let webapp = webapp else {
            LogError("读取webapp数据失败")
            return
        }
        
        if !webapp.currentVersion.isEmpty && !webapp.latestVersion.isEmpty && !webapp.remoteUrl.isEmpty {
            if webapp.currentVersion < webapp.latestVersion { // 有新版本直接下载
                downloadPackage()
                return
            }
        }
        requestVersionInfo()
    }
    
    // MARK: - Private
    
    fileprivate var webapp: WebAppInfo? = nil
    
    fileprivate var requestTask: URLSessionDataTask? = nil
    fileprivate var downloadTask: URLSessionDownloadTask? = nil
    
    init() {
        
    }
    
    /// 请求版本信息
    fileprivate func requestVersionInfo() {
        // test
        if let url = URL(string: "http://localhost:3000/checkUpdate.json") {
            requestTask = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
                if error == nil && data != nil {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] {
                            if let latestVer = json["latest_version"] as? String {
                                self?.webapp?.latestVersion = latestVer
                            }
                            if let url = json["package_url"] as? String {
                                self?.webapp?.remoteUrl = url
                            }
                            self?.updateWebappInfo()
                            
                            LogInfo("当前版本:\(self?.webapp?.currentVersion ?? ""), 最新版本: \(self?.webapp?.latestVersion ?? "")")
                            
                            // 有更新则下载最新的资源包
                            if let currVer = self?.webapp?.currentVersion, let latestVer = self?.webapp?.latestVersion, currVer < latestVer {
                                LogVerbose("开始下载更新包")
                                self?.downloadPackage()
                            }
                        }
                    } catch {
                        LogError("json解析错误:\(error)")
                    }
                } else {
                    LogError("网络请求错误: \(error)")
                }
            }
            requestTask?.resume()
        }
    }
    
    /// 下载最新的资源包
    fileprivate func downloadPackage() {
        guard let webapp = webapp else {
            return
        }
        if let remoteUrl = URL(string: webapp.remoteUrl) {
            downloadTask = URLSession.shared.downloadTask(with: remoteUrl) { [weak self] (fileUrl, response, error) in
                if error == nil {
                    if let fileUrl = fileUrl {
                        // TODO: 更新包生效时机控制
                        if CacheManager.shared.unzipWebappPackage(atPath: fileUrl.path) {
                            self?.webapp?.currentVersion = self?.webapp?.latestVersion ?? ""
                            self?.updateWebappInfo()
                            LogInfo("资源包更新完成，当前版本: \(self?.webapp?.currentVersion ?? "")")
                        }
                    }
                } else {
                    LogError("资源包下载失败: \(error)")
                }
            }
            downloadTask?.resume()
        }
    }
    
    /// 更新本地webapp数据
    fileprivate func updateWebappInfo() {
        if let webapp = webapp {
            CacheManager.shared.updateWebappInfo(webapp)
        }
    }
}
