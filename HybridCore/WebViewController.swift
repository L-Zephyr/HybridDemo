//
//  WebViewController.swift
//  Hybrid
//
//  Created by LZephyr on 2017/4/20.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {
    
    init(webView: WebView) {
        super.init(nibName: nil, bundle: nil)
        self.webView = webView
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let webView = webView {
            self.view.addSubview(webView)
            webView.frame = self.view.bounds
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Private
    
    fileprivate var webView: WebView? = nil
}
