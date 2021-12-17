//
//  O2AuthenticationModels.swift
//  O2OA_SDK_Framwork
//
//  Created by FancyLou on 2018/11/7.
//

import Foundation
import HandyJSON

// MARK: - 绑定collect服务器相关的models

/// 注册节点请求的model
public class O2NodeReqModel: DataModel {
    
    required public init() {}
    
    public var description: String {
        return toJSONString(prettyPrint: true) ?? ""
    }
    
    @objc var mobile:String?
    
    @objc var value:String?
    
    @objc var meta:String?
    
}

/// 注册节点返回的model
public class O2NodeResModel: NSObject, DataModel, NSCoding {
    public func encode(with aCoder: NSCoder) {
        if value != nil {
            aCoder.encode(value, forKey: "value")
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        value =  aDecoder.decodeObject(forKey: "value") as? Bool
    }
    
    required public override init() {}
    
    public override var description: String {
        return toJSONString(prettyPrint: true) ?? ""
    }
    var value:Bool?
    
}
// 短信验证码返回
public class O2MobileCodeResModel: NSObject, DataModel, NSCoding {
    public func encode(with aCoder: NSCoder) {
        if answer != nil {
            aCoder.encode(answer, forKey: "answer")
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        answer =  aDecoder.decodeObject(forKey: "answer") as? String
    }
    
    required public override init() {}
    
    public override var description: String {
        return toJSONString(prettyPrint: true) ?? ""
    }
    @objc var answer: String?
}

/// 中心服务器节点Model
public protocol IO2BindUnitModel: HandyJSON, CustomStringConvertible {
    var id:String? { get set }
    
    var pinyin:String? { get set }
    
    var pinyinInitial:String? { get set }
    
    var httpProtocol:String? { get set }
    
    var name:String? { get set }
    
    var centerHost:String? { get set }
    
    var centerContext:String? { get set }
    
    var centerPort:Int? { get set }
    
    var urlMapping: String? { get set }
}

open class O2BindUnitModel: NSObject, DataModel, NSCoding, IO2BindUnitModel {
    @objc open var id:String?
    
    @objc open var pinyin:String?
    
    @objc open var pinyinInitial:String?
    
    @objc open var httpProtocol:String?
    
    @objc open var name:String?
    
    @objc open var centerHost:String?
    
    @objc open var centerContext:String?
    
    open var centerPort:Int?
    
    @objc open var urlMapping: String?
    
    
    /// 代理地址配置
    /// 如： {"qywx.o2oa.net:80":"qywx.o2oa.net/dev/web", "qywx.o2oa.net:20020":"qywx.o2oa.net/dev/app", "qywx.o2oa.net:20030":"qywx.o2oa.net/dev/center"}
    public func urlMappingDecode() -> Dictionary<String, Any>? {
        if urlMapping != nil && !urlMapping!.isBlank {
            if let jsonData = urlMapping?.data(using: .utf8) {
                do {
                    let dc = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
                    return dc as? Dictionary<String, Any>
                } catch _ {
                    print("json 转化 出错")
                }
            }
        }
        return nil
    }
    
    ///
    /// 将服务器地址替换成 urlMapping地址
    public func transUrl2Mapping(url: String) -> String? {
        var result: String? = nil
        if url.isEmpty {
            return result
        }
        if let d = urlMappingDecode() {
            if !d.isEmpty {
                d.keys.forEach { (key) in
                    if url.contains(key) {
                        if let v = d[key] as? String {
                            result = url.replacingOccurrences(of: key, with: v)
                        }
                    }
                }
            }
        }
        return result
    }
    
    
    public func encode(with aCoder: NSCoder) {
        if id != nil {
            aCoder.encode(id, forKey: "id")
        }
        
        if pinyin != nil {
            aCoder.encode(pinyin, forKey: "pinyin")
        }
        
        if httpProtocol != nil {
            aCoder.encode(httpProtocol, forKey: "httpProtocol")
        }
        
        if pinyinInitial != nil {
            aCoder.encode(pinyinInitial, forKey: "pinyinInitial")
        }
        
        if name != nil {
            aCoder.encode(name, forKey: "name")
        }
        
        if centerHost != nil {
            aCoder.encode(centerHost, forKey: "centerHost")
        }
        
        if centerContext != nil {
            aCoder.encode(centerContext, forKey: "centerContext")
        }
        
        if centerPort != nil {
            aCoder.encode(centerPort, forKey: "centerPort")
        }
        if urlMapping != nil {
            aCoder.encode(urlMapping, forKey: "urlMapping")
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObject(forKey: "id") as? String
        pinyin = aDecoder.decodeObject(forKey: "pinyin") as? String
        httpProtocol = aDecoder.decodeObject(forKey: "httpProtocol") as? String
        pinyinInitial = aDecoder.decodeObject(forKey: "pinyinInitial") as? String
        name = aDecoder.decodeObject(forKey: "name")  as? String
        centerHost = aDecoder.decodeObject(forKey: "centerHost") as? String
        centerContext = aDecoder.decodeObject(forKey: "centerContext") as? String
        centerPort = aDecoder.decodeObject(forKey: "centerPort") as?  Int
        urlMapping = aDecoder.decodeObject(forKey: "urlMapping") as? String
    }
    
    required public override init() {}
    
    open override var description: String {
        return toJSONString(prettyPrint: true) ?? ""
    }
}

/// 手机绑定节点的对象
public protocol IO2BindDeviceModel: HandyJSON, CustomStringConvertible  {
    //选择的节点名称
     var unit:String? { get set }
    //手机号码
      var mobile:String? { get set }
    //验证码
      var code:String? { get set }
    //设备推送的token
     var name:String? { get set }
    //设备类型
     var deviceType:String  { get set }
}
open class O2BindDeviceModel: NSObject, DataModel, NSCoding,IO2BindDeviceModel {
    //选择的节点名称
    @objc open var unit:String?
    //手机号码
    @objc open  var mobile:String?
    //验证码
    @objc open  var code:String?
    //设备推送的token
    @objc open var name:String?
    //设备类型
    @objc open var deviceType:String = "ios"
    
    public func encode(with aCoder: NSCoder) {
        if unit != nil {
            aCoder.encode(unit, forKey: "unit")
        }
        
        if mobile != nil {
            aCoder.encode(mobile, forKey: "mobile")
        }
        
        if code != nil {
            aCoder.encode(code, forKey: "code")
        }
        
        if name != nil {
            aCoder.encode(name, forKey: "name")
        }
        
        aCoder.encode(deviceType, forKey: "deviceType")
    }
    
    public required init?(coder aDecoder: NSCoder) {
        unit = aDecoder.decodeObject(forKey: "unit") as? String
        mobile = aDecoder.decodeObject(forKey: "mobile") as? String
        code = aDecoder.decodeObject(forKey: "code") as? String
        name = aDecoder.decodeObject(forKey: "name") as? String
        deviceType = aDecoder.decodeObject(forKey: "deviceType") as! String
    }
    
    required public override init() {}
    
    open override var description: String {
        return toJSONString(prettyPrint: true) ?? ""
    }
}


//MARK: - 中心服务器相关对象
/// api服务模块信息对象
public protocol IO2APIServerModel: HandyJSON, CustomStringConvertible  {
    var httpProtocol:String? { get set }
    
    var host:String? { get set }
    
    var name:String? { get set }
    
    var context:String? { get set }
    
    var port:Int? { get set }
}
open class O2APIServerModel: NSObject, DataModel, NSCoding, IO2APIServerModel {
    @objc open var httpProtocol:String?
    
    @objc open var host:String?
    
    @objc open var name:String?
    
    @objc open var context:String?
    
    open var port:Int?
    
    
    public func encode(with aCoder: NSCoder) {
        if httpProtocol != nil {
            aCoder.encode(httpProtocol, forKey: "httpProtocol")
        }
        
        if name != nil {
            aCoder.encode(name, forKey: "name")
        }
        
        if host != nil {
            aCoder.encode(host, forKey: "host")
        }
        
        if context != nil {
            aCoder.encode(context, forKey: "context")
        }
        
        if port != nil {
            aCoder.encode(port, forKey: "port")
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        httpProtocol = aDecoder.decodeObject(forKey: "httpProtocol") as? String
        name = aDecoder.decodeObject(forKey: "name") as? String
        host = aDecoder.decodeObject(forKey: "host") as? String
        context = aDecoder.decodeObject(forKey: "context") as? String
        port = aDecoder.decodeObject(forKey: "port") as? Int
    }
    
    required public override init() {}
    
    open override var description: String {
        return toJSONString(prettyPrint: true) ?? ""
    }
}

/// web服务器信息对象
public protocol IO2WebServerModel: HandyJSON, CustomStringConvertible  {
    var httpProtocol:String? { get set }
    
    var host:String? { get set }
    
    var port:Int? { get set }
}
open class O2WebServerModel: NSObject, DataModel, NSCoding, IO2WebServerModel {
    @objc open var httpProtocol:String?
    
    @objc open var host:String?
    
    open var port:Int?
    
    
    public func encode(with aCoder: NSCoder) {
        if httpProtocol != nil {
            aCoder.encode(httpProtocol, forKey: "httpProtocol")
        }
        
        if host !=  nil {
            aCoder.encode(host, forKey: "host")
        }
        
        if port != nil {
            aCoder.encode(port, forKey: "port")
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        httpProtocol = aDecoder.decodeObject(forKey: "httpProtocol") as? String
        host = aDecoder.decodeObject(forKey: "host") as? String
        port = aDecoder.decodeObject(forKey: "port") as? Int
    }
    
    required public override init() {}
    
    open override var description: String {
        return toJSONString(prettyPrint: true) ?? ""
    }
}

/// 中心服务器信息对象
public protocol IO2CenterServerModel: HandyJSON, CustomStringConvertible  {
    var assembles:[String: O2APIServerModel]? { get set }
    
    var webServer: O2WebServerModel? { get set }
    
    var tokenName: String? { get set }
}
open class O2CenterServerModel: NSObject, DataModel, NSCoding, IO2CenterServerModel {
    @objc open var assembles:[String: O2APIServerModel]?
    
    @objc open var webServer: O2WebServerModel?
    
    @objc open var tokenName: String? // tokenName是可修改的 x-token是默认值
    
    
    public func encode(with aCoder: NSCoder) {
        if assembles != nil {
            aCoder.encode(assembles, forKey: "assembles")
        }
        
        if webServer != nil {
            aCoder.encode(webServer, forKey: "webServer")
        }
        if tokenName != nil {
            aCoder.encode(tokenName, forKey: "tokenName")
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        assembles = aDecoder.decodeObject(forKey: "assembles") as? [String : O2APIServerModel]
        webServer = aDecoder.decodeObject(forKey: "webServer") as? O2WebServerModel
        tokenName = aDecoder.decodeObject(forKey: "tokenName") as? String
    }
    
    required public override init() {}
    
    open override var description: String {
        return toJSONString(prettyPrint: true) ?? ""
    }
}

//MARK: - 登录认证相关的对象
/// 当前登录用户对象信息
public protocol IO2LoginAccountModel: HandyJSON, CustomStringConvertible {
    var changePasswordTime : String? { get set }
    var controllerList : [AnyObject]? { get set }
    var createTime : String? { get set }
    var distinguishedName : String? { get set }
    var employee : String? { get set }
    var genderType : String? { get set }
    var icon : String? { get set }
    var id : String? { get set }
    var lastLoginAddress : String? { get set }
    var lastLoginClient : String? { get set }
    var lastLoginTime : String? { get set }
    var mail : String? { get set }
    var mobile : String? { get set }
    var name : String? { get set }
    var passwordExpired : Bool? { get set }
    var pinyin : String? { get set }
    var pinyinInitial : String? { get set }
    var qq : String? { get set }
    var roleList : [AnyObject]? { get set }
    var token : String? { get set }
    var tokenType : String? { get set }
    var unique : String? { get set }
    var updateTime : String? { get set }
    var weixin : String? { get set }
}
open class O2LoginAccountModel: NSObject, DataModel, NSCoding, IO2LoginAccountModel {
    @objc open var changePasswordTime : String?
    @objc open var controllerList : [AnyObject]?
    @objc open var createTime : String?
    @objc open var distinguishedName : String?
    @objc open var employee : String?
    @objc open var genderType : String?
    @objc open var icon : String?
    @objc open var id : String?
    @objc open var lastLoginAddress : String?
    @objc open var lastLoginClient : String?
    @objc open var lastLoginTime : String?
    @objc open var mail : String?
    @objc open var mobile : String?
    @objc open var name : String?
    open var passwordExpired : Bool?
    @objc open var pinyin : String?
    @objc open var pinyinInitial : String?
    @objc open var qq : String?
    @objc open var roleList : [AnyObject]?
    @objc open var token : String?
    @objc open var tokenType : String?
    @objc open var unique : String?
    @objc open var updateTime : String?
    @objc open var weixin : String?
    @objc open var signature: String?
    
    public func encode(with aCoder: NSCoder) {
        if changePasswordTime != nil{
            aCoder.encode(changePasswordTime, forKey: "changePasswordTime")
        }
        if controllerList != nil{
            aCoder.encode(controllerList, forKey: "controllerList")
        }
        if createTime != nil{
            aCoder.encode(createTime, forKey: "createTime")
        }
        if distinguishedName != nil{
            aCoder.encode(distinguishedName, forKey: "distinguishedName")
        }
        if employee != nil{
            aCoder.encode(employee, forKey: "employee")
        }
        if genderType != nil{
            aCoder.encode(genderType, forKey: "genderType")
        }
        if icon != nil{
            aCoder.encode(icon, forKey: "icon")
        }
        if id != nil{
            aCoder.encode(id, forKey: "id")
        }
        if lastLoginAddress != nil{
            aCoder.encode(lastLoginAddress, forKey: "lastLoginAddress")
        }
        if lastLoginClient != nil{
            aCoder.encode(lastLoginClient, forKey: "lastLoginClient")
        }
        if lastLoginTime != nil{
            aCoder.encode(lastLoginTime, forKey: "lastLoginTime")
        }
        if mail != nil{
            aCoder.encode(mail, forKey: "mail")
        }
        if mobile != nil{
            aCoder.encode(mobile, forKey: "mobile")
        }
        if name != nil{
            aCoder.encode(name, forKey: "name")
        }
        if passwordExpired != nil{
            aCoder.encode(passwordExpired, forKey: "passwordExpired")
        }
        if pinyin != nil{
            aCoder.encode(pinyin, forKey: "pinyin")
        }
        if pinyinInitial != nil{
            aCoder.encode(pinyinInitial, forKey: "pinyinInitial")
        }
        if qq != nil{
            aCoder.encode(qq, forKey: "qq")
        }
        if roleList != nil{
            aCoder.encode(roleList, forKey: "roleList")
        }
        if token != nil{
            aCoder.encode(token, forKey: "token")
        }
        if tokenType != nil{
            aCoder.encode(tokenType, forKey: "tokenType")
        }
        if unique != nil{
            aCoder.encode(unique, forKey: "unique")
        }
        if updateTime != nil{
            aCoder.encode(updateTime, forKey: "updateTime")
        }
        if weixin != nil{
            aCoder.encode(weixin, forKey: "weixin")
        }
        if signature != nil {
            aCoder.encode(signature, forKey: "signature")
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        changePasswordTime = aDecoder.decodeObject(forKey: "changePasswordTime") as? String
        controllerList = aDecoder.decodeObject(forKey: "controllerList") as? [AnyObject]
        createTime = aDecoder.decodeObject(forKey: "createTime") as? String
        distinguishedName = aDecoder.decodeObject(forKey: "distinguishedName") as? String
        employee = aDecoder.decodeObject(forKey: "employee") as? String
        genderType = aDecoder.decodeObject(forKey: "genderType") as? String
        icon = aDecoder.decodeObject(forKey: "icon") as? String
        id = aDecoder.decodeObject(forKey: "id") as? String
        lastLoginAddress = aDecoder.decodeObject(forKey: "lastLoginAddress") as? String
        lastLoginClient = aDecoder.decodeObject(forKey: "lastLoginClient") as? String
        lastLoginTime = aDecoder.decodeObject(forKey: "lastLoginTime") as? String
        mail = aDecoder.decodeObject(forKey: "mail") as? String
        mobile = aDecoder.decodeObject(forKey: "mobile") as? String
        name = aDecoder.decodeObject(forKey: "name") as? String
        passwordExpired = aDecoder.decodeObject(forKey: "passwordExpired") as? Bool
        pinyin = aDecoder.decodeObject(forKey: "pinyin") as? String
        pinyinInitial = aDecoder.decodeObject(forKey: "pinyinInitial") as? String
        qq = aDecoder.decodeObject(forKey: "qq") as? String
        roleList = aDecoder.decodeObject(forKey: "roleList") as? [AnyObject]
        token = aDecoder.decodeObject(forKey: "token") as? String
        tokenType = aDecoder.decodeObject(forKey: "tokenType") as? String
        unique = aDecoder.decodeObject(forKey: "unique") as? String
        updateTime = aDecoder.decodeObject(forKey: "updateTime") as? String
        weixin = aDecoder.decodeObject(forKey: "weixin") as? String
        signature = aDecoder.decodeObject(forKey: "signature") as? String
    }
    
    required public override init() {}
    
    open override var description: String {
        return toJSONString(prettyPrint: true) ?? ""
    }
}

//MARK: - customStyle 移动端样式配置相关对象


/// 自定义图片对象
public protocol IO2CustomImageModel: HandyJSON, CustomStringConvertible  {
    var name : String? { get set }
    var value : String? { get set }
}
open  class O2CustomImageModel: NSObject, DataModel, NSCoding, IO2CustomImageModel {
    @objc open var name : String?
    @objc open var value : String? // base64 图片
    public func encode(with aCoder: NSCoder) {
        if name != nil {
            aCoder.encode(name, forKey: "name")
        }
        if value != nil {
            aCoder.encode(value, forKey: "value")
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: "name") as? String
        value = aDecoder.decodeObject(forKey: "value") as? String
    }
    
    required public override init() {}
    
    open override var description: String {
        return toJSONString(prettyPrint: true) ?? ""
    }
}

public protocol IO2CustomIosModel: HandyJSON, CustomStringConvertible  {
    var category : String? { get set }
    var storyboard : String? { get set }
    var subcategory : String? { get set }
    var vcname : String? { get set }
}
open class O2CustomIosModel: NSObject, DataModel, NSCoding, IO2CustomIosModel {
    @objc open var category : String?
    @objc open var storyboard : String?
    @objc open var subcategory : String?
    @objc open var vcname : String?
    
    public func encode(with aCoder: NSCoder) {
        if category != nil {
            aCoder.encode(category, forKey: "category")
        }
        if storyboard != nil {
            aCoder.encode(storyboard, forKey: "storyboard")
        }
        if subcategory != nil {
            aCoder.encode(subcategory, forKey: "subcategory")
        }
        if vcname != nil {
            aCoder.encode(vcname, forKey: "vcname")
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        category = aDecoder.decodeObject(forKey: "category") as? String
        storyboard = aDecoder.decodeObject(forKey: "storyboard") as? String
        subcategory = aDecoder.decodeObject(forKey: "subcategory") as? String
        vcname = aDecoder.decodeObject(forKey: "vcname") as? String
    }
    
    required public override init() {}
    
    open override var description: String {
        return toJSONString(prettyPrint: true) ?? ""
    }
}

public protocol IO2CustomNativeAppModel: HandyJSON, CustomStringConvertible  {
    var enable : Bool? { get set }
    var iOS : O2CustomIosModel? { get set }
    var id : Int? { get set }
    var key : String? { get set }
    var name : String? { get set }
}
open class O2CustomNativeAppModel: NSObject, DataModel, NSCoding, IO2CustomNativeAppModel {
    open var enable : Bool?
    @objc open var iOS : O2CustomIosModel?
    open var id : Int?
    @objc open var key : String?
    @objc  open var name : String?
    public func encode(with aCoder: NSCoder) {
        if enable != nil {
            aCoder.encode(enable, forKey: "enable")
        }
        if iOS != nil {
            aCoder.encode(iOS, forKey: "iOS")
        }
        if id != nil {
            aCoder.encode(id, forKey: "id")
        }
        if key != nil {
            aCoder.encode(key, forKey: "key")
        }
        if name != nil {
            aCoder.encode(name, forKey: "name")
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        enable = aDecoder.decodeObject(forKey: "enable") as? Bool
        iOS = aDecoder.decodeObject(forKey: "iOS") as? O2CustomIosModel
        id = aDecoder.decodeObject(forKey: "id") as? Int
        key = aDecoder.decodeObject(forKey: "key") as? String
        name = aDecoder.decodeObject(forKey: "name") as? String
    }
    
    required public override init() {}
    
    open override var description: String {
        return toJSONString(prettyPrint: true) ?? ""
    }
}

public protocol IO2CustomPortalAppModel: HandyJSON, CustomStringConvertible  {
    var alias : String? { get set }
    var createTime : String? { get set }
    var creatorPerson : String? { get set }
    var descriptionField : String? { get set }
    var enable : Bool? { get set }
    var firstPage : String? { get set }
    var id : String? { get set }
    var lastUpdatePerson : String? { get set }
    var lastUpdateTime : String? { get set }
    var name : String? { get set }
    var portalCategory : String? { get set }
    var updateTime : String? { get set }
}
open class O2CustomPortalAppModel: NSObject, DataModel, NSCoding, IO2CustomPortalAppModel {
    @objc open var alias : String?
    @objc open var createTime : String?
    @objc open var creatorPerson : String?
    @objc open var descriptionField : String?
    open var enable : Bool?
    @objc open var firstPage : String?
    @objc open var id : String?
    @objc open var lastUpdatePerson : String?
    @objc open var lastUpdateTime : String?
    @objc open var name : String?
    @objc open var portalCategory : String?
    @objc open var updateTime : String?
    
    public func encode(with aCoder: NSCoder) {
        if alias != nil {
            aCoder.encode(alias, forKey: "alias")
        }
        if createTime != nil {
            aCoder.encode(createTime, forKey: "createTime")
        }
        if creatorPerson != nil {
            aCoder.encode(creatorPerson, forKey: "creatorPerson")
        }
        if descriptionField != nil {
            aCoder.encode(descriptionField, forKey: "descriptionField")
        }
        if enable != nil {
            aCoder.encode(enable, forKey: "enable")
        }
        if firstPage != nil {
            aCoder.encode(firstPage, forKey: "firstPage")
        }
        if id != nil {
            aCoder.encode(id, forKey: "id")
        }
        if lastUpdatePerson != nil {
            aCoder.encode(lastUpdatePerson, forKey: "lastUpdatePerson")
        }
        if lastUpdateTime != nil {
            aCoder.encode(lastUpdateTime, forKey: "lastUpdateTime")
        }
        if name != nil {
            aCoder.encode(name, forKey: "name")
        }
        if portalCategory != nil {
            aCoder.encode(portalCategory, forKey: "portalCategory")
        }
        if updateTime != nil {
            aCoder.encode(updateTime, forKey: "updateTime")
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        alias = aDecoder.decodeObject(forKey: "alias") as? String
        createTime = aDecoder.decodeObject(forKey: "createTime") as? String
        creatorPerson = aDecoder.decodeObject(forKey: "creatorPerson") as? String
        descriptionField = aDecoder.decodeObject(forKey: "descriptionField") as? String
        enable = aDecoder.decodeObject(forKey: "enable") as? Bool
        firstPage = aDecoder.decodeObject(forKey: "firstPage") as? String
        id = aDecoder.decodeObject(forKey: "id") as? String
        lastUpdatePerson = aDecoder.decodeObject(forKey: "lastUpdatePerson") as? String
        lastUpdateTime = aDecoder.decodeObject(forKey: "lastUpdateTime") as? String
        name = aDecoder.decodeObject(forKey: "name") as? String
        portalCategory = aDecoder.decodeObject(forKey: "portalCategory") as? String
        updateTime = aDecoder.decodeObject(forKey: "updateTime") as? String
    }
    
    required public override init() {}
    
    open override var description: String {
        return toJSONString(prettyPrint: true) ?? ""
    }
}

/// 样式配置对象
public protocol IO2CustomStyleModel: HandyJSON, CustomStringConvertible {
    var images : [O2CustomImageModel]? { get set }
    var indexPortal : String? { get set }
    var indexType : String? { get set }
    var nativeAppList : [O2CustomNativeAppModel]? { get set }
    var portalList : [O2CustomPortalAppModel]? { get set }
    var simpleMode: Bool? { get set } /// 简易模式
}
open class O2CustomStyleModel: NSObject, DataModel, NSCoding, IO2CustomStyleModel {
    @objc open var images : [O2CustomImageModel]?
    @objc open var indexPortal : String?
    @objc open var indexType : String?
    @objc open var contactPermissionView: String? = O2.CUSTOM_STYLE_CONTACT_PERMISSION_DEFAULT
    @objc open var nativeAppList : [O2CustomNativeAppModel]?
    @objc open var portalList : [O2CustomPortalAppModel]?
    open var simpleMode: Bool?
    
    @objc public func encode(with aCoder: NSCoder) {
        if images != nil {
            aCoder.encode(images, forKey: "images")
        }
        if indexPortal != nil {
            aCoder.encode(indexPortal, forKey: "indexPortal")
        }
        if indexType != nil {
            aCoder.encode(indexType, forKey: "indexType")
        }
        if contactPermissionView != nil {
            aCoder.encode(contactPermissionView, forKey: "contactPermissionView")
        }
        if nativeAppList != nil {
            aCoder.encode(nativeAppList, forKey: "nativeAppList")
        }
        if portalList != nil {
            aCoder.encode(portalList, forKey: "portalList")
        }
        if simpleMode != nil {
            aCoder.encode(simpleMode, forKey: "simpleMode")
        }
    }
    
    @objc public required init?(coder aDecoder: NSCoder) {
        images = aDecoder.decodeObject(forKey: "images") as? [O2CustomImageModel]
        indexPortal = aDecoder.decodeObject(forKey: "indexPortal") as? String
        indexType = aDecoder.decodeObject(forKey: "indexType") as? String
        contactPermissionView = aDecoder.decodeObject(forKey: "contactPermissionView") as? String
        nativeAppList = aDecoder.decodeObject(forKey: "nativeAppList") as? [O2CustomNativeAppModel]
        portalList = aDecoder.decodeObject(forKey: "portalList") as? [O2CustomPortalAppModel]
        simpleMode = aDecoder.decodeObject(forKey: "simpleMode") as? Bool
    }
    
    required public override init() {}
    
    open override var description: String {
        return toJSONString(prettyPrint: true) ?? ""
    }
    
}


/// 移动端应用对象， 服务器提供移动端 可以展现的应用列表
public protocol IO2AppModel: HandyJSON, CustomStringConvertible  {
    var id : String? { get set } // native应用里面的key portal应用里面的id
    var name: String? { get set }
    
    var portalUrl: String? { get set } // portal应用的访问地址
    var portalCategory : String? { get set } //

    var type: String? { get set } //分类 native portal
    var enable : Bool? { get set } // 是否启用
}

open class O2AppModel: NSObject, DataModel, NSCoding, IO2AppModel {
    @objc open var id: String?
    @objc open var name: String?
    @objc open var portalUrl: String?
    @objc open var portalCategory: String?
    @objc open var type: String?
    open var enable: Bool?
    
    required public override init() {}
    
    open override var description: String {
        return toJSONString(prettyPrint: true) ?? ""
    }
    
    @objc public func encode(with aCoder: NSCoder) {
        if id != nil {
            aCoder.encode(id, forKey: "id")
        }
        if name != nil {
            aCoder.encode(name, forKey: "name")
        }
        if portalUrl != nil {
            aCoder.encode(portalUrl, forKey: "portalUrl")
        }
        if portalCategory != nil {
            aCoder.encode(portalCategory, forKey: "portalCategory")
        }
        if type != nil {
            aCoder.encode(type, forKey: "type")
        }
        if enable != nil {
            aCoder.encode(enable, forKey: "enable")
        }
        
    }
    
    @objc public required init?(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObject(forKey: "id") as? String
        name = aDecoder.decodeObject(forKey: "name") as? String
        portalUrl = aDecoder.decodeObject(forKey: "portalUrl") as? String
        portalCategory = aDecoder.decodeObject(forKey: "portalCategory") as? String
        type = aDecoder.decodeObject(forKey: "type") as? String
        enable = aDecoder.decodeObject(forKey: "enable") as? Bool
    }
}
