//
//  O2CloudFileV3Models.swift
//  O2Platform
//
//  Created by FancyLou on 2022/5/30.
//  Copyright © 2022 zoneland. All rights reserved.
//

import Foundation
import HandyJSON


// MARK:- 收藏的共享区
class CloudFileV3Favorite: NSObject,DataModel {
    
    @objc var id : String?
    @objc  var name : String?
    @objc  var person : String?
    @objc  var folder : String?
    @objc  var zoneId : String?
    var orderNumber: Int?
    @objc var createTime: String?
    @objc var updateTime: String?
    var isAdmin: Bool?
    var isEditor: Bool?
    
    override required init() {
        
    }
}

class CloudFileV3Zone: NSObject,DataModel {
    
    @objc var id : String?
    @objc  var name : String?
    @objc  var person : String?
    @objc  var folder : String?
    @objc  var zoneId : String?
    var orderNumber: Int?
    @objc var createTime: String?
    @objc var updateTime: String?
    var isAdmin: Bool?
    var isEditor: Bool?
    @objc var superior: String?
    @objc var status: String?
    @objc var lastUpdatePerson: String?
    @objc var lastUpdateTime:String?

    var isZone: Bool?
    
    override required init() {
        
    }
}

class CloudFileV3ZoneHeader: NSObject,DataModel {
    @objc  var name : String?
    override required init() {
        
    }
}


enum CloudFileV3ZoneType {
    case header(AnyObject)
    case favorite(AnyObject)
    case zone(AnyObject)
}

class CloudFileV3CellViewModel {
    
    var name:String?
    
    var dataType:CloudFileV3ZoneType
    
    init(name:String?,sourceObject:AnyObject){
        self.name = name
        if sourceObject.isKind(of: CloudFileV3ZoneHeader.self) {
            self.dataType = .header(sourceObject)
        } else if sourceObject.isKind(of: CloudFileV3Zone.self) {
            self.dataType = .zone(sourceObject)
        } else {
            self.dataType = .favorite(sourceObject)
        }
    }
    
}
