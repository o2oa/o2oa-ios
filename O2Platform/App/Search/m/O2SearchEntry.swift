//
//  File.swift
//  O2Platform
//
//  Created by FancyLou on 2021/5/25.
//  Copyright © 2021 zoneland. All rights reserved.
//

import Foundation


class O2SearchIdsEntry: NSObject, DataModel {
    @objc var count: Int = 0
    @objc var valueList: [String] = []
    
    required override init(){}
}

class O2SearchEntry: NSObject, DataModel {
    @objc var id: String?
    @objc var type: String? // cms work
    @objc var title: String?
    @objc var summary: String?
    @objc var creatorPerson: String?
    @objc var creatorUnit: String?
    @objc var reference: String? //关联id
    @objc var createTime: String? //
    @objc var updateTime: String? //

    @objc var appId: String?// cms栏目ID
    @objc var appName: String?//    cms栏目名称
    @objc var categoryId: String?//   cms分类ID
    @objc var categoryName: String?//    cms分类名称
    @objc var application: String?//   processPlatform应用id
    @objc var applicationName: String?//    processPlatform应用名称
    @objc var process: String?//   processPlatform流程id
    @objc var processName: String?//   processPlatform流程名称

    
    required override init(){}
    
}

/// 查询的 分页对象
struct O2SearchPageModel {
    
    var list:[O2SearchEntry] = [] // 结果列表
    var page: Int = 1 // 当前页数
    var totalPage: Int = 1 // 总页数
    
    
}

/// 查询 post
class O2SearchV2Form : NSObject, DataModel {
    var page: Int = 1
    @objc var query: String = ""
    var size: Int = O2.defaultPageSize
    
    
    required override init(){}
}

class O2SearchV2PageModel: NSObject, DataModel {
    var documentList:[O2SearchV2Entry] = []
    var count: Int = 0
    
    
    required override init(){}
}
class O2SearchV2Entry: NSObject, DataModel {
    @objc var id: String = "" // 业务id
    @objc var category: String = "" // cms processPlatform
    @objc var title: String = ""
    @objc    var highlighting: String = "" // html
    @objc    var summary: String = "" // 文字
    @objc    var creatorPerson: String = ""
    @objc var creatorUnit: String = ""
    @objc var indexTime: String = ""
    @objc var createTime: String = ""
    @objc var updateTime: String = ""
    
    
    required override init(){}
}
