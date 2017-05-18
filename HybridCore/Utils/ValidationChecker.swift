//
//  ValidationChecker.swift
//  Hybrid
//
//  Created by LZephyr on 2017/5/17.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import UIKit
import CryptoSwift

internal class ValidationChecker {
    
    /// 校验资源包是否被篡改
    ///
    /// - Parameters:
    ///   - path:        资源包的位置
    ///   - encrypedMD5: 资源包信息中加密的MD5值
    ///   - key:         AES加密所用的Key
    /// - Returns:       校验成功返回true，失败返回false
    class func validateFile(_ path: URL, with encrypedMD5: String, using key: String) -> Bool {
        do {
            let fileData = try Data(contentsOf: path)
            if let data = encrypedMD5.data(using: .utf8) {
                let fileMD5 = try AES128Encrypt(data, key: key)
                if fileMD5 == fileData.md5() {
                    return true
                }
            }
        } catch {
            LogError("\(error)")
            return false
        }
        
        return false
    }
    
    /// 128位AES加密
    ///
    /// - Parameters:
    ///   - data:  待加密的数据
    ///   - key:   加密所用的Key值
    /// - Returns: 返回加密成功后的数据
    /// - Throws:  加密失败抛出异常
    private class func AES128Encrypt(_ data: Data, key: String) throws -> Data {
        do {
            let aes = try AES(key: key, iv: key, blockMode: .CBC, padding: PKCS7())
            let encrypt = try aes.encrypt(data)
            return Data(bytes: encrypt)
        } catch {
            throw error
        }
    }
    
    /// 128位AES解密
    ///
    /// - Parameters:
    ///   - data:  待解密的数据
    ///   - key:   解密所用的Key值
    /// - Returns: 返回解密成功后的数据
    /// - Throws:  解密失败抛出异常
    private class func AES128Decrypt(_ data: Data, key: String) throws -> Data {
        do {
            let aes = try AES(key: key, iv: key, blockMode: .CBC, padding: PKCS7())
            let decrypt = try aes.decrypt(data)
            return Data(bytes: decrypt)
        } catch {
            throw error
        }
    }
}
