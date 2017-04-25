//
//  ResourceManager.swift
//  Hybrid
//
//  Created by LZephyr on 2017/4/16.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import UIKit
import ZipArchive

internal class ResourceManager: NSObject {
    
    public static let shared = ResourceManager()
    
    public func webapp(withRoute url: String) -> WebappItem? {
        return selectWebapp(routeUrl: url)
    }
    
    public func saveWebapp(_ webapp: WebappItem) {
        insert(webapp)
    }
    
    // Deprecated
    /// 获取资源包的本地缓存位置, 如果不存在则解压至一个本地路径
    ///
    /// - Parameter url: 资源解压后的路径
//    public func localPath(withZip url: URL) -> URL? {
//        guard let zipRelatedUrl = url.relatedTo(Bundle.main.resourceURL) else {
//            LogError("Can not get related path")
//            return nil
//        }
//        
//        if Util.isZip(url: url) {
//            if let localRelatedPath = selectLocalPath(zipRelatedUrl) { // 已解压到本地
//                return Util.appSpportPath?.appendingPathComponent(localRelatedPath.path)
//            } else if let localPath = Util.webappPath, let appPath = Util.appSpportPath { // 否则解压到本地，并保存位置信息
//                // unzip
//                guard let relatedUrl = localPath.appendingPathComponent(url.path.md5()).relatedTo(appPath),
//                      let fullUrl = Util.appSpportPath?.appendingPathComponent(relatedUrl.path) else {
//                    return nil
//                }
//                
//                let zip = ZipArchive()
//                if zip.unzipOpenFile(url.path) && zip.unzipFile(to: fullUrl.path, overWrite: true) {
////                    insert(zipUrl: zipRelatedUrl, localUrl: relatedUrl)
//                    return fullUrl
//                }
//            }
//        }
//        return nil
//    }
    
    /// 下载一个资源包
    ///
    /// - Parameters:
    ///   - url:     资源包下载url
    ///   - success: 下载成功回调
    ///   - failure: 下载失败回调
    @discardableResult public func downloadPackage(url: URL, success: ((URL) -> Void)?, failure: ((Error) -> Void)?) -> DownloadTask? {
        let callback = { (desUrl: URL?, error: Error?) in
            if let error = error {
                failure?(error)
            } else if let desUrl = desUrl {
                success?(desUrl)
            } else {
                failure?(NSError(domain: "Download file location unkown", code: 6000, userInfo: nil))
            }
        }
        
        // 下载任务已存在
        if let downloadingTask = downloadingTasks[url.absoluteString] {
            downloadingTask.addCompletionCallback(callback)
            return downloadingTask
        }
        
        if let routeUrl = Router.shared.routeUrl(with: url), let session = session {
            let task = DownloadTask.startDownloadTask(in: session, downloadUrl: url, routeUrl: routeUrl, completion: callback)
            downloadingTasks[url.absoluteString] = task
            return task
        }
        return nil
    }
    
    override init() {
        super.init()
        initDatabase()
        session = URLSession(configuration: URLSessionConfiguration(), delegate: self, delegateQueue: nil)
    }
    
    // MARK: - Private
    
    fileprivate let sqlQueue: DispatchQueue = DispatchQueue(label: "Hybrid.com.database")
    fileprivate var downloadingTasks: [String : DownloadTask] = [:] // URL字符串作为key
    fileprivate var session: URLSession? = nil
}

// MARK: - URLSessionDownloadDelegate

extension ResourceManager: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        if let url = downloadTask.originalRequest?.url?.absoluteString, let task = downloadingTasks[url] {
            task.urlSession(session, downloadTask: downloadTask, didFinishDownloadingTo: location)
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let url = task.originalRequest?.url?.absoluteString, let downloadingTask = downloadingTasks[url] {
            downloadingTask.urlSession(session, task: task, didCompleteWithError: error)
            downloadingTasks.removeValue(forKey: url)
        }
    }
}

// MARK: - Data Base

internal extension ResourceManager {
    
    private struct Table {
        static let Name = "ResourceTable"
        static let RouteUrl = "route_url" // key
        static let ZipPath = "zip_path"
        static let LocalPath = "local_path"
        static let Version = "version"
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
                "\(Table.RouteUrl) text primary key, " +
                "\(Table.ZipPath) text, " +
                "\(Table.LocalPath) text, " +
                "\(Table.Version) text);"
            if sqlite3_exec(database, createTable, nil, nil, nil) != SQLITE_OK {
                LogError("Fail to create database table: \(String(cString: sqlite3_errmsg(database)))")
                return false
            }
            
            return true
        }
    }
    
    /// 根据Route URL查询资源包信息
    ///
    /// - Parameter routeUrl: 路由URL
    /// - Returns:            包含资源包信息的`WebappItem`实例
    fileprivate func selectWebapp(routeUrl: String) -> WebappItem? {
        var webapp: WebappItem? = nil
        
        let sema = DispatchSemaphore(value: 0)
        query({ (database) -> Bool in
            let sql = "select * from \(Table.Name) where \(Table.RouteUrl)=\"\(routeUrl)\";"
            var stat: OpaquePointer? = nil
            var result = false
            
            if sqlite3_prepare_v2(database, sql, -1, &stat, nil) == SQLITE_OK {
                if sqlite3_step(stat) == SQLITE_ROW {
                    webapp = WebappItem()
                    if let routeUrl = sqlite3_column_text(stat, 0) {
                        webapp?.routeUrl = String(cString: routeUrl)
                    }
                    if let zipPath = sqlite3_column_text(stat, 1) {
                        webapp?.zipPath = String(cString: zipPath)
                    }
                    if let localPath = sqlite3_column_text(stat, 2), let rootPath = Util.appSpportPath {
                        webapp?.localPath = rootPath.appendingPathComponent(String(cString: localPath)).path
                    }
                    if let version = sqlite3_column_text(stat, 3) {
                        webapp?.version = String(cString: version)
                    }
                    result = true
                }
            }
            sqlite3_finalize(stat)
            sema.signal()
            
            return result
        })
        
        sema.wait()
        
        return webapp
    }
    
    /// 插入一条资源包信息
    ///
    /// - Parameter item: 包含资源包信息的`WebappItem`实例
    /// - Returns:        插入成功返回true，否则返回false
    @discardableResult fileprivate func insert(_ item: WebappItem) -> Bool {
        return query({ (database) -> Bool in
            guard let relativePath = item.localUrl.relatedTo(Util.appSpportPath)?.path else {
                return false
            }
            let sql = "insert or replace into \(Table.Name) values ('\(item.routeUrl)', '\(item.zipPath)', '\(relativePath)', '\(item.version)');"
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
    @discardableResult fileprivate func delete(routeUrl: String) -> Bool {
        return query({ (database) -> Bool in
            let sql = "delete from \(Table.Name) where \(Table.RouteUrl)='\(routeUrl)';"
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
    
    // ---------
    
    /// 根据压缩包位置获取本地解压后的路径
    ///
    /// - Parameter url: 资源压缩包路径
    /// - Returns:       解压后的文件夹路径
//    fileprivate func selectLocalPath(withZip zipUrl: URL) -> URL? {
//        var url: URL? = nil
//        
//        let sema = DispatchSemaphore(value: 0)
//        query({ (database) -> Bool in
//            let sql = "select * from \(Table.Name) where \(Table.ZipPath)=\"\(zipUrl.path)\";"
//            var stat: OpaquePointer? = nil
//            var result = false
//            
//            if sqlite3_prepare_v2(database, sql, -1, &stat, nil) == SQLITE_OK {
//                if sqlite3_step(stat) == SQLITE_ROW, let path = sqlite3_column_text(stat, 1) {
//                    url = URL(fileURLWithPath: String(cString: path))
//                    result = true
//                }
//            }
//            sqlite3_finalize(stat)
//            sema.signal()
//            
//            return result
//        })
//        
//        sema.wait()
//        
//        return url
//    }
    
    /// 根据Route URL查找资源包的本地解压路径
    ///
    /// - Parameter routeUrl: Route URL
    /// - Returns:            资源包在本地解压保存的路径
//    fileprivate func selectLocalPath(_ routeUrl: String) -> URL? {
//        var url: URL? = nil
//        
//        let sema = DispatchSemaphore(value: 0)
//        query({ (database) -> Bool in
//            let sql = "select * from \(Table.Name) where \(Table.RouteUrl)=\"\(routeUrl)\";"
//            var stat: OpaquePointer? = nil
//            var result = false
//            
//            if sqlite3_prepare_v2(database, sql, -1, &stat, nil) == SQLITE_OK {
//                if sqlite3_step(stat) == SQLITE_ROW, let path = sqlite3_column_text(stat, 2) {
//                    url = URL(fileURLWithPath: String(cString: path))
//                    result = true
//                }
//            }
//            sqlite3_finalize(stat)
//            sema.signal()
//            
//            return result
//        })
//        
//        sema.wait()
//        
//        return url
//    }
    
    /// 保存压缩包和解压信息
    ///
    /// - Parameters:
    ///   - zipUrl:   压缩包路径
    ///   - localUrl: 解压后的路径
    /// - Returns:    保存成功返回true，否则false
//    @discardableResult fileprivate func insert(routeUrl: String, zipUrl: URL, localUrl: URL) -> Bool {
//        return query({ (database) -> Bool in
//            let sql = "insert or replace into \(Table.Name) values ('\(routeUrl)', '\(zipUrl.path)', '\(localUrl.path)');"
//            if sqlite3_exec(database, sql, nil, nil, nil) != SQLITE_OK {
//                LogError("Fail to insert into Table \(Table.Name): \(String(cString: sqlite3_errmsg(database)))")
//                return false
//            }
//            return true
//        })
//    }
}
