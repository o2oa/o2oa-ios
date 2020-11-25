//
//  O2MoyaProvider.swift
//  O2OA_SDK_Framwork
//
//  Created by FancyLou on 2018/11/8.
//

import Foundation
import Moya


class O2MoyaProvider<Target>: MoyaProvider<Target> where Target: TargetType {
    
    // MARK:- 打印出来的JSON格式化
    class func JSONResponseDataFormatter(_ data: Data) -> Data {
        do {
            let dataAsJSON = try JSONSerialization.jsonObject(with: data)
            let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
            return prettyData
        } catch {
            return data // fallback to original data if it can't be serialized.
        }
    }
    /// 网络请求状态改变插件
    var networkIndicatorPlugin:NetworkActivityPlugin = {
        return NetworkActivityPlugin(networkActivityClosure: { change,arg  in
            switch change {
            case .began:
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                }
                break
            case .ended:
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                break
            }
        })
    }()
    
    
    init() {
//        let policy = ServerTrustPolicyManager.serverTrustPolicy(
//        let manager = Manager(configuration: .default, serverTrustPolicyManager: ServerTrustPolicyManager)
//        (
//            configuration: URLSessionConfiguration.default,
//            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
//        )
        let loggerConfig = NetworkLoggerPlugin.Configuration(logOptions: .verbose)
        let networkLogger = NetworkLoggerPlugin(configuration: loggerConfig)
        super.init(plugins: [
            // 日志打印插件
//            NetworkLoggerPlugin(
//                verbose: true,
//                responseDataFormatter: O2MoyaProvider<Target>.JSONResponseDataFormatter
//            ),
            networkLogger,
            // 网络请求指示器插件
            networkIndicatorPlugin,
            // o2oa 认证插件
            O2AccessTokenPlugin()
            ])
    }
    
}
