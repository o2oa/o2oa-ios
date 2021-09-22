//
//  OrganizationPermissionAPI.swift
//  O2Platform
//  custom模块 通讯录 需要到应用市场下载安装
//  Created by FancyLou on 2021/7/28.
//  Copyright © 2021 zoneland. All rights reserved.
//

import Moya


enum OrganizationPermissionAPI {
    case getPermissionViewInfo(String)
}

extension OrganizationPermissionAPI: OOAPIContextCapable {
    var apiContextKey: String {
           return "x_organizationPermission"
       }
}

// 是否需要xtoken
extension OrganizationPermissionAPI: OOAccessTokenAuthorizable {
    var shouldAuthorize: Bool {
        return true
    }
}

extension OrganizationPermissionAPI: TargetType {
    var baseURL: URL {
        let model  = O2AuthSDK.shared.centerServerInfo()?.assembles?["x_organizationPermission"]
        let baseURLString = "\(model?.httpProtocol ?? "http")://\(model?.host ?? ""):\(model?.port ?? 80)\(model?.context ?? "")"
        if let trueUrl = O2AuthSDK.shared.bindUnitTransferUrl2Mapping(url: baseURLString) {
            return URL(string: trueUrl)!
        }
        return URL(string: baseURLString)!
    }
    
    var path: String {
        switch self {
        case .getPermissionViewInfo(let view):
            return "/jaxrs/permission/view/\(view)"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }
    
    var task: Task {
        return .requestPlain
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    
}

