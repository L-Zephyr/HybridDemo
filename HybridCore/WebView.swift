//
//  WebView.swift
//  Hybrid
//
//  Created by LZephyr on 2017/4/5.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import UIKit
import GCDWebServer
import ZipArchive

class WebView: WKWebView {

    // MARK: - Public
    
    public override func loadFileURL(_ URL: URL, allowingReadAccessTo readAccessURL: URL) -> WKNavigation? {
        if #available(iOS 9.0, *) {
            return super.loadFileURL(URL, allowingReadAccessTo: readAccessURL)
        } else {
            // readAccessURL必须是文件夹，且包含文件URL
            if !Util.isFolder(url: readAccessURL) {
                LogError("`readAccessURL` must reference to a foler url!")
                return nil
            }
            
            var relationship: FileManager.URLRelationship = .other
            do {
                try FileManager.default.getRelationship(&relationship, ofDirectoryAt: readAccessURL, toItemAt: URL)
            } catch {
                LogError("Get file relation ship error: \(error)")
            }
            
            if relationship == .other {
                LogError("`readAccessURL` must contain the file `URL`")
                return nil
            }
            
            // 启动HTTP Server
            let port: UInt = 8008
            WebView.server.addGETHandler(forBasePath: "/", directoryPath: readAccessURL.path, indexFilename: nil, cacheAge: 3600, allowRangeRequests: true)
            if !WebView.server.isRunning {
                WebView.server.start(withPort: port, bonjourName: nil)
            }
            
            let relatePath = URL.path.substring(from: readAccessURL.path.endIndex)
            var urlConponment = URLComponents(string: "http://127.0.0.1")
            urlConponment?.port = Int(port)
            urlConponment?.path = relatePath
            if let url = urlConponment?.url {
                return self.load(URLRequest(url: url))
            } else {
                return nil
            }
        }
    }
    
    /// 通过URL加载资源
    ///
    /// - Parameter url: 资源URL，支持网络资源、本地资源压缩包、本地文件夹
    public func load(url: URL) {
        if url.isFileURL {
            if Util.isZip(url: url) { // 指向一个本地的资源压缩包
                if let localPath = ResourceManager.shared.localPath(with: url) {
                    load(url: localPath)
                }
            } else if Util.isFolder(url: url) { // 指向一个本地的文件夹
                // 读取webapp_info.json文件
                let infoUrl = url.appendingPathComponent("webapp_info.json")
                if FileManager.default.fileExists(atPath: infoUrl.path) {
                    if let profile = Util.loadJsonObject(fromUrl: infoUrl), let entrance = profile["entrance"] as? String {
                        LogVerbose("Local Web path: '\(url.path)'\nEntrance: '\(entrance)'")
                        let entranceUrl = url.appendingPathComponent(entrance)
                        _ = loadFileURL(entranceUrl, allowingReadAccessTo: url)
                    }
                } else {
                    LogError("Profile file `webapp_info.json` not found in \(url.path)")
                    return
                }
            } else { // 加载一个单独的本地文件
                let request = URLRequest(url: url)
                self.load(request)
            }
        } else {
            let request = URLRequest(url: url)
            self.load(request)
        }
    }
    
    /// 通过URL字符串加载资源
    ///
    /// - Parameter urlString: 资源URL，支持网络资源、本地资源压缩包、本地文件夹
    public func load(urlString: String) {
        if let url = URL(string: urlString) {
            load(url: url)
        } else {
            LogError("Url \(urlString) is not valid")
        }
    }
    
    init() {
        super.init(frame: CGRect.zero, configuration: WKWebViewConfiguration())
        bridge = ReflectJavascriptBridge(self)
    }
    
    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        bridge = ReflectJavascriptBridge(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private
    
    fileprivate var bridge: ReflectJavascriptBridge?
    
    fileprivate static let server: GCDWebServer = GCDWebServer()
}
