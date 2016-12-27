//
//  String+Extension.swift
//  Hybrid
//
//  Created by LZephyr on 2016/12/11.
//  Copyright © 2016年 LZephyr. All rights reserved.
//

import Foundation

extension String {
    
    internal func md5() -> String {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        CC_MD5(str!, strLen, result)
        let hash = NSMutableString()
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i])
        }
        result.deinitialize()
        return (hash as String)
    }
    
    /// 获取相对于path的相对路径，path不能带有scheme
    internal func relativePath(toPath path: String) -> String {
        var components = self.components(separatedBy: "/").flatMap { (component) -> String? in
            return component.isEmpty ? nil : component
        }
        let anchorComponents = path.components(separatedBy: "/").flatMap { (component) -> String? in
            return component.isEmpty ? nil : component
        }
        
        let from = components.count - anchorComponents.count
        
        if from <= 0 {
            return ""
        }
        
        components.removeSubrange(0..<(components.count - from))
        let relativePath = "/" + components.joined(separator: "/")
        
        return relativePath
    }
    
    internal func urlEncoding() -> String? {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
    }
}
