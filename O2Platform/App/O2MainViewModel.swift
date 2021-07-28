//
//  O2MainViewModel.swift
//  O2Platform
//
//  Created by FancyLou on 2021/7/28.
//  Copyright © 2021 zoneland. All rights reserved.
//


import Promises
import CocoaLumberjack


class O2MainViewModel: NSObject {
    override init() {
        super.init()
    }
    private let orgPermissionApi = OOMoyaProvider<OrganizationPermissionAPI>()
    private let contactExpressAPI = OOMoyaProvider<OOContactExpressAPI>()
}


extension O2MainViewModel {
    
    func loadOrgContactPermission() {
        let view = O2AuthSDK.shared.customStyle()?.contactPermissionView ?? O2.CUSTOM_STYLE_CONTACT_PERMISSION_DEFAULT
        DDLogDebug("查询权限的view ： \(view)")
        self.orgPermissionApi.request(.getPermissionViewInfo(view), completion: { result in
            let response = OOResult<BaseModelClass<OrganizationPermissionData>>(result)
            if response.isResultSuccess() {
                if let data = response.model?.data {
                    DDLogDebug("查询成功")
                    OrganizationPermissionManager.shared.initData(data: data)
                    // 查询person转身份
                    self.transferPerson2Identity(perList: OrganizationPermissionManager.shared.hideMobilePersons).then { (list) in
                        if list.count > 0 {
                            for item in list {
                                OrganizationPermissionManager.shared.hideMobilePersons.append(item)
                            }
                        }
                    }
                    
                    self.transferPerson2Identity(perList: OrganizationPermissionManager.shared.limitAll).then { (list) in
                        if list.count > 0 {
                            for item in list {
                                OrganizationPermissionManager.shared.limitAll.append(item)
                            }
                        }
                    }
                    
                    self.transferPerson2Identity(perList: OrganizationPermissionManager.shared.limitOuter).then { (list) in
                        if list.count > 0 {
                            for item in list {
                                OrganizationPermissionManager.shared.limitOuter.append(item)
                            }
                        }
                    }
                    
                    self.transferPerson2Identity(perList: OrganizationPermissionManager.shared.excludePersons).then { (list) in
                        if list.count > 0 {
                            for item in list {
                                OrganizationPermissionManager.shared.excludePersons.append(item)
                            }
                        }
                    }
                    
                }
            } else {
                DDLogError(response.error?.localizedDescription ?? "查询通讯录权限错误！")
            }
        })
    }
    
    /// 讲人员DN转化成身份DN
    func transferPerson2Identity(perList: [String]) -> Promise<[String]> {
        return Promise {fulfill, reject in
            self.contactExpressAPI.request(.personIdentityByPersonList(perList), completion: { result in
                let response = OOResult<BaseModelClass<PersonIdentityListData>>(result)
                if response.isResultSuccess() {
                    if let data = response.model?.data {
                        fulfill(data.identityList ?? [])
                    } else {
                        reject(O2APIError.o2ResponseError("数据为空"))
                    }
                }else {
                    reject(response.error!)
                }
            })
        }
    }
}
