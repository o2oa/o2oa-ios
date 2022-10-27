//
//  RSAUtils.swift
//  O2Platform
//
//  Created by FancyLou on 2022/10/27.
//  Copyright © 2022 zoneland. All rights reserved.
//
import SwiftyRSA
import CocoaLumberjack



class RSAUtils {
    
    /// rsa 加密
    static func rsa_encrypt(_ str:String, publicKey: String) -> String {
        var reslutStr = ""
        do{
            let rsa_publicKey = try PublicKey(base64Encoded: publicKey)
            let clear = try ClearMessage(string: str, using: .utf8)
            reslutStr = try clear.encrypted(with: rsa_publicKey, padding: .PKCS1).base64String
        }catch{
            DDLogError("RSA加密失败 \(error)")
        }
        return reslutStr
    }
    
    /// rsa解密
//    class func rsa_decrypt(_ str:String) -> String{
//        var reslutStr = ""
//        let enData = Data(base64Encoded: str, options: .ignoreUnknownCharacters)!
//        do{
//            let rsa_privateKey = try PrivateKey(pemEncoded: privkey)
//            let data = try EncryptedMessage(data: enData).decrypted(with: rsa_privateKey, padding: .PKCS1).data
//            reslutStr = String(bytes: data.bytes, encoding: .utf8) ?? ""
//        }catch{
//            print("RSA解密失败")
//        }
//        return reslutStr
//    }
}

