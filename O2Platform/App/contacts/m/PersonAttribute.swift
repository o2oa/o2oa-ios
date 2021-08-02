//
//  PersonAttribute.swift
//  O2Platform
//
//  Created by FancyLou on 2021/8/2.
//  Copyright © 2021 zoneland. All rights reserved.
//
import Foundation
import ObjectMapper


class PersonAttribute: Mappable {
    var id : String?
    var pinyin : String?
    var pinyinInitial : String?
    var name : String?
    var unique : String?
    var distinguishedName : String?
    var person : String?
    var attributeList :  [String]?
    required init?(map: Map){}
    
    init() {
    }
    
    func mapping(map: Map)
    {
        distinguishedName <- map["distinguishedName"]
        id <- map["id"]
        name <- map["name"]
        pinyin <- map["pinyin"]
        pinyinInitial <- map["pinyinInitial"]
        unique <- map["unique"]
        person <- map["person"]
        attributeList <- map["attributeList"]
    }
}
