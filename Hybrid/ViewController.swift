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
        
        Router.shared.delegate = self
        
        TimeLogger.sharedLogger.startTimeLog()
        
        if let preload = Bundle.main.resourceURL?.appendingPathComponent("HybridResource") {
            HybridConfig.resourcePreloadPath = preload.path
        }
                
        if let resUrl = Bundle.main.resourceURL {
            let url = resUrl.appendingPathComponent("HybridResource").appendingPathComponent("route.json")
            HybridConfig.routeFilePath = url.path
        }

        if let web = Router.shared.webView(routeUrl: "/main") {
            web.frame = CGRect(x: 0, y: 44, width: self.view.frame.size.width, height: self.view.frame.size.height - 44)
            self.view.addSubview(web)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: HybridRouterDelegate {
    func viewController(for routeUrl: String, params: [String : String]) -> UIViewController? {
        return nil
    }
}
