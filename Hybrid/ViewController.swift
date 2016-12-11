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
        let web = WebContainer()
        web.frame = CGRect(x: 0, y: 20, width: self.view.frame.size.width, height: self.view.frame.size.height)
        self.view.addSubview(web)
        
        // load local resouce
        TimeLogger.sharedLogger.startTimeLog()
        let localPath = Bundle.main.path(forResource: "main", ofType: "html")
        web.loadRequest(URLRequest(url: URL(string: localPath!)!))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

