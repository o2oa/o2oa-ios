//
//  O2AccessTokenAuthorizable.swift
//  O2OA_SDK_Framwork
//
//  Created by FancyLou on 2018/11/7.
//

import Foundation
import Moya

public protocol O2APIContextCapable {
    var apiContextKey:String { get }
}

public protocol O2AccessTokenAuthorizable {
    var shouldAuthorize: Bool { get }
}

public class O2AccessTokenPlugin:PluginType {
    
    public init() {}
    
    var tokenVal:String {
        get {
            guard let myInfo = O2UserDefaults.shared.myInfo else {
                return ""
            }
            return myInfo.token ?? ""
        }
    }
    
    var clientVal:String {
        get {
            let version = ProcessInfo.processInfo.operatingSystemVersion
            let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
            return "iOS \(versionString)"
        }
    }
    
    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var request = request
        //加上通用头
        request.addValue(clientVal, forHTTPHeaderField: "x-client")
        if let authorizable = target as? O2AccessTokenAuthorizable,authorizable.shouldAuthorize ==  false {
            return request
        }
        //加上token
        let tokenName = O2AuthSDK.shared.tokenName()
        request.addValue(tokenVal, forHTTPHeaderField: tokenName)
        return request
    }
    
    
}
