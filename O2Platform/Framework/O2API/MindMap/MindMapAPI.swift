//
//  MindMapAPI.swift
//  O2Platform
//
//  Created by FancyLou on 2021/12/16.
//  Copyright © 2021 zoneland. All rights reserved.
//


import Moya


enum MindMapAPI {
    case myFolderTree
    case listNextWithFilter(String, MindMapFilter)
}


extension MindMapAPI: OOAPIContextCapable {
    var apiContextKey: String {
        return "x_mind_assemble_control"
    }
}

// 是否需要xtoken
extension MindMapAPI: OOAccessTokenAuthorizable {
    var shouldAuthorize: Bool {
        return true
    }
}

extension MindMapAPI: TargetType {
    var baseURL: URL {
        let model = O2AuthSDK.shared.o2APIServer(context: .x_mind_assemble_control)
        let baseURLString = "\(model?.httpProtocol ?? "http")://\(model?.host ?? ""):\(model?.port ?? 80)\(model?.context ?? "")"
        if let trueUrl = O2AuthSDK.shared.bindUnitTransferUrl2Mapping(url: baseURLString) {
            return URL(string: trueUrl)!
        }
        return URL(string: baseURLString)!
    }
    
    var path: String {
        switch self {
        case .myFolderTree:
            return "/jaxrs/folder/tree/my"
        case .listNextWithFilter(let id, _):
            return "/jaxrs/mind/filter/list/\(id)/next/\(O2.defaultPageSize)"
        }
    }
    
    var method: Moya.Method  {
        switch self {
        case .myFolderTree:
            return .get
        case .listNextWithFilter(_, _):
            return .put
        }
    }
    
    var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }
    
    var task: Task {
        switch self {
        case .myFolderTree:
            return .requestPlain
        case .listNextWithFilter(_, let filter):
            return .requestParameters(parameters: filter.toJSON() ?? [:], encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    
}
