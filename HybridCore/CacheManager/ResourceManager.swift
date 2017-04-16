//
//  ResourceManager.swift
//  Hybrid
//
//  Created by LZephyr on 2017/4/16.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import UIKit
import ZipArchive

internal class ResourceManager {
    
    public static let shared = ResourceManager()
    
    /// 获取资源包的本地缓存位置, 如果不存在则解压至一个本地路径
    ///
    /// - Parameter url: 资源包的URL
    public func localPath(with url: URL) -> URL? {
        guard let zipRelatedUrl = url.relatedTo(Bundle.main.resourceURL) else {
            LogError("Can not get related path")
            return nil
        }
        
        if Util.isZip(url: url) {
            if let localRelatedPath = selectLocalPath(zipRelatedUrl) { // 已解压到本地
                return Util.appSpportPath?.appendingPathComponent(localRelatedPath.path)
            } else if let localPath = Util.webappPath, let appPath = Util.appSpportPath { // 否则解压到本地，并保存位置信息
                // unzip
                guard let relatedUrl = localPath.appendingPathComponent(url.path.md5()).relatedTo(appPath),
                      let fullUrl = Util.appSpportPath?.appendingPathComponent(relatedUrl.path) else {
                    return nil
                }
                
                let zip = ZipArchive()
                if zip.unzipOpenFile(url.path) && zip.unzipFile(to: fullUrl.path, overWrite: true) {
                    insert(zipUrl: zipRelatedUrl, localUrl: relatedUrl)
                    return fullUrl
                }
            }
        }
        return nil
    }
    
    init() {
        initDatabase()
    }
    
    // MARK: - Private
    
    internal let sqlQueue: DispatchQueue = DispatchQueue(label: "Hybrid.com.database")
}

// MARK: - Data Base

internal extension ResourceManager {
    
    private struct Table {
        static let Name = "ResourceTable"
        static let ZipPath = "zip_path"
        static let LocalPath = "local_path"
    }
    
    fileprivate var sqlPath: URL? {
        if let webappPath = Util.webappPath {
            return webappPath.appendingPathComponent("hybrid.db")
        }
        return nil
    }
    
    fileprivate func initDatabase() {
        if let webappPath = Util.webappPath {
            let sqlUrl = webappPath.appendingPathComponent("hybrid.db")
            _ = Util.createFileIfNotExist(withPath: sqlUrl.path)
        }
        
        query { (database) -> Bool in
            let createTable = "create table if not exists \(Table.Name)(" +
                "\(Table.ZipPath) text primary key, " +
                "\(Table.LocalPath) text);"
            if sqlite3_exec(database, createTable, nil, nil, nil) != SQLITE_OK {
                LogError("Fail to create database table: \(String(cString: sqlite3_errmsg(database)))")
                return false
            }
            
            return true
        }
    }
    
    /// 获取资源包在本地解压后的路径
    ///
    /// - Parameter url: 资源压缩包路径
    /// - Returns:       解压后的文件夹路径
    fileprivate func selectLocalPath(_ zipUrl: URL) -> URL? {
        var url: URL? = nil
        
        let sema = DispatchSemaphore(value: 0)
        query({ (database) -> Bool in
            let sql = "select * from \(Table.Name) where \(Table.ZipPath)=\"\(zipUrl.path)\";"
            var stat: OpaquePointer? = nil
            var result = false
            
            if sqlite3_prepare_v2(database, sql, -1, &stat, nil) == SQLITE_OK {
                if sqlite3_step(stat) == SQLITE_ROW, let path = sqlite3_column_text(stat, 1) {
                    url = URL(fileURLWithPath: String(cString: path))
                    result = true
                }
            }
            sqlite3_finalize(stat)
            sema.signal()
            
            return result
        })
        
        sema.wait()
        
        return url
    }
    
    /// 保存压缩包和解压信息
    ///
    /// - Parameters:
    ///   - zipUrl:   压缩包路径
    ///   - localUrl: 解压后的路径
    /// - Returns:    保存成功返回true，否则false
    @discardableResult fileprivate func insert(zipUrl: URL, localUrl: URL) -> Bool {
        return query({ (database) -> Bool in
            let sql = "insert or replace into \(Table.Name) values ('\(zipUrl.path)', '\(localUrl.path)');"
            if sqlite3_exec(database, sql, nil, nil, nil) != SQLITE_OK {
                LogError("Fail to insert into Table \(Table.Name): \(String(cString: sqlite3_errmsg(database)))")
                return false
            }
            return true
        })
    }
    
    /// 从数据库中删除一条数据
    ///
    /// - Parameter zipUrl: 资源压缩包路径
    /// - Returns: 删除成功返回true，否则false
    @discardableResult fileprivate func delete(zipUrl: URL) -> Bool {
        return query({ (database) -> Bool in
            let sql = "delete from \(Table.Name) where \(Table.ZipPath)='\(zipUrl.path)';"
            if sqlite3_exec(database, sql, nil, nil, nil) != SQLITE_OK {
                LogError("Fail to delete from Table \(Table.Name): \(String(cString: sqlite3_errmsg(database)))")
                return false
            }
            return true
        })
    }
    
    /// 执行一条数据库查询
    ///
    /// - Parameter block: 在block中执行数据库操作
    /// - Returns:         操作成功返回true，否则返回false
    @discardableResult fileprivate func query(_ block: (_ database: OpaquePointer?) -> Bool) -> Bool {
        guard let sqlPath = sqlPath?.path else {
            return false
        }
        
        var result: Bool = true
        self.sqlQueue.sync {
            var database: OpaquePointer? = nil
            if sqlite3_open(sqlPath, &database) != SQLITE_OK {
                LogError("打开数据库失败: \(String(cString: sqlite3_errmsg(database)))")
                result = false
                return
            }
            
            result = block(database)
            
            if sqlite3_close(database) != SQLITE_OK {
                LogError("关闭数据库失败: \(String(cString: sqlite3_errmsg(database)))")
            }
        }
        return result
    }
}
