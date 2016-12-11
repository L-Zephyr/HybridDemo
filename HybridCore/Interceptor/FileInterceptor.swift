//
//  FileInterceptor.swift
//  Hybrid
//
//  Created by LZephyr on 2016/12/11.
//  Copyright © 2016年 LZephyr. All rights reserved.
//

import UIKit
import Foundation

class FileInterceptor: URLProtocol {
    
    // 1.判断哪些请求可以被该拦截器处理
    // 拦截来自浏览器的http/https请求
    override class func canInit(with request: URLRequest) -> Bool {
        guard let userAgent = request.allHTTPHeaderFields?["User-Agent"] else {
            return false
        }
        guard userAgent.hasPrefix("Mozilla") else {
            return false
        }
        
        if let scheme = request.url?.scheme, scheme.uppercased() == "HTTP" || scheme.uppercased() == "HTTPS" {
            print("拦截\(scheme) \((request.url!.absoluteString as NSString).lastPathComponent)")
            return true
        }
        
        return false
    }
    
    // 2.过滤之后获得要处理的请求(修改Header)
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    // 3.得到请求对象之后初始化一个URLProtocol对象
    override init(request: URLRequest, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
        super.init(request: request, cachedResponse: cachedResponse, client: client)
    }
    
    // 4.开始网络请求,完成后将结果回调给client
    override func startLoading() {
        var request = self.request
        // 优先使用本地缓存进行响应
        if let remoteUrl = request.url?.absoluteString, let localUrl = CacheManager.shared.localFile(withPath: remoteUrl) {
            request.url = URL(string: localUrl)
        }
    }
    
    // 5.终止网络请求
    override func stopLoading() {
        
    }
}

// TODO: - 先这样写，之后考虑将网络请求封装成独立的组件
extension FileInterceptor: URLSessionDelegate {
    
}
