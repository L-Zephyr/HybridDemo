//
//  WebContainer.swift
//  Hybrid
//
//  Created by LZephyr on 2016/12/11.
//  Copyright © 2016年 LZephyr. All rights reserved.
//

import UIKit

class WebContainer: UIWebView {
    
    // MARK: - Public
    
    public func load(url: String) {
        let request = URLRequest(url: URL(string: url)!)
        self.loadRequest(request)
    }
    
    // MARK: - Private
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self
        backgroundColor = UIColor.white
        self.stringByEvaluatingJavaScript(from: "document.documentElement.style.webkitTouchCallout='none';")
        URLProtocol.registerClass(FileInterceptor.self)
    }
    
    deinit {
        URLProtocol.registerClass(FileInterceptor.self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}

// MARK: - UIWebViewDelegate

extension WebContainer: UIWebViewDelegate {
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        print("\(request.url?.absoluteString)")
        return true
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        TimeLogger.sharedLogger.logTime()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        TimeLogger.sharedLogger.logTime()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        
    }
}
