//
//  FileInterceptor.swift
//  Hybrid
//
//  Created by LZephyr on 2016/12/11.
//  Copyright © 2016年 LZephyr. All rights reserved.
//

import UIKit
import Foundation

/*
 拦截浏览器中对静态资源的请求，优先用本地资源进行响应
 */

class FileInterceptor: URLProtocol {
    
    fileprivate var session: URLSession? = nil
    fileprivate var fileHandler: FileHandle? = nil
    fileprivate var filename: String = ""
    fileprivate var downloadTask: URLSessionTask? = nil
    
    // 1.判断哪些请求可以被该拦截器处理
    // 拦截来自浏览器的http/https请求
    override class func canInit(with request: URLRequest) -> Bool {
        guard let userAgent = request.allHTTPHeaderFields?["User-Agent"] else {
            return false
        }
        guard userAgent.hasPrefix("Mozilla") else { // 只拦截浏览器的请求
            return false
        }
        guard let ext = request.url?.pathExtension, HybridConfig.cacheTypeWhiteList.contains(ext), !HybridConfig.cacheTypeBlackList.contains(ext) else {
            return false
        }
        
        if let scheme = request.url?.scheme, scheme.uppercased() == "HTTP" || scheme.uppercased() == "HTTPS" {
            LogVerbose("拦截请求: \(request.url!.absoluteString)")
            return true
        }
        
        return false
    }
    
    // 2.处理请求对象
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    // 3.得到请求对象之后初始化一个URLProtocol对象
    override init(request: URLRequest, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
        super.init(request: request, cachedResponse: cachedResponse, client: client)
    }
    
    // 4.开始网络请求,完成后将结果回调给client
    override func startLoading() {
        guard let remoteUrl = self.request.url else {
            self.client?.urlProtocol(self, didFailWithError: Errors.httpRequestError)
            return
        }
        
        filename = remoteUrl.absoluteString.md5()
        // 命中本地缓存
        if let cacheData = CacheManager.shared.localCacheData(withRemoteUrl: remoteUrl) {
            LogVerbose("请求\(remoteUrl.absoluteString)命中本地缓存")
            let httpResponse = HTTPURLResponse(url: remoteUrl, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: [:])
            self.client?.urlProtocol(self, didReceive: httpResponse!, cacheStoragePolicy: URLCache.StoragePolicy.notAllowed)
            self.client?.urlProtocol(self, didLoad: cacheData)
            self.client?.urlProtocolDidFinishLoading(self)
        } else { // 否则走网络请求
            LogVerbose("请求\(remoteUrl.absoluteString)未命中缓存，继续网络请求")
            if session == nil {
                session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
            }
            
            FileManager.default.createFile(atPath: Util.tempPath + filename, contents: nil, attributes: nil)
            fileHandler = FileHandle(forWritingAtPath: Util.tempPath + filename)
            
            let task = session?.dataTask(with: request)
            task?.resume()
        }
    }
    
    // 5.终止网络请求
    override func stopLoading() {
        self.client?.urlProtocolDidFinishLoading(self)
        self.downloadTask?.cancel()
    }
}

extension FileInterceptor: URLSessionDataDelegate {
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: URLCache.StoragePolicy.notAllowed)
        completionHandler(URLSession.ResponseDisposition.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.fileHandler?.write(data)
        self.client?.urlProtocol(self, didLoad: data)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error == nil {
            self.fileHandler?.closeFile()
            self.fileHandler = nil
            
            // TODO: 增加协议控制资源是否应该被缓存
            if let url = task.currentRequest?.url {
                CacheManager.shared.saveFile(atTmpPath: Util.tempPath + self.filename, forRemoteUrl: url)
            }
            self.client?.urlProtocolDidFinishLoading(self)
        } else {
            logError("网络请求失败: \(error)")
            do {
                if FileManager.default.fileExists(atPath: Util.tempPath + self.filename) {
                    try FileManager.default.removeItem(atPath: Util.tempPath + self.filename)
                }
            } catch {
                logError("\(error)")
            }
            self.client?.urlProtocol(self, didFailWithError: error!)
        }
    }
}
