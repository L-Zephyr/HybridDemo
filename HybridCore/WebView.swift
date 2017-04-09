//
//  WebView.swift
//  Hybrid
//
//  Created by LZephyr on 2017/4/5.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import UIKit

class WebView: WKWebView {

    // MARK: - Public
    
    public func load(url: String) {
        let request = URLRequest(url: URL(string: url)!)
        self.load(request)
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
    
}
