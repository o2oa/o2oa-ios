//
//  MindFolder.swift
//  O2Platform
//
//  Created by FancyLou on 2021/12/15.
//  Copyright © 2021 zoneland. All rights reserved.
//

import HandyJSON

// 脑图目录
class MindFolder : NSObject, DataModel {
    @objc var id: String?
    @objc var   name: String?
    @objc var  parentId: String? // 默认根目录id root
    var orderNumber: Int?
    var children: [MindFolder]? = []
    @objc var  desc: String?
    @objc var  creator: String?
    @objc var  creatorUnit: String?
    @objc var  createTime: String?
    @objc var  updateTime: String?
    @objc var  sequence: String?
    
    var level: Int? // 服务器没有level字段 查询结果转成list给tableview使用的时候填充 从1 开始
    var selected: Bool = false // 是否选中
   
    
    
    required override init(){}
    
    func mapping(mapper: HelpingMapper) {
        mapper <<< self.desc <-- "description"
    }
}
