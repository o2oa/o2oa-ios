//
//  PersonIdentityListData.swift
//  O2Platform
//
//  Created by FancyLou on 2021/7/28.
//  Copyright © 2021 zoneland. All rights reserved.
//

import HandyJSON


class PersonIdentityListData: NSObject, DataModel  {
    @objc  var identityList: [String]? = []
    
    required override init() { }

    func mapping(mapper: HelpingMapper) {

    }
}
