//
//  O2LoginAPI.swift
//  O2OA_SDK_Framwork
//
//  Created by FancyLou on 2018/11/8.
//

import Foundation
import Moya

enum O2LoginAPI {
    case createLoginCode(String)
    
    case loginWithCredntial(String,String)
    
    case loginWithPassword(String, String)
    
    case loginWithToken(String)
    
    case loginWithScanCode(String)
    
    case loginWithSSO(String, String)
}



extension O2LoginAPI: O2APIContextCapable {
    var apiContextKey: String {
        return "x_organization_assemble_authentication"
    }
}


// MARK: - 是否需要加入x-token访问头
extension O2LoginAPI: O2AccessTokenAuthorizable {
    public var shouldAuthorize: Bool {
        switch self {
        //二维码登录时提交x-token
        case .loginWithScanCode(_):
            return true
        case .loginWithToken(_):
            return true
        default:
            //其它情况不需要x-token
            return false
        }
    }
}

extension O2LoginAPI: TargetType {
    public var headers: [String : String]? {
        return nil
    }
    
    
    public var baseURL: URL {
        let model = O2UserDefaults.shared.centerServer?.assembles![apiContextKey]
        let baseURLString = "\(model?.httpProtocol ?? "http")://\(model?.host ?? ""):\(model?.port ?? 80)\(model?.context ?? "")"
        if let trueUrl = O2AuthSDK.shared.bindUnitTransferUrl2Mapping(url: baseURLString) {
            return URL(string: trueUrl)!
        }
        return URL(string: baseURLString)!
    }
    
    public var path: String {
        switch self {
        case .createLoginCode(let credential):
            return "/jaxrs/authentication/code/credential/\(credential.urlEscaped)"
        case .loginWithCredntial(_,_):
            return "/jaxrs/authentication/code"
        case .loginWithToken(_):
            return "/jaxrs/authentication"
        case .loginWithPassword(_,  _):
            return "/jaxrs/authentication"
        case .loginWithScanCode(let meta):
            return "/jaxrs/authentication/bind/meta/\(meta.urlEscaped)"
        case .loginWithSSO(_, _):
            return "/jaxrs/sso"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .createLoginCode(_):
            return .get
        case .loginWithCredntial(_,_):
            return .post
        case .loginWithToken(_):
            return .get
        case .loginWithPassword(_, _):
            return .post
        case .loginWithScanCode(_):
            return .post
        case .loginWithSSO(_, _):
            return .post
        }
    }
    
    
    
    public var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }
    
    public var task: Task {
        switch self {
        case .createLoginCode(_):
            return .requestPlain
        case .loginWithCredntial(let username, let codeAnswer):
            return .requestParameters(parameters: ["credential":username,"codeAnswer":codeAnswer], encoding: JSONEncoding.default)
        case .loginWithToken(_):
            return .requestPlain
        case .loginWithPassword(let username, let password):
            return .requestParameters(parameters: ["credential":username,"password":password], encoding: JSONEncoding.default)
        case .loginWithScanCode(_):
            return .requestPlain
        case .loginWithSSO(let client, let token):
            return .requestParameters(parameters: ["client": client,"token": token], encoding: JSONEncoding.default)
        }
    }
    
    
}
