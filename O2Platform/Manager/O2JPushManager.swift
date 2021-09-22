//
//  O2JPushManager.swift
//  O2Platform
//
//  Created by FancyLou on 2019/11/11.
//  Copyright © 2019 zoneland. All rights reserved.
//

import UIKit
import Moya

import Promises
import CocoaLumberjack


typealias PushCallback = () -> Void

class O2JPushManager {
    static let shared: O2JPushManager = {
        return O2JPushManager()
    }()
    
    private init() {
        
    }
    
    private let o2JPushAPI = {
        return OOMoyaProvider<JPushAPI>()
    }()
    
    private func pushConfig(completedBlock:@escaping PushCallback) {
        DDLogDebug("请求推送配置，目前启用的通道是极光还是华为")
        if let _ = O2AuthSDK.shared.o2APIServer(context: .x_jpush_assemble_control) {
            self.o2JPushAPI.request(.pushConfig) { result in
                let response = OOResult<BaseModelClass<JPushConfig>>(result)
                if response.isResultSuccess() {
                    let type = response.model?.data?.pushType ?? "jpush"
                    O2AuthSDK.shared.setPushType(type: type)
                }else {
                    O2AuthSDK.shared.setPushType(type: "jpush")
                    DDLogError(response.error?.localizedDescription ?? "绑定设备到服务器失败！")
                }
                completedBlock()
            }
        }else {
            DDLogError("绑定，没有获取到极光推送消息模块，服务器版本不支持！！！！！")
            O2AuthSDK.shared.setPushType(type: "jpush")
            completedBlock()
        }
    }
    
    //直连版本 连接o2oa服务器绑定设备号到个人属性中
    func o2JPushBind() {
        DDLogDebug("绑定设备号")
        if let _ = O2AuthSDK.shared.o2APIServer(context: .x_jpush_assemble_control) {
            pushConfig {
                let pushType = O2AuthSDK.shared.getPushType()
                let device = JPushDevice()
                // apns deviceToken 华为推送通道的时候用
                if pushType == "jpush" {
                    let deviceName = O2AuthSDK.shared.getDeviceToken() // jpush 的deviceToken
                    device.deviceName = deviceName
                } else {
                    let deviceToken = O2AuthSDK.shared.getApnsToken()
                    device.deviceName = deviceToken
                }
                device.deviceType = "ios"
                device.pushType = pushType
                self.o2JPushAPI.request(.bindDevice(device)) { (result) in
                    let response = OOResult<BaseModelClass<OOCommonValueBoolModel>>(result)
                    if response.isResultSuccess() {
                        let value = response.model?.data
                        DDLogInfo("绑定设备到服务器，结果：\(value?.value ?? false)")
                    }else {
                        DDLogError(response.error?.localizedDescription ?? "绑定设备到服务器失败！")
                    }
                }
            }
        }else {
            DDLogError("绑定，没有获取到极光推送消息模块，服务器版本不支持！！！！！")
        }
    }
    
    func O2JPushUnBind() {
        DDLogDebug("解除绑定设备号")
        if let _ = O2AuthSDK.shared.o2APIServer(context: .x_jpush_assemble_control) {
            let deviceName = O2AuthSDK.shared.getDeviceToken()
            let pushType = O2AuthSDK.shared.getPushType()
            self.o2JPushAPI.request(.unBindDeviceNew(deviceName, pushType)) { (result) in
                let response = OOResult<BaseModelClass<OOCommonValueBoolModel>>(result)
                if response.isResultSuccess() {
                    let value = response.model?.data
                    DDLogInfo("解绑设备号 ，结果：\(value?.value ?? false)")
                } else {
                    DDLogDebug("老的解绑方式。。。。。")
                    self.o2JPushAPI.request(.unBindDevice(deviceName)) { (result) in
                        let response = OOResult<BaseModelClass<OOCommonValueBoolModel>>(result)
                        if response.isResultSuccess() {
                            let value = response.model?.data
                            DDLogInfo("解绑设备号 ，结果：\(value?.value ?? false)")
                        }else {
                            DDLogError(response.error?.localizedDescription ?? "解绑设备号 失败！")
                        }
                    }
                }
            }
        }else {
            DDLogError("解绑，没有获取到极光推送消息模块，服务器版本不支持！！！！！")
        }
    }
}
