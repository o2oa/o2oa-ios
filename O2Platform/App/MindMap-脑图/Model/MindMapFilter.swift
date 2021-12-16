//
//  MindMapFilter.swift
//  O2Platform
//
//  Created by FancyLou on 2021/12/16.
//  Copyright © 2021 zoneland. All rights reserved.
//


import HandyJSON

class MindMapFilter: NSObject, DataModel {
    @objc var folderId: String? // 所属目录
    @objc var key: String? // 模糊搜索
    @objc var  desc: String?
    
    required override init(){}
    
    func mapping(mapper: HelpingMapper) {
        mapper <<< self.desc <-- "description"
    }
}
