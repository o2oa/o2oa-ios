//
//	O2Data.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import ObjectMapper
import HandyJSON


// 根据分类显示应用列表
struct O2AppByCategory {
    var category: String?
    var app: O2Application?
}

class O2Application : NSObject, DataModel {

	@objc var alias : String?
	@objc var applicationCategory : String?
	@objc var controllerList : [String]?
	@objc var createTime : String?
	@objc var creatorPerson : String?
	@objc var descriptionField : String?
	@objc var icon : String?
	@objc var id : String?
	@objc var lastUpdatePerson : String?
	@objc var lastUpdateTime : String?
	@objc var name : String?
	@objc var updateTime : String?
    var processList:[O2ApplicationProcess]?


	 
	 
	required override init(){}

	func mapping(map: Map)
	{
		alias <- map["alias"]
		applicationCategory <- map["applicationCategory"]
		controllerList <- map["controllerList"]
		createTime <- map["createTime"]
		creatorPerson <- map["creatorPerson"]
		descriptionField <- map["description"]
		icon <- map["icon"]
		id <- map["id"]
		lastUpdatePerson <- map["lastUpdatePerson"]
		lastUpdateTime <- map["lastUpdateTime"]
		name <- map["name"]
		updateTime <- map["updateTime"]
        processList <- map["processList"]
	}

    

}


class O2ApplicationProcess: NSObject, DataModel {
    
    @objc var id:String?
    @objc var name:String?
    @objc var alias:String?
    @objc var desc:String?
    @objc var creatorPerson:String?
    @objc var application:String?
    @objc var icon:String?
    @objc var defaultStartMode: String?
    @objc var startableTerminal: String? // client,mobile,all 有可能没有值 没有值就是all
    
    /// 版本号
    @objc var edition: String?
    @objc var editionName: String?
    var editionEnable: Bool?
    @objc var editionNumber: String?
    
    required override init(){}
    
}


class O2ApplicationIcon: NSObject, DataModel {
    @objc var icon: String?
    @objc var iconHue: String?
    
    required override init() {
    }
    
    func mapping(mapper: HelpingMapper) {
    }
}

/// 根据应用查询流程 applicationItemWithFilter filter对象
class O2ProcessFilter: NSObject, DataModel {
    @objc var startableTerminal: String? //可启动流程终端类型,可选值 client,mobile,all
    required override init() {
    }
    
    func mapping(mapper: HelpingMapper) {
    }
}
