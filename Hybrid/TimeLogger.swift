//
//  TimerLogger.swift
//  Hybrid
//
//  Created by LZephyr on 2016/12/11.
//  Copyright © 2016年 LZephyr. All rights reserved.
//

import UIKit

class TimeLogger: NSObject {
    static let sharedLogger: TimeLogger = TimeLogger()
    static var stepTime: TimeInterval = 0
    
    func startTimeLog() {
        TimeLogger.stepTime = Date().timeIntervalSince1970
        print("start")
    }
    
    func logTime() {
        print("pass \(Date().timeIntervalSince1970 - TimeLogger.stepTime) s")
        TimeLogger.stepTime = Date().timeIntervalSince1970
    }
    
    func stopTimeLog() {
        print("stop")
    }
}
