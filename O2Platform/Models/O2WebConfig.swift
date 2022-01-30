//
//  O2WebConfig.swift
//  O2Platform
//
//  Created by FancyLou on 2022/1/30.
//  Copyright © 2022 zoneland. All rights reserved.
//

import HandyJSON

open class  O2WebConfig: NSObject, HandyJSON , NSCoding {
    // im聊天配置
    open var imConfig: IMConfig?
    // token名称
    @objc open var tokenName: String?
    
    // 语言 如：zh-CN
    @objc open var language: String?
    
    
    public func encode(with aCoder: NSCoder) {
        if tokenName != nil {
            aCoder.encode(tokenName, forKey: "tokenName")
        }
        
        if language != nil {
            aCoder.encode(language, forKey: "language")
        }
        
        if imConfig != nil {
            aCoder.encode(imConfig, forKey: "imConfig")
        }
        
        
    }
    
    public required init?(coder aDecoder: NSCoder) {
        imConfig = aDecoder.decodeObject(forKey: "imConfig") as? IMConfig
        language = aDecoder.decodeObject(forKey: "language") as? String
        tokenName = aDecoder.decodeObject(forKey: "tokenName") as? String
    }
    
    required public override init() {}
    
    open override var description: String {
        return toJSONString(prettyPrint: true) ?? ""
    }
}
