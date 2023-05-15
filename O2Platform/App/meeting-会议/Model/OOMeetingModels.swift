//
//  MeetingModels.swift
//  o2app
//
//  Created by 刘振兴 on 2018/1/17.
//  Copyright © 2018年 zone. All rights reserved.
//

import Foundation
import HandyJSON

class OOMeetingConfigProcess: NSObject, DataModel, NSCoding {
    @objc var name: String?
    @objc var id: String?
    @objc var application: String?
    @objc var applicationName: String?
    @objc var alias: String?
    
    public func encode(with aCoder: NSCoder) {
        if name != nil {
            aCoder.encode(name, forKey: "name")
        }
        if id != nil {
            aCoder.encode(id, forKey: "id")
        }
        if application != nil {
            aCoder.encode(application, forKey: "application")
        }
        if applicationName != nil {
            aCoder.encode(applicationName, forKey: "applicationName")
        }
        if alias != nil {
            aCoder.encode(alias, forKey: "alias")
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: "name") as? String
        id = aDecoder.decodeObject(forKey: "id") as? String
        application = aDecoder.decodeObject(forKey: "application") as? String
        applicationName = aDecoder.decodeObject(forKey: "applicationName") as? String
        alias = aDecoder.decodeObject(forKey: "alias") as? String
    }
    
    required public override init() {}
    
    open override var description: String {
        return toJSONString(prettyPrint: true) ?? ""
    }
}

/// 会议管理模块配置对象
class OOMeetingConfigInfo: NSObject, DataModel, NSCoding {
    @objc var process: OOMeetingConfigProcess?
    var mobileCreateEnable:  Bool?
    var weekBegin: Int?
    @objc var typeList: [String]? // 会议类型可选值
    
    public func encode(with aCoder: NSCoder) {
        if process != nil {
            aCoder.encode(process, forKey: "process")
        }
        if mobileCreateEnable != nil {
            aCoder.encode(mobileCreateEnable, forKey: "mobileCreateEnable")
        }
        if weekBegin != nil {
            aCoder.encode(weekBegin, forKey: "weekBegin")
        }
        if typeList != nil {
            aCoder.encode(typeList, forKey: "typeList")
        }
        
    }
    
    public required init?(coder aDecoder: NSCoder) {
        process = aDecoder.decodeObject(forKey: "process") as? OOMeetingConfigProcess
        mobileCreateEnable = aDecoder.decodeObject(forKey: "mobileCreateEnable") as? Bool
        weekBegin = aDecoder.decodeObject(forKey: "weekBegin") as? Int
        typeList = aDecoder.decodeObject(forKey: "typeList") as? [String]
        
    }
    
    required public override init() {}
    
    open override var description: String {
        return toJSONString(prettyPrint: true) ?? ""
    }
}

class OOMeetingProcessIdentity: NSObject, DataModel {
    @objc var name: String?
    @objc var unique: String?
    @objc var summary:String?
    @objc var distinguishedName: String?
    @objc var person: String?
    @objc var unit: String?
    @objc var unitName: String?
    var unitLevel: Int?
    @objc var unitLevelName: String?
    
    required override init() {
        
    }
    
}

class OOMeetingBuildInfo: NSObject,DataModel {
    
    @objc var address : String?
    @objc var createTime : String?
    @objc var id : String?
    @objc var name : String?
    @objc var pinyin : String?
    @objc var pinyinInitial : String?
    @objc var roomList : [OOMeetingRoomInfo]?
    @objc var updateTime : String?
    
    required override init() {
        
    }
}

class OOMeetingRoomInfo: NSObject,DataModel {
    var available : Bool?
    var idle : Bool?
    @objc var building : String?
    var capacity : Int?
    @objc var createTime : String?
    @objc var device : String?
    var floor : Int?
    @objc var id : String?
    @objc var meetingList : [OOMeetingInfo]?
    @objc var name : String?
    @objc var phoneNumber : String?
    @objc var pinyin : String?
    @objc var pinyinInitial : String?
    @objc var roomNumber : String?
    @objc var updateTime : String?
    
    required override init() {
        
    }
}

class OOMeetingInfo :NSObject,DataModel{
    
    @objc var acceptPersonList : [String]?
    @objc var applicant : String? //申请人
    @objc var attachmentList : [OOMeetingAttachmentList]?
    @objc var completedTime : String?
    @objc var confirmStatus : String?
    @objc var createTime : String?
    @objc var descriptionField : String?
    @objc var summary: String?
    @objc var id : String?
    @objc var invitePersonList : [String]? //被邀请的人员 老字段 为了兼容 这个字段还需设值
    @objc var  inviteMemberList: [String]?//被邀请的人员 这个是新字段
    @objc var  inviteDelPersonList: [String]?//被邀请的人员 删除的人
    
    var manualCompleted : Bool?
    var myAccept : Bool?
    var myApply : Bool?
    var myReject : Bool?
    var myWaitAccept : Bool?
    var myWaitConfirm : Bool?
    @objc var pinyin : String?
    @objc var pinyinInitial : String?
    @objc var rejectPersonList : [String]?
    @objc var room : String?
    @objc var startTime : String?
    @objc var status : String? //状态  wait 就可以修改
    @objc var subject : String?
    @objc var updateTime : String?
    //会议室对象
    @objc var woRoom: OOMeetingRoomInfo?
    
    // 新增3个字段 202203
    @objc var hostUnit: String?// 承办部门
    @objc var hostPerson: String?// 主持人
    @objc var type: String? // 会议类型
    // 新增字段 2023-05
    @objc var mode: String? // online
    @objc var roomId: String? // 在线会议房间号
    @objc var roomLink: String? // 在线会议链接
    
    required override init() {
        
    }
}

class OOMeetingAttachmentList : NSObject,DataModel{
    
    @objc var createTime : String?
    @objc var `extension` : String?
    @objc var id : String?
    @objc var lastUpdatePerson : String?
    @objc var lastUpdateTime : String?
    var length : Int?
    @objc var meeting : String?
    @objc var name : String?
    @objc var storage : String?
    var summary : Bool?
    @objc var updateTime : String?
    
    required override init() {
        
    }
}

class MeetingForm:NSObject,HandyJSON{
    @objc var subject:String?
    @objc var room:String?
    @objc var roomName:String?
    var meetingDate:Date = Date()
    var startTime:Date = Date()
    var completedTime:Date = Date()
    @objc var invitePersonList:[String] = []
    @objc var summary:String?
    override required init() {
        
    }
}


