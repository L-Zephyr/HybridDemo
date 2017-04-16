//
//  ViewController.swift
//  Hybrid
//
//  Created by LZephyr on 2016/12/11.
//  Copyright © 2016年 LZephyr. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let web = WebView()
        web.frame = CGRect(x: 0, y: 20, width: self.view.frame.size.width, height: self.view.frame.size.height)
        self.view.addSubview(web)
        
        // load local resouce
        TimeLogger.sharedLogger.startTimeLog()
        
//        let remoteUrl = "http://localhost:3000/main2.html"
//        web.load(url: remoteUrl)
        
//        if let resUrl = Bundle.main.resourceURL {
//            let dirUrl = resUrl.appendingPathComponent("HybridResource").appendingPathComponent("webapp")
//            web.load(url: dirUrl)
//        }
        
        if let resUrl = Bundle.main.resourceURL {
            let dirUrl = resUrl.appendingPathComponent("HybridResource").appendingPathComponent("webapp.zip")
            web.load(url: dirUrl)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
