//
//  CacheManager.swift
//  Hybrid
//
//  Created by LZephyr on 2016/12/16.
//  Copyright © 2016年 LZephyr. All rights reserved.
//

import UIKit

// 储存webapp代码文件索引的表
fileprivate struct WebAppFilesTable {
    static let TableName: String = "webapp_files_table" // 表名
    static let Key: String = "key"                      // 主键，host+path的md5
    static let FullUrl: String = "full_url"             // 完整url
    static let LocalPath: String = "local_path"         // 本地储存路径
    static let Size: String = "size"                    // 文件大小
}

// 储存图片等资源文件索引的表
fileprivate struct WebAppResourceTable {
    static let TableName: String = "webapp_resource_table" // 表名
    static let Key: String = "key"                         // 主键，host+path的md5
    static let FullUrl: String = "full_url"                // 文件完整url
    static let Size: String = "size"                       // 文件大小
}

// 储存webapp信息的表
fileprivate struct WebAppInfoTable {
    static let TableName: String = "webapp_info_table"    // 表名
    static let Name: String = "name"                      // webapp的名字
    static let CurrentVersion: String = "current_version" // 当前版本号
    static let LatestVersion: String = "latest_version"   // 最新版本号
    static let RemoteUrl: String = "remote_url"           // 最新资源包下载路径
    static let LocalPath: String = "local_path"           // 资源包本地路径
    static let Size: String = "size"                      // 资源包总大小
}

extension CacheManager {
        
    // 数据库文件位置
    fileprivate var sqlPath: String {
        return self.cachePath + "cache.db"
    }
    
    internal func databaseInitialize() {
        if FileManager.default.fileExists(atPath: sqlPath) == false {
            if FileManager.default.createFile(atPath: sqlPath, contents: nil, attributes: nil) == false {
                logError("创建数据库文件失败")
            }
        }
        createTable()
    }
    
    fileprivate func createTable() {
        _ = query { (database) -> Bool in
            let createFilesTable = "create table if not exists \(WebAppFilesTable.TableName)(" +
                "\(WebAppFilesTable.Key) text not null primary key, " +
                "\(WebAppFilesTable.FullUrl) text, " +
                "\(WebAppFilesTable.LocalPath) text, " +
                "\(WebAppFilesTable.Size) text);"
            
            let createResourceTable = "create table if not exists \(WebAppResourceTable.TableName)(" +
                "\(WebAppResourceTable.Key) text not null primary key, " +
                "\(WebAppResourceTable.FullUrl) text, " +
                "\(WebAppResourceTable.Size) text);"
            
            let createInfoTable = "create table if not exists \(WebAppInfoTable.TableName)(" +
                "\(WebAppInfoTable.Name) text not null primary key, " +
                "\(WebAppInfoTable.CurrentVersion) text, " +
                "\(WebAppInfoTable.LatestVersion) text, " +
                "\(WebAppInfoTable.RemoteUrl) text, " +
                "\(WebAppInfoTable.LocalPath) text, " +
                "\(WebAppInfoTable.Size) text);"
            
            if sqlite3_exec(database, createFilesTable, nil, nil, nil) != SQLITE_OK {
                logError("创建表\(WebAppFilesTable.TableName)失败:\(String(cString: sqlite3_errmsg(database)))")
                return false
            }
            if sqlite3_exec(database, createResourceTable, nil, nil, nil) != SQLITE_OK {
                logError("创建表\(WebAppResourceTable.TableName)失败:\(String(cString: sqlite3_errmsg(database)))")
                return false
            }
            if sqlite3_exec(database, createInfoTable, nil, nil, nil) != SQLITE_OK {
                logError("创建表\(WebAppInfoTable.TableName)失败:\(String(cString: sqlite3_errmsg(database)))")
                return false
            }
            
            return true
        }
    }
}

// MARK: - WebAppFilesTable

extension CacheManager {
    
    /// 插入一条WebappFile记录，已存在则更新数据
    @discardableResult internal func insert(fileItem item: WebAppFileItem) -> Bool {
        return query { (database) -> Bool in
//            var result = true
//            var stat: OpaquePointer? = nil
//            let insertOrReplace = "insert or replace into \(WebAppFilesTable.TableName) (\(WebAppFilesTable.Key), \(WebAppFilesTable.FullUrl), \(WebAppFilesTable.LocalPath), \(WebAppFilesTable.Size)) values(?,?,?,?);"
//            
//            if sqlite3_prepare_v2(database, insertOrReplace, -1, &stat, nil) == SQLITE_OK {
//                sqlite3_bind_text(stat, 0, item.key, -1, nil)
//                sqlite3_bind_text(stat, 1, item.fullUrl, -1, nil)
//                sqlite3_bind_text(stat, 2, item.localPath, -1, nil)
//                sqlite3_bind_text(stat, 3, item.size, -1, nil)
//                
//                if sqlite3_step(stat) != SQLITE_DONE {
//                    print("insert fail: \(String(cString: sqlite3_errmsg(database)))")
//                    result = false
//                }
//                
//                sqlite3_finalize(stat)
//            } else {
//                print("prepare update fail: \(String(cString: sqlite3_errmsg(database)))")
//                sqlite3_finalize(stat)
//                result = false
//            }
            
            let insert = "insert or replace into \(WebAppFilesTable.TableName) values ('\(item.key)','\(item.fullUrl)','\(item.localRelativePath)','\(item.size)');"
            if sqlite3_exec(database, insert, nil, nil, nil) != SQLITE_OK {
                logError("insert fail: \(String(cString: sqlite3_errmsg(database)))")
                return false
            }
            
            return true
        }
    }
    
    /// 根据key删除一条WebappFile记录
    internal func deleteFileItem(forKey key: String) -> Bool {
        return query({ (database) -> Bool in
            let delete = "delete from \(WebAppFilesTable.TableName) where \(WebAppFilesTable.Key)='\(key)';"
            
            if sqlite3_exec(database, delete, nil, nil, nil) != SQLITE_OK {
                logError("delete fail: \(String(cString: sqlite3_errmsg(database)))")
                return false
            }
            
            return true
        })
    }
    
    /// 查询一条WebappFile记录
    internal func selectFileItem(forKey key: String) -> WebAppFileItem? {
        var item = WebAppFileItem()
        
        let result = query({ (database) -> Bool in
            let select = "select * from \(WebAppFilesTable.TableName) where \(WebAppFilesTable.Key)=\"\(key)\""
            var stat: OpaquePointer? = nil
            var result = false
            
            if sqlite3_prepare_v2(database, select, -1, &stat, nil) == SQLITE_OK {
                if sqlite3_step(stat) == SQLITE_ROW {
                    if let key = sqlite3_column_text(stat, 0) {
                        item.key = String(cString: key)
                    }
                    if let fullUrl = sqlite3_column_text(stat, 1) {
                        item.fullUrl = String(cString: fullUrl)
                    }
                    if let localPath = sqlite3_column_text(stat, 2) {
                        item.localRelativePath = String(cString: localPath)
                    }
                    if let size = sqlite3_column_text(stat, 3) {
                        item.size = String(cString: size)
                    }
                    result = true
                }
                sqlite3_finalize(stat)
            } else {
                logError("prepare fail: \(String(cString: sqlite3_errmsg(database)))")
            }
            return result
        })
        
        if result {
            return item
        } else {
            return nil
        }
    }
    
    /// 查询所有WebappFile记录
    internal func selectAllFileItems() -> [WebAppFileItem] {
        var items: [WebAppFileItem] = []
        
        _ = query({ (database) -> Bool in
            let select = "select * from \(WebAppFilesTable.TableName)"
            var stat: OpaquePointer? = nil
            
            if sqlite3_prepare_v2(database, select, -1, &stat, nil) == SQLITE_OK {
                while sqlite3_step(stat) == SQLITE_ROW {
                    var item = WebAppFileItem()
                    if let key = sqlite3_column_text(stat, 0) {
                        item.key = String(cString: key)
                    }
                    if let fullUrl = sqlite3_column_text(stat, 1) {
                        item.fullUrl = String(cString: fullUrl)
                    }
                    if let localPath = sqlite3_column_text(stat, 2) {
                        item.localRelativePath = String(cString: localPath)
                    }
                    if let size = sqlite3_column_text(stat, 3) {
                        item.size = String(cString: size)
                    }
                    items.append(item)
                }
                sqlite3_finalize(stat)
            } else {
                logError("prepare fail: \(String(cString: sqlite3_errmsg(database)))")
                return false
            }
            return true
        })
        
        return items
    }
}

// MARK: - WebAppInfoTable

extension CacheManager {
    
    /// 获取webapp信息
    internal func webappInfo() -> WebAppInfo? {
        let webapp = WebAppInfo()
        let result = query { (database) -> Bool in
            let select = "select * from \(WebAppInfoTable.TableName)"
            var stat: OpaquePointer? = nil
            var result = false
            
            if sqlite3_prepare_v2(database, select, -1, &stat, nil) == SQLITE_OK {
                if sqlite3_step(stat) == SQLITE_ROW {
                    if let name = sqlite3_column_text(stat, 0) {
                        webapp.name = String(cString: name)
                    }
                    if let currentVersion = sqlite3_column_text(stat, 1) {
                        webapp.currentVersion = String(cString: currentVersion)
                    }
                    if let latestVersion = sqlite3_column_text(stat, 2) {
                        webapp.latestVersion = String(cString: latestVersion)
                    }
                    if let remoteUrl = sqlite3_column_text(stat, 3) {
                        webapp.remoteUrl = String(cString: remoteUrl)
                    }
                    if let localPath = sqlite3_column_text(stat, 4) {
                        webapp.localPath = String(cString: localPath)
                    }
                    if let size = sqlite3_column_text(stat, 5) {
                        webapp.size = String(cString: size)
                    }
                    result = true
                }
                sqlite3_finalize(stat)
            } else {
                logError("prepare fail: \(String(cString: sqlite3_errmsg(database)))")
            }
            return result
        }
        
        if result {
            return webapp
        } else {
            return nil
        }
    }
    
    /// 更新webapp信息
    @discardableResult internal func updateWebappInfo(_ info: WebAppInfo) -> Bool {
        return query({ (database) -> Bool in
            let insert = "insert or replace into \(WebAppInfoTable.TableName) values ('\(info.name)','\(info.currentVersion)','\(info.latestVersion)','\(info.remoteUrl)','\(info.localPath)','\(info.size)');"
            if sqlite3_exec(database, insert, nil, nil, nil) != SQLITE_OK {
                logError("insert fail: \(String(cString: sqlite3_errmsg(database)))")
                return false
            }
            return true
        })
    }
}

// MARK: - WebAppResourceTable

extension CacheManager {
    
}

// MARK: - Helper

extension CacheManager {
    fileprivate func query(_ block: (_ database: OpaquePointer?) -> Bool) -> Bool {
        var result: Bool = true
        self.queue.sync {
            var database: OpaquePointer? = nil
            if sqlite3_open(sqlPath, &database) != SQLITE_OK {
                logError("打开数据库失败: \(String(cString: sqlite3_errmsg(database)))")
                result = false
                return
            }
            
            result = block(database)
            
            if sqlite3_close(database) != SQLITE_OK {
                logError("关闭数据库失败: \(String(cString: sqlite3_errmsg(database)))")
            }
        }
        return result
    }
}
