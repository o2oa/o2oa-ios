//
//  OOMoyaProvider.swift
//  o2app
//
//  Created by 刘振兴 on 2017/8/18.
//  Copyright © 2017年 zone. All rights reserved.
//

import Foundation
import Moya




// MARK:- 自定义Provider
public class OOMoyaProvider<Target>: MoyaProvider<Target> where Target: TargetType {
    
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
    
    private let networkActivityPlugin  = NetworkActivityPlugin(networkActivityClosure: { change,arg  in
            switch change {
            case .began:
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                break
            case .ended:
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                break
            }
        })
    
    
    /// 网络请求状态改变插件
    var netPlugin:NetworkActivityPlugin = {
        return NetworkActivityPlugin(networkActivityClosure: { change,arg  in
            switch change {
            case .began:
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                break
            case .ended:
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                break
            }
        })
    }()
    
    init() {
        
        let loggerConfig = NetworkLoggerPlugin.Configuration(logOptions: .verbose)
        let networkLogger = NetworkLoggerPlugin(configuration: loggerConfig)
//        let verbose = NetworkLoggerPlugin.Configuration(formatter: OOMoyaProvider<Target>.JSONResponseDataFormatter, output: O2AccessTokenPlugin(), logOptions: .verbose)
        super.init(plugins: [networkLogger, O2AccessTokenPlugin()])
    }
    
    
    
}


