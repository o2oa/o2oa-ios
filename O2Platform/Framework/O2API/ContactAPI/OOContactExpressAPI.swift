//
//  OOContactExpressAPI.swift
//  O2Platform
//
//  Created by FancyLou on 2019/8/13.
//  Copyright © 2019 zoneland. All rights reserved.
//

import Moya


//x_organization_assemble_express

enum OOContactExpressAPI {
    //根据职务列表和组织查询 组织下对应的身份列表
    case identityListByUnitAndDuty([String], String)
    //查询人员person的dn
    case personListDN([String])
    // 人员转身份
    case personIdentityByPersonList([String])
}


extension OOContactExpressAPI: OOAPIContextCapable {
    var apiContextKey: String {
        return "x_organization_assemble_express"
    }
}

extension OOContactExpressAPI: OOAccessTokenAuthorizable {
    var shouldAuthorize: Bool {
        return true
    }
}

extension OOContactExpressAPI: TargetType {
    var baseURL: URL {
        let model = O2AuthSDK.shared.o2APIServer(context: .x_organization_assemble_express)
        let baseURLString = "\(model?.httpProtocol ?? "http")://\(model?.host ?? ""):\(model?.port ?? 80)\(model?.context ?? "")"
        if let trueUrl = O2AuthSDK.shared.bindUnitTransferUrl2Mapping(url: baseURLString) {
            return URL(string: trueUrl)!
        }
        return URL(string: baseURLString)!
    }
    
    var path: String {
        switch self {
        case .identityListByUnitAndDuty(_, _):
            return "/jaxrs/unitduty/list/identity/unit/name/object"
        case .personListDN(_):
            return "/jaxrs/person/list"
        case .personIdentityByPersonList(_):
            return "/jaxrs/identity/list/person"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .identityListByUnitAndDuty(_, _), .personListDN(_), .personIdentityByPersonList(_):
            return .post
        }
    }
    
    var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }
    
    var task: Task {
        switch self {
        case .identityListByUnitAndDuty(let dutyList, let unit):
            return .requestParameters(parameters: ["nameList": dutyList, "unit": unit], encoding: JSONEncoding.default)
        case .personListDN(let idList):
            return.requestParameters(parameters: ["personList": idList], encoding: JSONEncoding.default)
        case .personIdentityByPersonList(let personList):
            return.requestParameters(parameters: ["personList": personList], encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    
}

