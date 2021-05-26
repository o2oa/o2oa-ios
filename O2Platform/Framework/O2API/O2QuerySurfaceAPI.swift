//
//  O2QuerySurfaceAPI.swift
//  O2Platform
//
//  Created by FancyLou on 2021/5/25.
//  Copyright © 2021 zoneland. All rights reserved.
//

import Foundation
import Moya


enum O2QuerySurfaceAPI {
    // 搜索
    case segmentSearch(String)
    // 根据搜索的结果id 显示指定的搜索条目
    case segmentListEntry([String])
   
}

// MARK: - 通讯录上下文
extension O2QuerySurfaceAPI:OOAPIContextCapable {
    var apiContextKey: String {
        return "x_query_assemble_surface"
    }
}

// MARK: - 是否需要加入x-token访问头
extension O2QuerySurfaceAPI:OOAccessTokenAuthorizable {
    public var shouldAuthorize: Bool {
        return true
    }
}

// MARK: - 扩展API
extension O2QuerySurfaceAPI:TargetType {
    
    var baseURL: URL {
        let model = O2AuthSDK.shared.o2APIServer(context: .x_query_assemble_surface)
        let baseURLString = "\(model?.httpProtocol ?? "http")://\(model?.host ?? ""):\(model?.port ?? 0)\(model?.context ?? "")"
        return URL(string: baseURLString)!
    }
    
    var path: String {
        switch self {
        case .segmentSearch(let key):
            return "/jaxrs/segment/key/\(key)"
        case .segmentListEntry(_):
            return "/jaxrs/segment/list/entry"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .segmentSearch(_):
            return .get
        case .segmentListEntry(_):
            return .post
        }
    }
    
    var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }
    
    var task: Task {
        switch self {
        case .segmentSearch(_):
            return .requestPlain
        case .segmentListEntry(let list):
            return .requestParameters(parameters: ["entryList":  list], encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
   
    
    
}

