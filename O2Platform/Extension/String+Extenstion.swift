//
//  String+Extenstion.swift
//  o2app
//
//  Created by 刘振兴 on 2017/8/18.
//  Copyright © 2017年 zone. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    
    /// 获取扩展名 比如 png gif 等
    public var pathExtension: String {
        guard let url = URL(string: self) else { return "" }
        return url.pathExtension.isEmpty ? "" : url.pathExtension
    }
    
    /// 获取文件名称
    public var pathFileName: String {
        guard let url = URL(string: self) else {
            return ""
        }
        return url.lastPathComponent
    }
    
    /// EZSE: Checks if string is empty or consists only of whitespace and newline characters
    public var isBlank: Bool {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty
    }
    
    /// EZSE: split string using a spearator string, returns an array of string
    public func split(_ separator: String) -> [String] {
        return self.components(separatedBy: separator).filter {
            !$0.trim().isEmpty
        }
    }
    
    /// EZSE: split string with delimiters, returns an array of string
    public func split(_ characters: CharacterSet) -> [String] {
        return self.components(separatedBy: characters).filter {
            !$0.trim().isEmpty
        }
    }
    
    public func trim(trimNewline: Bool = false) ->String {
        if trimNewline {
            return self.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return self.trimmingCharacters(in: .whitespaces)
    }
    
    /// 字符串时间转 Date
    ///
    /// - Parameter formatter: 字符串时间的格式 yyyy-MM-dd/YYYY-MM-dd/HH:mm:ss/yyyy-MM-dd HH:mm:ss
    /// - Returns: Date
    func toDate(formatter: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = formatter
        let date = dateFormatter.date(from: self)
        return date!
    }
    
    
    var length: Int {
        return self.count
    }
    
    func subString(from: Int, to: Int? = nil) -> String {
        if from >= self.length {
            return self
        }
        let startIndex = self.index(self.startIndex, offsetBy: from)
        if to == nil {
            return String(self[startIndex..<self.endIndex])
        }else {
            if from >= to! {
                return String(self[startIndex..<self.endIndex])
            }else {
                let endIndex = index(self.startIndex, offsetBy: to!)
                return String(self[startIndex..<endIndex])
            }
        }
    }
    
    /// 计算文本的高度
    func textHeight(fontSize: CGFloat, width: CGFloat) -> CGFloat {
        return self.boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [.font: UIFont.systemFont(ofSize: fontSize)], context: nil).size.height
    }
    
    // MARK: - URL允许的字符
    var urlEscaped: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)  ?? ""
    }
    
    var urlEncoded: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    }
   
    func urlEncoding() -> String {
        let toSearchword = (self as NSString).addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: #"?!@#$^&%*+,:;='"`<>()[]{}/\|"#).inverted)
        return toSearchword as String? ?? ""
    }
        
    
    
    
    // MARK:- 获取字符串的CGSize
    func getSize(with fontSize: CGFloat) -> CGSize {
        let str = self as NSString
        
        let size = CGSize(width: UIScreen.main.bounds.width, height: CGFloat(MAXFLOAT))
        return str.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)], context: nil).size
    }
    
    // MARK: - 根据固定宽度获取字符串在label中的size
    func getSizeWithMaxWidth(fontSize:CGFloat, maxWidth: CGFloat) -> CGSize {
        let size = CGSize(width: maxWidth, height: CGFloat(MAXFLOAT))
        return self.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)], context: nil).size
    }
    
    // MARK:- 获取文本图片
    func getTextImage(_ size:CGSize,textColor tColor:UIColor,backColor bColor:UIColor,textFont tFont:UIFont) -> UIImage? {
        let label = UILabel(frame: CGRect(origin:CGPoint(x:0,y:0), size: size))
        label.textAlignment = .center
        label.textColor = tColor
        label.font = tFont
        label.text = self
        label.backgroundColor = bColor
        UIGraphicsBeginImageContextWithOptions(label.frame.size, true, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        label.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    subscript(r: Range<Int>) -> String {
        get {
            let startIndex = self.index(self.startIndex, offsetBy: r.lowerBound)
            let endIndex = self.index(self.startIndex, offsetBy: r.upperBound)
            
            return String(self[startIndex..<endIndex])
        }
    }
    
    subscript(r: ClosedRange<Int>) -> String {
        get {
            let startIndex = self.index(self.startIndex, offsetBy: r.lowerBound)
            let endIndex = self.index(self.startIndex, offsetBy: r.upperBound)
            
            return String(self[startIndex...endIndex])
        }
    }
    
    static func randomString(length:Int) -> String {
        let charSet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var c = charSet.map { String($0) }
        var s:String = ""
        for _ in (1...length) {
            s.append(c[Int(arc4random()) % c.count])
        }
        return s
    }
    
    /// o2 后台统一的des加密
    func o2DESEncode() -> String? {
        if let encode = desEncrypt(key: O2ConfigInfo.O2_OA_DES_KEY, iv: "12345678", options: (kCCOptionECBMode + kCCOptionPKCS7Padding)) {
            print("解密后的字符串：\(encode)")
            let first = encode.replacingOccurrences(of: "+", with: "-")
            let second = first.replacingOccurrences(of: "/", with: "_")
            let token = second.replacingOccurrences(of: "=", with: "")
            print("安全替换后的字符串：\(token)")
            return token
        }else {
            print("加密错误")
            return nil
        }
    }
    
    /// o2 后台统一的des解密
    func o2DESDecode() -> String? {
        return desDecrypt(key: O2ConfigInfo.O2_OA_DES_KEY, iv: "12345678", options: (kCCOptionECBMode + kCCOptionPKCS7Padding))
    }
    
    /// DES 加密
    func desEncrypt(key:String, iv:String, options:Int = kCCOptionPKCS7Padding) -> String? {
        if let keyData = key.data(using: String.Encoding.utf8),
            let data = self.data(using: String.Encoding.utf8),
            let cryptData    = NSMutableData(length: Int((data.count)) + kCCBlockSizeDES) {


            let keyLength              = size_t(kCCKeySizeDES)
            let operation: CCOperation = UInt32(kCCEncrypt)
            let algoritm:  CCAlgorithm = UInt32(kCCAlgorithmDES)
            let options:   CCOptions   = UInt32(options)



            var numBytesEncrypted :size_t = 0

            let cryptStatus = CCCrypt(operation,
                                      algoritm,
                                      options,
                                      (keyData as NSData).bytes, keyLength,
                                      iv,
                                      (data as NSData).bytes, data.count,
                                      cryptData.mutableBytes, cryptData.length,
                                      &numBytesEncrypted)

            if UInt32(cryptStatus) == UInt32(kCCSuccess) {
                cryptData.length = Int(numBytesEncrypted)
//                    let base64cryptString = cryptData.base64EncodedString(options: .lineLength64Characters)
                let base64cryptString = cryptData.base64EncodedString()
                return base64cryptString

            }
            else {
                return nil
            }
        }
        return nil
    }
    /// DES 解密
    func desDecrypt(key:String, iv:String, options:Int = kCCOptionPKCS7Padding) -> String? {
        if let keyData = key.data(using: String.Encoding.utf8),
            let data = NSData(base64Encoded: self, options: .ignoreUnknownCharacters),
            let cryptData    = NSMutableData(length: Int((data.length)) + kCCBlockSizeDES) {

            let keyLength              = size_t(kCCKeySizeDES)
            let operation: CCOperation = UInt32(kCCDecrypt)
            let algoritm:  CCAlgorithm = UInt32(kCCAlgorithmDES)
            let options:   CCOptions   = UInt32(options)

            var numBytesEncrypted :size_t = 0

            let cryptStatus = CCCrypt(operation,
                                      algoritm,
                                      options,
                                      (keyData as NSData).bytes, keyLength,
                                      iv,
                                      data.bytes, data.length,
                                      cryptData.mutableBytes, cryptData.length,
                                      &numBytesEncrypted)

            if UInt32(cryptStatus) == UInt32(kCCSuccess) {
                cryptData.length = Int(numBytesEncrypted)
                let unencryptedMessage = String(data: cryptData as Data, encoding:String.Encoding.utf8)
                return unencryptedMessage
            }
            else {
                return nil
            }
        }
        return nil
    }
    

    // MARK:- 获取帐号中的中文名称
    func getChinaName() -> String{
        let userName = self
        var strTemp = ""
        if !userName.isBlank{
              let userNameSplit =  userName.split("@");
              if strTemp == "" {
                 strTemp = userNameSplit[0]
              }else{
                  strTemp = strTemp + "," + userNameSplit[0]
              }
              print(strTemp)
         }
        return strTemp
        
    }

    
}
