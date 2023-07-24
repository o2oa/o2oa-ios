//
//  O2PortalInfo.swift
//  O2Platform
//
//  Created by FancyLou on 2021/12/20.
//  Copyright © 2021 zoneland. All rights reserved.
//

import HandyJSON

class O2PortalInfo:NSObject, DataModel {

    @objc var alias : String?
    @objc var createTime : String?
    @objc var creatorPerson : String?
    @objc var desc : String?
    @objc var firstPage : String?
    @objc var id : String?
    @objc var lastUpdatePerson : String?
    @objc var lastUpdateTime : String?
    @objc var name : String?
    @objc var portalCategory : String?
    @objc var updateTime : String?
    var pcClient: Bool?
    var mobileClient: Bool?
    
    required override init(){}
    
    func mapping(mapper: HelpingMapper) {
        mapper <<< self.desc <-- "description"
    }
}


class O2PortalCornerMarkNumber: NSObject, DataModel {
    var count: Int?
    
    required override init(){}
}
