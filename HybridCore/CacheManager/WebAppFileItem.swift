//
//  WebAppFileItem.swift
//  Hybrid
//
//  Created by LZephyr on 2016/12/20.
//  Copyright © 2016年 LZephyr. All rights reserved.
//

import UIKit

internal struct WebAppFileItem {
    var key: String = ""
    var fullUrl: String = ""
    var localPath: String = ""
    var size: String = ""
}

extension WebAppFileItem: Equatable {
    static func == (lhs: WebAppFileItem, rhs: WebAppFileItem) -> Bool {
        if lhs.key != rhs.key {
            return false
        }
        if lhs.fullUrl != rhs.fullUrl {
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
