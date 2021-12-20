//
//  PortalAPI.swift
//  O2Platform
//
//  Created by FancyLou on 2021/12/20.
//  Copyright © 2021 zoneland. All rights reserved.
//


import Moya


enum PortalAPI {
    case listMobile
}

extension PortalAPI: OOAPIContextCapable {
    var apiContextKey: String {
           return "x_portal_assemble_surface"
       }
}

// 是否需要xtoken
extension PortalAPI: OOAccessTokenAuthorizable {
    var shouldAuthorize: Bool {
        return true
    }
}


extension PortalAPI: TargetType {
    var baseURL: URL {
        let model  = O2AuthSDK.shared.centerServerInfo()?.assembles?["x_portal_assemble_surface"]
        let baseURLString = "\(model?.httpProtocol ?? "http")://\(model?.host ?? ""):\(model?.port ?? 80)\(model?.context ?? "")"
        if let trueUrl = O2AuthSDK.shared.bindUnitTransferUrl2Mapping(url: baseURLString) {
            return URL(string: trueUrl)!
        }
        return URL(string: baseURLString)!
    }
    
    var path: String {
        switch self {
        case .listMobile:
            return "/jaxrs/portal/list/mobile"
        }
    }
    
    var method:  Moya.Method {
        switch self {
        case .listMobile:
            return .get
        }
    }
    
    var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }
    
    var task: Task {
        switch self {
        case .listMobile:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    
}
