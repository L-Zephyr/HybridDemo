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
            packageCachePath = cachePath + "Packages/"
            resourceCachePath = cachePath + "Resources/"
        }
    }
    
    /// 缓存路径url 
    var cachePathUrl: URL? {
        return URL(fileURLWithPath: cachePath)
    }
    
    // MARK: - Public Method
    
    /// 获取文件的本地缓存,nil表示本地缓存不存在
    /// - Parameter remoteUrl: 文件的url，根据url查找本地缓存
    /// - Returns: 查找成功直接返回文件数据，失败则返回nil
    public func localCacheData(withRemoteUrl remoteUrl: URL) -> Data? {
        return nil
        
        guard let host = remoteUrl.host else {
            return nil
        }
        let key = host + remoteUrl.path
        if let fileItem = self.selectFileItem(forKey: key.md5()) {
            let fullPath = cachePath + fileItem.localRelativePath
            if FileManager.default.fileExists(atPath: fullPath) {
                do {
                    let url = URL(fileURLWithPath: fullPath)
                    let fileData = try Data(contentsOf: url)
                    return fileData
                } catch {
                    LogError("\(error)")
                }
            }
        }
        
        return nil
    }
    
    /// 将文件保存到本地
    /// - Parameter tmpPath:   文件临时储存的位置
    /// - Parameter remoteUrl: 文件的url
    public func saveFile(atTmpPath tmpPath: String, forRemoteUrl remoteUrl: URL) {
        guard let host = remoteUrl.host else {
            return
        }
        guard let filename = tmpPath.components(separatedBy: "/").last else {
            return
        }
        let fullPath = packageCachePath + filename
        
        // 1. 在数据库中创建索引
        let key = host + remoteUrl.path
        var fileItem = WebAppFileItem()
        fileItem.key = key.md5()
        fileItem.fullUrl = remoteUrl.absoluteString
        fileItem.localRelativePath = fullPath.relativePath(toPath: cachePath)
        if self.insert(fileItem: fileItem) == false {
            return
        }
        // TODO: 暂时不处理size
        
        // 2. 将文件从临时位置移动到缓存文件夹
        do {
            if FileManager.default.fileExists(atPath: fullPath) {
                try FileManager.default.removeItem(atPath: fullPath)
            }
            try FileManager.default.moveItem(atPath: tmpPath, toPath: fullPath)
            
            if FileManager.default.fileExists(atPath: tmpPath) {
                try FileManager.default.removeItem(atPath: tmpPath)
            }
        } catch {
            LogError("\(error)")
        }
    }
    
    /// 解析并更新资源压缩包
    /// - Parameter path 压缩包路径
    @discardableResult internal func unzipWebappPackage(atPath path: String) -> Bool {
        if let tmpUrl = self.cachePathUrl?.appendingPathComponent("webapp.tmp"), unzipPackage(withPath: path, toPath: tmpUrl.path) {
            do {
                try FileManager.default.removeItem(atPath: packageCachePath)
                try FileManager.default.moveItem(atPath: tmpUrl.path, toPath: packageCachePath)
                if generateFilesIndex(inPath: packageCachePath) == false {
                    return false
                }
            } catch {
                LogError("\(error)")
                return false
            }
        } else {
            LogError("压缩包解压失败")
            return false
        }
        return true
    }
    
    // MARK: - Private
    
    internal let queue: DispatchQueue = DispatchQueue(label: "Hybrid.com.database")
    
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
    fileprivate func unzipPackage(withPath path: String, toPath: String) -> Bool {
        if FileManager.default.fileExists(atPath: path) {
            let zip = ZipArchive()
            if !zip.unzipOpenFile(path) || !zip.unzipFile(to: toPath, overWrite: true) {
                LogError("资源包解压失败")
                return false
            }
        } else {
            LogError("资源包不存在")
            return false
        }
        return true
    }
    
    /// 遍历文件夹并生成索引
    fileprivate func generateFilesIndex(inPath path: String) -> Bool {
        var isDir: ObjCBool = ObjCBool(true)
        if FileManager.default.fileExists(atPath: path, isDirectory: &isDir), let encodePath = path.urlEncoding(), let url = URL(string: encodePath) {
            if isDir.boolValue == false {
                return false
            }
            
            let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.isDirectoryKey], options: .skipsHiddenFiles, errorHandler: nil)
            
            while let fileUrl = enumerator?.nextObject() as? URL {
                guard let resValues = try? fileUrl.resourceValues(forKeys: [.isDirectoryKey]), let isDirectory = resValues.isDirectory else {
                    return false
                }
                
                if isDirectory {
                    continue
                }
                
                let fullPath = fileUrl.resolvingSymlinksInPath().path
                let relativePath = fullPath.relativePath(toPath: packageCachePath)
                let key = (HybridConfig.serverAddress?.addressWithoutPort() ?? "") + relativePath
                LogVerbose("插入文件索引,key为\(key)")
                
                var fileItem = WebAppFileItem()
                fileItem.key = key.md5()
                fileItem.localRelativePath = fullPath.relativePath(toPath: cachePath)
                // TODO: size 暂时先不加
                if self.insert(fileItem: fileItem) == false {
                    return false
                }
            }
        }
        return true
    }
    
    init() {
        defer {
//            cachePath = Util.appSpportPath + "/HybridCache/"
            databaseInitialize() // 初始化数据库
            checkWebAppInfo()
        }
    }
    
    /// 启动时检查本地信息
    fileprivate func checkWebAppInfo() {
        // 如果不存在webapp的信息则尝试从本地读取
        if self.webappInfo() == nil {
            guard let webRoot = HybridConfig.webRoot, let resUrl = Bundle.main.resourceURL?.appendingPathComponent(webRoot) else {
                return
            }
            let configFileUrl = resUrl.appendingPathComponent("webapp_info.json")
            let packageUrl = resUrl.appendingPathComponent("webapp.zip")
            
            if FileManager.default.fileExists(atPath: configFileUrl.path) == false {
                LogError("未找到配置文件webapp_info.json")
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
                self.updateWebappInfo(webapp)
            } catch {
                LogError("\(error)")
            }
            
            // 解析离线资源包
            unzipWebappPackage(atPath: packageUrl.path)
        }
    }
    
    // TODO: 内存缓存和磁盘缓存实现，LRU缓存淘汰算法处理缓存过期
}
