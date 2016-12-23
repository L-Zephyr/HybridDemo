//
//  CacheManager.swift
//  Hybrid
//
//  Created by LZephyr on 2016/12/11.
//  Copyright © 2016年 LZephyr. All rights reserved.
//

import UIKit
import ZipArchive

class CacheManager {
    
    // MARK: - Public Property
    
    static let shared = CacheManager()
    
    /// 允许缓存
    var cacheEnable: Bool = true
    
    /// 缓存最大磁盘占用,0为无限制
    var maxDiskCacheSize: Int = 0
    
    /// 缓存最大内存占用
    var maxMermoryCacheSize: Int = 0
    
    /// 缓存路径
    var cachePath: String = "" {
        didSet {
            Util.createDirectoryIfNotExist(withPath: cachePath)
            packageCachePath = cachePath + "/Packages"
            packageCachePath = cachePath + "/Resources"
        }
    }
    
    /// 缓存路径url 
    var cachePathUrl: URL? {
        return URL(fileURLWithPath: cachePath)
    }
    
    // MARK: - Public Method
    
    /// 获取文件的本地缓存,nil表示本地缓存不存在
    public func localCacheData(withRemoteUrl remoteUrl: String) -> Data? {

        return nil
    }
    
    /// 将文件保存到本地
    public func saveFile(withPath path: String) {
        
    }
    
    // MARK: - Private
    
    /// 资源包缓存位置
    fileprivate var packageCachePath: String = "" {
        didSet {
            Util.createDirectoryIfNotExist(withPath: packageCachePath)
        }
    }
    
    /// 图片资源缓存位置
    fileprivate var resourceCachePath: String = "" {
        didSet {
            Util.createDirectoryIfNotExist(withPath: resourceCachePath)
        }
    }
    
    /// 将资源包文件解压到临时文件夹
    fileprivate func unzipPackage(withPath path: String) -> Bool {
        if FileManager.default.fileExists(atPath: path) {
            // 临时文件夹
            guard let tmpUrl = self.cachePathUrl?.appendingPathComponent("webapp.tmp") else {
                return false
            }
            
            let zip = ZipArchive()
            if !zip.unzipOpenFile(path) || !zip.unzipFile(to: tmpUrl.path, overWrite: true) {
                print("资源包解压失败")
                return false
            }
        } else {
            print("资源包不存在")
            return false
        }
        return true
    }
    
    /// 遍历文件夹并生成索引
    fileprivate func generateFilesIndex(withUrl url: URL) {
        var isDir: ObjCBool = ObjCBool(true)
        if url.isFileURL && FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) {
            if isDir.boolValue == false {
                return
            }
            
            let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.nameKey, .isDirectoryKey], options: .skipsHiddenFiles, errorHandler: nil)
            
            while let file = enumerator?.nextObject() as? URL {
                guard let resValues = try? file.resourceValues(forKeys: [.nameKey, .isDirectoryKey]), let name = resValues.name, let isDirectory = resValues.isDirectory else {
                    return
                }
                
                if isDirectory {
                    continue
                }
                
                let key = Config.serverAddress ?? "" + name
                
                var fileItem = WebAppFileItem()
                fileItem.key = key.md5()
            }
        }
    }
    
    init() {
        defer {
            cachePath = Util.appSpportPath + "/HybridCache/"
            checkWebAppInfo()
        }
    }
    
    /// 启动时检查本地信息
    fileprivate func checkWebAppInfo() {
        // 如果不存在webapp的信息则尝试从本地读取
        print("\(DBHelper.shared.webappInfo())")
        if DBHelper.shared.webappInfo() == nil {
            guard let resUrl = Bundle.main.resourceURL else {
                return
            }
            let configFileUrl = resUrl.appendingPathComponent("webapp_info.json")
            let packageUrl = resUrl.appendingPathComponent("webapp.zip")
            
            if FileManager.default.fileExists(atPath: configFileUrl.path) == false {
                print("未找到配置文件webapp_info.json")
                return
            }
            
            // 读取配置文件
            let webapp = WebAppInfo()
            do {
                let data = try Data(contentsOf: configFileUrl)
                if let info = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String: Any] {
                    if let name = info["name"] as? String {
                        webapp.name = name
                    } else {
                        webapp.name = "HybridWebapp"
                    }
                    if let version = info["version"] as? String {
                        webapp.currentVersion = version
                    }
                    if let url = info["url"] as? String {
                        webapp.remoteUrl = url
                    }
                    if let md5 = info["md5"] as? String {
                        // TODO: md5校验
                    }
                }
                DBHelper.shared.updateWebappInfo(webapp)
                VersionManager.shared.loadVersionInfo()
            } catch {
                print(error)
            }
            
            // 解析离线资源包
            if unzipPackage(withPath: packageUrl.path) {
                
            }
        }
    }
    
    // TODO: 内存缓存和磁盘缓存实现，LRU缓存淘汰算法处理缓存过期
}
