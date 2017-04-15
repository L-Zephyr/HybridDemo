//
//  Logger.swift
//  Hybrid
//
//  Created by LZephyr on 2016/12/27.
//  Copyright © 2016年 LZephyr. All rights reserved.
//

import UIKit

enum LoggerLevel: Int {
    case Verbose = 0
    case Info = 1
    case Warning = 2
    case Error = 3
}

internal var LogLevel: LoggerLevel = .Warning

fileprivate func printLog(withLevel level: LoggerLevel, log: String) {
    let levelNames = ["Verbose", "Info", "Warning", "Error"]
    print("[\(levelNames[level.rawValue])]: \(log)")
}

internal func LogVerbose(_ log: String) {
    if LogLevel.rawValue <= LoggerLevel.Verbose.rawValue {
        printLog(withLevel: .Verbose, log: log)
    }
}

internal func LogInfo(_ log: String) {
    if LogLevel.rawValue <= LoggerLevel.Info.rawValue {
        printLog(withLevel: .Info, log: log)
    }
}

internal func LogWarning(_ log: String) {
    if LogLevel.rawValue <= LoggerLevel.Warning.rawValue {
        printLog(withLevel: .Warning, log: log)
    }
}

internal func LogError(_ log: String) {
    if LogLevel.rawValue <= LoggerLevel.Error.rawValue {
        printLog(withLevel: .Error, log: log)
    }
}
