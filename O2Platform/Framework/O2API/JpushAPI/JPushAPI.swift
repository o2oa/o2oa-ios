//
//  JPushAPI.swift
//  O2Platform
//
//  Created by FancyLou on 2019/11/8.
//  Copyright © 2019 zoneland. All rights reserved.
//

import Moya



// x_jpush_assemble_control 极光推送模块

enum JPushAPI {
    case pushConfig
    case bindDevice(JPushDevice)
    case unBindDevice(String)
    case unBindDeviceNew(String, String)
    
}
// 上下文根
extension JPushAPI: OOAPIContextCapable {
    var apiContextKey: String {
        return "x_jpush_assemble_control"
    }
}
// 是否需要xtoken
extension JPushAPI: OOAccessTokenAuthorizable {
    var shouldAuthorize: Bool {
        return true
    }
}

extension JPushAPI: TargetType {
    
    
    var baseURL: URL {
        let model = O2AuthSDK.shared.o2APIServer(context: .x_jpush_assemble_control)
        let baseURLString = "\(model?.httpProtocol ?? "http")://\(model?.host ?? ""):\(model?.port ?? 0)\(model?.context ?? "")"
        return URL(string: baseURLString)!
    }
    
    
    var path: String {
        switch self {
        case .pushConfig:
            return "/jaxrs/device/config/push/type"
        case .bindDevice(_):
            return "/jaxrs/device/bind"
        case .unBindDevice(let deviceName):
            return "/jaxrs/device/unbind/\(deviceName)/ios"
        case .unBindDeviceNew(let deviceToken, let pushType):
            return "/jaxrs/device/unbind/new/\(deviceToken)/ios/\(pushType)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .pushConfig:
            return .get
        case .bindDevice(_):
            return .post
        case .unBindDevice(_):
             return .delete
        case .unBindDeviceNew(_, _):
            return .get
        }
    }
    
    var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }
    
    var task: Task {
        switch self {
        case .pushConfig:
            return .requestPlain
        case .bindDevice(let device):
            return .requestParameters(parameters: device.toJSON()!, encoding: JSONEncoding.default)
        case .unBindDevice:
            return .requestPlain
        case .unBindDeviceNew(_, _):
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
   
}
