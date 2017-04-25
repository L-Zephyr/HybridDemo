//
//  DownloadTask.swift
//  Hybrid
//
//  Created by LZephyr on 2017/4/22.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import UIKit
import ZipArchive

class DownloadTask: NSObject {
    
    //
    typealias CompletionCallback = (_ desUrl: URL?, _ error: Error?) -> Void
    
    /// 创建并启动一个下载任务
    ///
    /// - Parameters:
    ///   - sourceUrl:  下载文件的URL
    ///   - toUrl:      保存到本地的位置
    ///   - completion: 下载完成的回调
    /// - Returns:      下载任务DownloadTask实例
    public class func startDownloadTask(in session: URLSession,
                                        downloadUrl: URL,
                                        routeUrl: String,
                                        completion: @escaping CompletionCallback) -> DownloadTask {
        let task = DownloadTask(session: session, downloadUrl: downloadUrl, routeUrl: routeUrl)
        task.addCompletionCallback(completion)
        task.resume()
        return task
    }
    
    /// 返回当前正在下载文件的URL字符串
    public var downloadingUrl: String {
        return downloadUrl.absoluteString
    }
    
    /// 添加一个下载结束时的回调
    ///
    /// - Parameter block: 下载结束时调用的闭包，desUrl: 下载文件的保存位置，error: 是否发生错误
    public func addCompletionCallback(_ block: @escaping CompletionCallback) {
        completionBlocks.append(block)
    }
    
    /// 开始下载
    public func resume() {
        task?.resume()
    }
    
    /// 暂停下载
    public func suspend() {
        task?.suspend()
    }
    
    /// 取消下载
    public func cancel() {
        task?.cancel()
    }
    
    init(session: URLSession, downloadUrl: URL, routeUrl: String) {
        self.routeUrl = routeUrl
        self.downloadUrl = downloadUrl
        
        super.init()
        
        task = session.downloadTask(with: downloadUrl)
    }
    
    // MARK: - Private
    
    fileprivate var downloadUrl: URL
    fileprivate var routeUrl: String
    fileprivate var task: URLSessionDownloadTask? = nil
    fileprivate var completionBlocks: [CompletionCallback] = []
    
    fileprivate func callback(_ desUrl: URL?, _ error: Error?) {
        for callback in completionBlocks {
            callback(desUrl, error)
        }
        completionBlocks.removeAll()
    }
}

// MARK: - URLSessionDownloadDelegate

extension DownloadTask: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let webappPath = Util.webappPath else {
            callback(nil, NSError(domain: "Can not access to 'Application Support/Hybrid/webapp'", code: 6001, userInfo: nil))
            return
        }
        
        let zip = ZipArchive()
        let localUrl = webappPath.appendingPathComponent(routeUrl.md5())
        if zip.unzipOpenFile(location.path) && zip.unzipFile(to: localUrl.path, overWrite: true) {
            // 将webapp储存到数据库
            // FIXME: 插入数据库的时机和方式可以优化
            let webapp = WebappItem()
            webapp.routeUrl = routeUrl
            webapp.localPath = localUrl.path
            webapp.version = Router.shared.version(for: routeUrl) ?? ""
            ResourceManager.shared.saveWebapp(webapp)
            
            callback(localUrl, nil)
        } else {
            LogError("Unzip file '\(location.path)' failed")
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            callback(nil, error)
        }
    }
}