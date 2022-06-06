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
    @objc  var desc : String?
    
   
    
    override required init() {
        
    }
    
    
    func mapping(mapper: HelpingMapper) {
        mapper <<< self.desc <-- "description"
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
    @objc  var desc : String?
    
    var isZone: Bool?
    
    override required init() {
        
    }
    
     
    func mapping(mapper: HelpingMapper) {
        mapper <<< self.desc <-- "description"
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

// 共享区 post对象
class CloudFileV3ZonePost: NSObject,DataModel {
    @objc  var name : String?
    @objc  var desc : String?
    
    override required init() {
        
    }
    
    func mapping(mapper: HelpingMapper) {
        mapper <<< self.desc <-- "description"
    }
}

//收藏post对象
class CloudFileV3FavoritePost: NSObject,DataModel {
    @objc  var name : String?
    @objc  var folder : String?
    @objc  var orderNumber : String?
    
    override required init() {
        
    }
     
}

// MARK: - v3版本 企业网盘内的 文件和文件夹

class OOAttachmentV3:NSObject,DataModel {
     
    @objc var createTime : String?
    @objc var id : String?
    @objc var name : String?
    @objc var updateTime : String?
     
    var isAdmin: Bool? // 是否管理员
    var isEditor: Bool? // 是否编辑者
    var isCreator: Bool? // 是否创建着
    @objc var person: String?
    @objc  var `extension`:  String?
    @objc  var contentType: String?
    @objc var type: String? // 文件所属分类.
    var length: Int?
    @objc  var folder: String? // 文件所属目录。
    @objc  var zoneId: String? // 共享区ID。
    @objc var originFile: String? // 真实文件id.
    @objc var lastUpdateTime: String?
    @objc var lastUpdatePerson: String?
    @objc var status: String? // 正常|已删除
    
    override required init() {
        
    }
    
}

class OOFolderV3:NSObject,DataModel {
    
    @objc var createTime : String?
    @objc var updateTime : String?
    @objc var id : String?
    @objc var name : String?
    
    
    @objc var lastUpdatePerson: String?
    @objc var lastUpdateTime: String?
    @objc var person: String?
    @objc var superior: String? // 上级目录ID
    @objc  var zoneId: String? // 共享区ID
    var attachmentCount: Int? // 附件数量
    var folderCount: Int? // 目录数量
    var isAdmin: Bool? // 是否管理员
    var isEditor: Bool? // 是否编辑者
    var isCreator: Bool? // 是否创建着
    @objc var status: String? // 正常|已删除
    
    override required init() {
        
    }
    
}


// 重命名提交对象
class RenamePost:NSObject,DataModel {
    
    @objc var name: String?
    
    override required init() {
        
    }
    
}
// 保存到个人网盘 提交对象
class MoveToMyPanPost:NSObject,DataModel {
    var attIdList: [String] = []
    var folderIdList:[String] = []
    
    override required init() {
        
    }
}

// 选择器使用的
class MoveV3Post: NSObject,DataModel {
    var name: String? // 文件或文件夹名称
    var folder: String?// 上级目录
    var superior: String? // 上级目录
    
    override required init() {
        
    }
}
