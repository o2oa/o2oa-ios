//
//  EmpowerData.swift
//  O2Platform
//
//  Created by FancyLou on 2023/5/17.
//  Copyright © 2023 zoneland. All rights reserved.
//

import HandyJSON



class EmpowerData: NSObject, DataModel  {
    
    @objc var id : String?
    @objc var fromPerson : String?
    @objc var fromIdentity : String?
    @objc var toPerson : String?
    @objc var toIdentity : String?
    @objc var type : String? // all application  process
    @objc var startTime : String?
    @objc var completedTime : String?
    var enable : Bool? // 是否启用
    @objc var application : String?
    @objc var applicationName : String?
    @objc var applicationAlias : String?
    @objc var edition : String? // 流程版本号
    @objc var process : String?
    @objc var processName : String?
    @objc var processAlias : String?
   
    
    required override init(){}
    
     
}
