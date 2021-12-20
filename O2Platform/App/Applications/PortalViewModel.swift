//
//  PortalViewModel.swift
//  O2Platform
//
//  Created by FancyLou on 2021/12/20.
//  Copyright © 2021 zoneland. All rights reserved.
//


import Promises
import CocoaLumberjack
import Moya
import Combine



class PortalViewModel {
    private let portalAPI = OOMoyaProvider<PortalAPI>()
    
    /// 查询我能看到的门户列表
    /// 和移动端门户列表进行排除
    func listMobile(localList: [O2App])-> Promise<[O2App]> {
        return Promise { fulfill, reject in
            self.portalAPI.request(.listMobile, completion: {result in
                let response = OOResult<BaseModelClass<[O2PortalInfo]>>(result)
                if response.isResultSuccess() {
                    if let list = response.model?.data {
                        var newLocal:[O2App] = []
                        for local in localList {
                            var isIn = false
                            for portal in list {
                                if portal.id != nil && portal.id == local.appId {
                                    isIn = true
                                }
                            }
                            if isIn {
                                newLocal.append(local)
                            }
                        }
                        fulfill(newLocal)
                    } else {
                        fulfill(localList)
                    }
                }else {
                    fulfill(localList)
                }
            })
        }
    }
}
