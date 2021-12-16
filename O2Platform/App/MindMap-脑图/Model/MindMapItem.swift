//
//  MindMapItem.swift
//  O2Platform
//
//  Created by FancyLou on 2021/12/16.
//  Copyright © 2021 zoneland. All rights reserved.
//
//"id": "6024a33d-3208-4d0a-9b03-026117093e92",
//"name": "1111",
//"folderId": "root",
//"icon": "",
//"description": "",
//"creator": "楼国栋@237@P",
//"creatorUnit": "移动开发组@320494093@U",
//"shared": false,
//"cooperative": false,
//"sharePersonList": [],
//"shareUnitList": [],
//"shareGroupList": [],
//"editorList": [
//"楼国栋@237@P"
//],
//"shared_sequence": "false202112151734106024a33d-3208-4d0a-9b03-026117093e92",
//"folder_sequence": "root202112151734106024a33d-3208-4d0a-9b03-026117093e92",
//"creator_sequence": "楼国栋@237@P202112151734106024a33d-3208-4d0a-9b03-026117093e92",
//"creatorUnit_sequence": "移动开发组@320494093@U202112151734106024a33d-3208-4d0a-9b03-026117093e92",
//"cooperative_sequence": "false202112151734106024a33d-3208-4d0a-9b03-026117093e92",
//"fileVersion": 2,
//"createTime": "2021-12-15 17:34:10",
//"updateTime": "2021-12-15 17:34:11",
//"sequence": "202112151734106024a33d-3208-4d0a-9b03-026117093e92"


import HandyJSON

// 脑图
class MindMapItem : NSObject, DataModel {
    @objc var id: String?
    @objc var name: String?
    @objc var folderId: String? // 所属目录
    @objc var icon: String? // 预览图 id
    @objc var  desc: String?
    @objc var  creator: String?
    @objc var  creatorUnit: String?
    var shared: Bool?
    var cooperative: Bool?
    var fileVersion:Int?
    @objc var  createTime: String?
    @objc var  updateTime: String?
    
    var sharePersonList:[String] = []
    var shareUnitList:[String] = []
    var shareGroupList:[String] = []
    var editorList:[String] = []
    
    
    required override init(){}
    
    func mapping(mapper: HelpingMapper) {
        mapper <<< self.desc <-- "description"
    }
}
