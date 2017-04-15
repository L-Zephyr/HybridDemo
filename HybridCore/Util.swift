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

class Util {
    
    /// 获取Application Support文件夹路径
    class var appSpportPath: String {
        guard let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.applicationSupportDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first else {
            return ""
        }
        
        if FileManager.default.fileExists(atPath: path) == false {
            do {
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("error occured when create \(path) error: \(error)")
            }
        }
        
        return path
    }
    
    /// 获取临时文件夹
    class var tempPath: String {
        return NSTemporaryDirectory()
    }
    
    /// 如果文件夹不存在则创建文件夹
    class func createDirectoryIfNotExist(withPath path: String) {
        if FileManager.default.fileExists(atPath: path) == false {
            do {
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("create dir error \(error)")
            }
        }
    }
    
    /// 如果文件不存在则创建
    class func createFileIfNotExist(withPath path: String) {
        if FileManager.default.fileExists(atPath: path) == false {
            if FileManager.default.createFile(atPath: path, contents: nil, attributes: nil) == false {
                print("create \(path) error")
            }
        }
    }
    
    /// 读取一个json配置文件
    class func loadJsonObject(fromUrl url: URL?) -> [String: Any]? {
        guard let url = url else {
            return nil
        }
        
        do {
            let jsonData = try Data(contentsOf: url)
            if let info = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? [String: Any] {
                return info
            }
        } catch {
            print("\(error)")
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
        return url.lastPathComponent.hasSuffix(".zip")
    }
}
