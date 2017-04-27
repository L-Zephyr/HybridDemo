//
//  Util.swift
//  Hybrid
//
//  Created by LZephyr on 2016/12/12.
//  Copyright © 2016年 LZephyr. All rights reserved.
//

import UIKit

enum Errors: Error {
    case readDataFail
    case httpRequestError
}

internal class Util {
    
    struct Constant {
        static let webappInfoFile = "webapp_info.json"
    }
    
    /// 获取Application Support文件夹路径
    class var appSpportPath: URL? {
        guard let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.applicationSupportDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first else {
            return nil
        }
        
        if FileManager.default.fileExists(atPath: path) == false {
            do {
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                LogError("error occured when create \(path) error: \(error)")
            }
        }
        
        return URL(fileURLWithPath: path)
    }
    
    /// 获取'Application Support/Hybrid'路径
    class var rootPath: URL? {
        if let url = appSpportPath?.appendingPathComponent("Hybrid") {
            if Util.createDirectoryIfNotExist(withPath: url.path) {
                return url
            }
        }
        return nil
    }
    
    /// 获取'Application Support/Hybrid/webapp'路径, 保存资源包解压后的文件夹
    class var webappPath: URL? {
        if let url = appSpportPath?.appendingPathComponent("Hybrid").appendingPathComponent("webapp") {
            if Util.createDirectoryIfNotExist(withPath: url.path) {
                return url
            }
        }
        return nil
    }
    
    /// 获取'Application Support/Hybrid/temp'路径, 用于临时保存资源包
    class var webappTempPath: URL? {
        if let url = appSpportPath?.appendingPathComponent("Hybrid").appendingPathComponent("temp") {
            if Util.createDirectoryIfNotExist(withPath: url.path) {
                return url
            }
        }
        return nil
    }
    
    /// 获取临时文件夹
    class var tempPath: String {
        return NSTemporaryDirectory()
    }
    
    /// 创建文件夹
    ///
    /// - Parameter path: 文件夹路径
    /// - Returns: 是否创建成功
    class func createDirectoryIfNotExist(withPath path: String) -> Bool {
        if FileManager.default.fileExists(atPath: path) == false {
            do {
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                LogError("Create directory at '\(path)' failed: \(error)")
                return false
            }
        }
        return true
    }
    
    /// 创建文件
    ///
    /// - Parameter path: 文件路径
    /// - Returns: 是否创建成功
    class func createFileIfNotExist(withPath path: String) -> Bool {
        if FileManager.default.fileExists(atPath: path) == false {
            if FileManager.default.createFile(atPath: path, contents: nil, attributes: nil) == false {
                LogError("Create file at '\(path)' failed")
                return false
            }
        }
        return true
    }
    
    /// 读取一个json配置文件
    class func loadJsonObject(fromUrl url: URL?) -> Any? {
        guard let url = url else {
            return nil
        }
        
        do {
            let jsonData = try Data(contentsOf: url)
            return try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        } catch {
            LogError("Read json file error: \(error)")
        }
        
        return nil
    }
    
    /// url是否指向一个文件夹
    class func isFolder(url: URL) -> Bool {
        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) {
            if isDir.boolValue {
                return true
            }
        }
        return false
    }
    
    /// 判断url是否指向一个zip文件
    class func isZip(url: URL) -> Bool {
        return url.isFileURL && url.lastPathComponent.hasSuffix(".zip")
    }
}

internal extension URL {
    
    /// 获取相对路径，只对本地文件URL有效
    ///
    /// - Parameter baseUrl: 基准URL
    /// - Returns:           返回相对于baseUrl的url
    func relatedTo(_ baseUrl: URL?) -> URL? {
        guard let baseUrl = baseUrl else {
            return nil
        }
        
        let relatedPath = self.path.substring(from: baseUrl.path.endIndex)
        return URL(fileURLWithPath: relatedPath)
    }
}
