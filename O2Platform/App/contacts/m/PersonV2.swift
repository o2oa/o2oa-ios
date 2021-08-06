//
//  PersonV2.swift
//  O2Platform
//
//  Created by 程剑 on 2017/7/9.
//  Copyright © 2017年 zoneland. All rights reserved.
//

import Foundation
import ObjectMapper

class PersonV2:Mappable {
    
    var changePasswordTime : String?
    var controllerList : [String]?
    var createTime : String?
    var distinguishedName : String?
    var employee : String?
    var genderType : String?
    var id : String?
    var lastLoginAddress : String?
    var lastLoginClient : String?
    var lastLoginTime : String?
    var mail : String?
    var mobile : String?
    var name : String?
    var orderNumber : Int?
    var superior : String?
    var signature : String?
    var pinyin : String?
    var pinyinInitial : String?
    var qq : String?
    var unique : String?
    var updateTime : String?
    var weixin : String?
    var officePhone : String?
    var boardDate : String?
    var desc : String?
    var birthday : String?
    var ownerid: String?
    var woGroupList : [AnyObject]?
    var woIdentityList : [IdentityV2]?
    var woPersonAttributeList : [PersonAttribute]?
    var woRoleList : [AnyObject]?
    
    required init?(map: Map){}
    
    init() {
        
    }
    
    func mapping(map: Map)
    {
        changePasswordTime <- map["changePasswordTime"]
        controllerList <- map["controllerList"]
        createTime <- map["createTime"]
        distinguishedName <- map["distinguishedName"]
        employee <- map["employee"]
        genderType <- map["genderType"]
        id <- map["id"]
        lastLoginAddress <- map["lastLoginAddress"]
        lastLoginClient <- map["lastLoginClient"]
        lastLoginTime <- map["lastLoginTime"]
        mail <- map["mail"]
        mobile <- map["mobile"]
        name <- map["name"]
        orderNumber <- map["orderNumber"]
        superior <- map["superior"]
        signature <- map["signature"]
        pinyin <- map["pinyin"]
        pinyinInitial <- map["pinyinInitial"]
        qq <- map["qq"]
        unique <- map["unique"]
        updateTime <- map["updateTime"]
        weixin <- map["weixin"]
        officePhone <- map["officePhone"]
        boardDate <- map["boardDate"]
        desc <- map["description"]
        birthday <- map["birthday"]
        woGroupList <- map["woGroupList"]
        woIdentityList <- map["woIdentityList"]
        woPersonAttributeList <- map["woPersonAttributeList"]
        woRoleList <- map["woRoleList"]
        
    }
    
    
}


struct PersonInfoWithAttributes {
    var infoType: Int // 0 默认属性 1个人属性
    var name: String? // infoType=0 显示的属性名称
    var attr: PersonAttribute? // infoType=1 对应的个人属性
}
