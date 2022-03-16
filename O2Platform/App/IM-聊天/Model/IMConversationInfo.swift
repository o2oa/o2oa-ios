//
//  IMConversation.swift
//  O2Platform
//
//  Created by FancyLou on 2020/6/4.
//  Copyright © 2020 zoneland. All rights reserved.
//
import HandyJSON


class IMConversationInfo: NSObject, DataModel {
    @objc var id: String?
    @objc var title: String?
    @objc var type: String? //会话类型 单人 、 群.
    @objc var personList: [String]?
    @objc var adminPerson: String?
    @objc var note: String?

    @objc var lastMessageTime: String?
    @objc var createTime: String?
    @objc var updateTime: String?
    var unreadNumber: Int?
    var isTop: Bool?

    @objc var lastMessage: IMMessageInfo?

    required override init() { }

    func mapping(mapper: HelpingMapper) {

    }
}

class IMConversationUpdateForm: NSObject, DataModel  {
    @objc var id: String?
    @objc var title: String?
    @objc var personList: [String]?
    @objc var adminPerson: String?
    @objc var note: String?
    
    required override init() { }

       func mapping(mapper: HelpingMapper) {

       }
}


class IMMessageRequestForm: NSObject, DataModel {

    @objc var conversationId: String?

    required override init() { }

    func mapping(mapper: HelpingMapper) {

    }
}

class IMMessageInfo: NSObject, DataModel {
    @objc var id: String?
    @objc var conversationId: String?
    @objc var body: String?
    @objc var createPerson: String?
    @objc var createTime: String?
    @objc var updateTime: String?

    required override init() { }

    func mapping(mapper: HelpingMapper) {

    }
}

class IMMessageBodyInfo: NSObject, DataModel {
    @objc var id: String?
    @objc var type: String?
    @objc var body: String?
    @objc var fileId: String? //文件id
    @objc var fileName: String? //文件名称
    @objc var fileExtension: String? //文件扩展
    @objc var fileTempPath: String? //本地临时文件地址
    @objc var audioDuration: String? // 音频文件时长
    @objc var address: String? //type=location的时候位置信息
    @objc var addressDetail: String?
    var latitude: Double?//type=location的时候位置信息
    var longitude: Double?//type=location的时候位置信息
    
    @objc var title:  String? // 流程工作标题
    @objc var work:  String?// 流程工作id
    @objc var process:  String?// 流程id
    @objc var processName:  String?// 流程名称
    @objc var application:  String?// 流程应用id
    @objc var applicationName:  String?// 流程应用名称
    @objc var job:  String?// 流程工作jobId


    required override init() { }

    func mapping(mapper: HelpingMapper) {

    }
}

class IMUploadBackModel: NSObject, DataModel {
    public override var description: String {
        return "IMUploadBackModel"
    }
    
    @objc var id:String?
    @objc var fileExtension: String? //文件扩展
    @objc var fileName: String? //文件名称
    
    required override init() { }

    func mapping(mapper: HelpingMapper) {

    }
}

//websocket 消息对象
class WsMessage: NSObject, DataModel {
    @objc var type: String? //im_create
    @objc var body: IMMessageInfo? //这个对象只有 type=im_create的时候才是这个对象
    required override init() { }

    func mapping(mapper: HelpingMapper) {

    }
}

//其他消息
class InstantMessage: NSObject, DataModel {
    @objc var id: String?
    @objc var title: String?
    @objc var type: String?
    @objc var body: String?
    @objc var consumerList: [String]?
    @objc var person: String?
    var consumed: Bool?
    @objc var createTime: String?
    @objc var updateTime: String?
    
    required override init() { }

    func mapping(mapper: HelpingMapper) {

    }

}


struct  O2LocationData {
    var address: String?
    var addressDetail: String?
    var latitude: Double?
    var longitude: Double?
}

/// IM聊天的配置文件
open class IMConfig: NSObject, HandyJSON, NSCoding {
    open var enableClearMsg: Bool?
    open var enableRevokeMsg: Bool?
    
    public func encode(with aCoder: NSCoder) {
        if enableClearMsg != nil {
            aCoder.encode(enableClearMsg, forKey: "enableClearMsg")
        }
        if enableRevokeMsg != nil {
            aCoder.encode(enableRevokeMsg, forKey: "enableRevokeMsg")
        }
        
    }
    
    public required init?(coder aDecoder: NSCoder) {
        enableClearMsg = aDecoder.decodeObject(forKey: "enableClearMsg") as? Bool
        enableRevokeMsg = aDecoder.decodeObject(forKey: "enableRevokeMsg") as? Bool
    }
    
    required public override init() {}
    
    open override var description: String {
        return toJSONString(prettyPrint: true) ?? ""
    }
}
