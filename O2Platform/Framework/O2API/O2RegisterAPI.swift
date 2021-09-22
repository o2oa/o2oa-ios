//
//  O2AuthenticationAPI.swift
//  O2OA_SDK_Framwork
//
//  Created by FancyLou on 2018/11/7.
//

import Foundation
import Moya

enum O2RegisterAPI {
    // MARK:- 生成手机验证码，参数是手机号
    case generateVerifiyCode(O2NodeReqModel)
    
    // MARK:- 校验手机收到的验证码，参数是手机号，收到的短信验证码
    case verifiyCode(O2NodeReqModel)
    
    // MARK:- 绑定设备与手机号
    case bindMobileToDevice(O2BindDeviceModel)
    
    // MARK:- 校验绑定信息
    case queryBindInfo(O2BindDeviceModel)
    
    // MARK:- 解除绑定
    case unBindFromDevice(O2BindDeviceModel)
    
    // MARK:- 下载指定节点数据
    case downloadNodeAPI(O2BindUnitModel)
    
    // MARK:- 校检配置是否更新
    case verConfigInfo(O2BindUnitModel)
    
    // MARK:- 下载配置信息
    case downloadConfigInfo(O2BindUnitModel)
    
    // MARK:- 校验节点信息
    case verNodeUnit(O2BindDeviceModel)
    
    // MARK: - 设备列表 unitId, accountId, token
    case deviceList(String, String, String)
    
}



// MARK: - 是否加入访问的x-token头
extension O2RegisterAPI: O2AccessTokenAuthorizable {
    public var shouldAuthorize: Bool {
        return false
    }
}

extension O2RegisterAPI: TargetType {
    public var headers: [String : String]? {
        return nil
    }
    
    public var baseURL:URL {
        switch self {
        case .downloadNodeAPI(let node),.verConfigInfo(let node),.downloadConfigInfo(let node):
            let urlString = "\(node.httpProtocol ?? "http")://\(node.centerHost!):\(node.centerPort!)"
            if let trueUrl = node.transUrl2Mapping(url: urlString) {
                return URL(string: trueUrl)!
            }
            return URL(string:urlString)!
        default:
            return URL(string: O2ConfigInfo.COLLECT_SERVER_URL)!
        }
    }
    
    public var path:String {
        switch self {
        case .generateVerifiyCode(_):
            return "/jaxrs/code"
        case .verifiyCode(let model):
            return "/jaxrs/unit/list/account/\(model.mobile ?? "")/code/\(model.value ?? "")"
        case .bindMobileToDevice(_):
            return "/jaxrs/device/account/bind"
        case .queryBindInfo(let model):
            return "/jaxrs/unit/find/\(model.unit ?? "")/\(model.mobile ?? "")/\(model.name ?? "")/ios"
        case .unBindFromDevice(let model):
            return "/jaxrs/device/name/\(model.name ?? "")/unbind"
        case .downloadNodeAPI(let node):
            return "\(node.centerContext ?? "")/jaxrs/distribute/webserver/assemble/source/\(node.centerHost ?? "")"
        case .verConfigInfo(let node):
            return "\(node.centerContext ?? "")/jaxrs/appstyle/current/update"
        case .downloadConfigInfo(let node):
            return "\(node.centerContext ?? "")/jaxrs/appstyle/current/style"
        case .verNodeUnit(let unit):
            return "/jaxrs/unit/find/\(unit.unit ?? "")/\(unit.mobile ?? "")/\(unit.name ?? "")/ios"
        case .deviceList(let unitId, let accountId, let token):
            return "/jaxrs/device/list/unit/\(unitId)/account/\(accountId)/device/\(token)"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .generateVerifiyCode(_):
            return .post
        case .verifiyCode(_):
            return .get
        case .bindMobileToDevice(_):
            return .post
        case .queryBindInfo(_):
            return .get
        case .unBindFromDevice(_):
            return .delete
        case .downloadNodeAPI(_):
            return .get
        case .verConfigInfo(_):
            return .get
        case .downloadConfigInfo(_):
            return .get
        case .verNodeUnit(_):
            return .get
        case .deviceList(_, _, _):
            return .get
        }
    }
    
    public var parameters: [String : Any]? {
        switch self {
        case .generateVerifiyCode(let model):
            return model.toJSON()
        case .verifiyCode(_):
            return nil
        case .bindMobileToDevice(let model):
            return model.toJSON()
        case .queryBindInfo(_):
            return nil
        case .unBindFromDevice(_):
            return nil
        case .downloadNodeAPI(_):
            return nil
        case .verConfigInfo(_):
            return nil
        case .downloadConfigInfo(_):
            return nil
        case .verNodeUnit(_):
            return nil
        case .deviceList(_, _, _):
            return nil
        }
    }
    
    
    public var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }
    
    public var task: Task {
        switch self {
        case .generateVerifiyCode(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: JSONEncoding.default)
        case .verifiyCode(_):
            return .requestPlain
        case .bindMobileToDevice(let model):
            return .requestParameters(parameters: model.toJSON()!, encoding: JSONEncoding.default)
        case .queryBindInfo(_):
            return .requestPlain
        case .unBindFromDevice(_):
            return .requestPlain
        case .downloadNodeAPI(_):
            return .requestPlain
        case .verConfigInfo(_):
            return .requestPlain
        case .downloadConfigInfo(_):
            return .requestPlain
        case .verNodeUnit(_):
            return .requestPlain
        case .deviceList(_, _, _):
            return .requestPlain
        }
    }
    
}

