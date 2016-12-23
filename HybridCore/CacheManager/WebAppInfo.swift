//
//  WebAppInfo.swift
//  Hybrid
//
//  Created by LZephyr on 2016/12/22.
//  Copyright © 2016年 LZephyr. All rights reserved.
//

import UIKit

class WebAppInfo {
    var name: String = ""
    var currentVersion: String = ""
    var latestVersion: String = ""
    var remoteUrl: String = ""
    var localPath: String = ""
    var size: String = ""
}

extension WebAppInfo: Equatable {
    static func == (lhs: WebAppInfo, rhs: WebAppInfo) -> Bool {
        if lhs.name != rhs.name {
            return false
        }
        if lhs.currentVersion != rhs.currentVersion {
            return false
        }
        if lhs.latestVersion != rhs.latestVersion {
            return false
        }
        if lhs.remoteUrl != rhs.remoteUrl {
            return false
        }
        if lhs.localPath != rhs.localPath {
            return false
        }
        if lhs.size != rhs.size {
            return false
        }
        return true
    }
}
