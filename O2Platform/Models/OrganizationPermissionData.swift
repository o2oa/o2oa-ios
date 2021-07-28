//
//  File.swift
//  O2Platform
//
//  Created by FancyLou on 2021/7/28.
//  Copyright © 2021 zoneland. All rights reserved.
//

import HandyJSON


class OrganizationPermissionData: NSObject, DataModel  {
    @objc var excludePerson: String? // 不允许被查询个人 人员数据
    @objc var excludeUnit: String? // 不允许被查询单位  组织数据
    @objc var hideMobilePerson: String? // 隐藏手机号码的人员 人员数据
    @objc var limitQueryAll: String?// 限制查看所有人 人员数据
    @objc var limitQueryOuter: String? // 限制查看外部门 有人员数据和组织数据
    
    required override init() { }

    func mapping(mapper: HelpingMapper) {

    }
}
