//
//  OrganizationPermissionManager.swift
//  O2Platform
//  应用市场 通讯录应用 可以管理通讯录权限
//  Created by FancyLou on 2021/7/28.
//  Copyright © 2021 zoneland. All rights reserved.
//

import CocoaLumberjack

class OrganizationPermissionManager {
    
    static let shared: OrganizationPermissionManager = {
       return OrganizationPermissionManager()
    }()
    
    private init() {}
    
    
    // 隐藏手机号码的人员列表
    var hideMobilePersons: [String] = []
    // 不查询的人员列表
    var excludePersons: [String] = []
    // 不查询的组织列表
    var excludeUnits: [String] = []
    // 不允许查询通讯录的人员
    var limitAll: [String] = []
    // 不允许查看外部门 包含人员和组织
    var limitOuter: [String] = []
    
    
    // 初始化数据
    func initData(data: OrganizationPermissionData) {
        DDLogDebug("初始化通讯录权限数据。。。。。。。")
        self.hideMobilePersons.removeAll()
        if let hidePersons = data.hideMobilePerson {
            let hidePersonsArr = hidePersons.split(",")
            for item in hidePersonsArr {
                self.hideMobilePersons.append(item)
            }
        }
        
        self.excludeUnits.removeAll()
        if let units = data.excludeUnit {
            let unitsArr = units.split(",")
            for item in unitsArr {
                self.excludeUnits.append(item)
            }
        }
        
        self.excludePersons.removeAll()
        if let eperson = data.excludePerson {
            let epersonArr = eperson.split(",")
            for item in epersonArr {
                self.excludePersons.append(item)
            }
        }
        
        self.limitAll.removeAll()
        if let all = data.limitQueryAll {
            let allArr = all.split(",")
            for item in allArr {
                self.limitAll.append(item)
            }
        }
        
        self.limitOuter.removeAll()
        if let outer = data.limitQueryOuter {
            let outerArr = outer.split(",")
            for item in outerArr {
                self.limitOuter.append(item)
            }
        }
    }
    
    /**
    * 判断 传入的人员是否需要隐藏手机号码
    * @param person 程剑@chengjian@P
    */
   func isHiddenMobile(person: String) -> Bool {
    return self.hideMobilePersons.contains(person)
   }

   /**
    * 判断 传入的人员是否要排除
    * @param person 程剑@chengjian@P
    */
   func isExcludePerson(person: String) -> Bool {
    return self.excludePersons.contains(person)
   }

   /**
    * 判断 传入的组织是否要排除
    * @param unit 团队领导@b7e3a8d3-21d4-4802-babf-9fc85392333d@U
    */
   func isExcludeUnit(unit: String) -> Bool {
    return self.excludeUnits.contains(unit)
   }

   /**
    * 判断 当前用户是否不能查询通讯录
    */
   func isCurrentPersonCannotQueryAll() -> Bool {
    if let currentDN = O2AuthSDK.shared.myInfo()?.distinguishedName {
        return self.limitAll.contains(currentDN)
    } else {
        return false
    }
   }

   /**
    * 判断 当前用户是否不能查询外部门
    */
   func isCurrentPersonCannotQueryOuter() -> Bool {
    if let currentDN = O2AuthSDK.shared.myInfo()?.distinguishedName {
        return limitOuter.contains(currentDN)
    } else {
           return false
       }
      
   }
    
    
}
