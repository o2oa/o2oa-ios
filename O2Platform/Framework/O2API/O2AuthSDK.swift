//
//  O2AuthSDK.swift
//  O2OA_SDK_Framwork
//
//  Created by FancyLou on 2018/11/6.
//

import UIKit
import RxSwift
import Moya
import CocoaLumberjack



public class O2AuthSDK: NSObject {
    
    /// 单例
    public static let shared: O2AuthSDK = O2AuthSDK()
    
    private override init() {}
    
    private let registerAPI: O2MoyaProvider<O2RegisterAPI> = {
        return O2MoyaProvider<O2RegisterAPI>()
    }()
    private let loginAPI: O2MoyaProvider<O2LoginAPI> = {
       return O2MoyaProvider<O2LoginAPI>()
    }()
    
    
    //MARK: - public 公开本地对象
    
    private var bbsMuteInfo: O2BBSMuteInfo? // 论坛禁言对象
    
    func setupMuteInfo(muteInfo: O2BBSMuteInfo?) {
        self.bbsMuteInfo = muteInfo
    }
    
    // 是否禁言
    public func isBBSMute() -> Bool {
        if (self.bbsMuteInfo == nil){
            return false
        }
        guard let expireDate = self.bbsMuteInfo?.unmuteDate else {
            return false
        }
        DDLogDebug(" expireDate \(expireDate)")
        if let date = Date.date(expireDate, formatter: "yyyy-MM-dd"), !date.isBefore(date: Date()) {
            return true
        }
        return false
    }
    
    
    /// 当前登录用户信息
    ///
    /// - Returns:
    public func myInfo() -> O2LoginAccountModel? {
        return O2UserDefaults.shared.myInfo
    }
    
    /// 当前绑定单位服务器信息
    ///
    /// - Returns:
    public func bindUnit() -> O2BindUnitModel? {
        return O2UserDefaults.shared.unit
    }
    
    /// 如果有代理地址 替换成代理地址
    ///
    public func bindUnitTransferUrl2Mapping(url: String) -> String? {
        var result: String? = nil
        if let unit = bindUnit() {
            result = unit.transUrl2Mapping(url: url)
        }
        return result
    }
    
    /// 当前绑定的设备信息
    ///
    /// - Returns:
    public func bindDevice() -> O2BindDeviceModel? {
        return O2UserDefaults.shared.device
    }
    
    /// 设置设备token 极光推送用的
    ///
    /// - Parameter token: 极光推送deviceToken
    public func setDeviceToken(token: String) {
        O2UserDefaults.shared.deviceToken = token
    }
    
    /// 获取设备token
    ///
    /// - Returns: 极光推送deviceToken
    public func getDeviceToken() -> String {
        return O2UserDefaults.shared.deviceToken ?? ""
    }
    
    /// 设置推送通道
    ///
    /// - Parameter type:  jpush|huawei
    public func setPushType(type: String) {
        O2UserDefaults.shared.pushType = type
    }
    
    public func getPushType() -> String {
        return O2UserDefaults.shared.pushType ?? "jpush"
    }
    
    /// 设置 苹果推送的设备token
    ///
    /// - Parameter token:  设备token
    public func setApnsToken(token: String) {
        O2UserDefaults.shared.apnsToken = token
    }
    
    public func getApnsToken() -> String {
        return O2UserDefaults.shared.apnsToken ?? ""
    }
    
    /// O2OA服务器信息
    ///
    /// - Returns:
    public func centerServerInfo() -> O2CenterServerModel? {
        return O2UserDefaults.shared.centerServer
    }
    
    /// 获取O2OA服务端的tokenName
    ///
    public func tokenName() -> String {
        if let center  = O2UserDefaults.shared.centerServer {
            if let tokenName = center.tokenName {
                return tokenName
            }
        }
        return "x-token"
    }
    
    /// O2OA 服务器 各个微服务信息
    ///
    /// - Parameter context: 微服务
    /// - Returns:
    public func o2APIServer(context: O2ModuleContext) -> O2APIServerModel? {
        guard let dic = O2UserDefaults.shared.centerServer?.assembles else {
            return nil
        }
        switch context {
        case .x_processplatform_assemble_surface_script:
            return dic["x_processplatform_assemble_surface_script"]
            
        case .x_processplatform_assemble_surface_task:
            return dic["x_processplatform_assemble_surface_task"]
            
        case .x_processplatform_assemble_surface_worklog:
            return dic["x_processplatform_assemble_surface_worklog"]
            
        case .x_processplatform_assemble_surface_workcompleted:
            return dic["x_processplatform_assemble_surface_workcompleted"]
            
        case .x_processplatform_assemble_surface_attachment:
            return dic["x_processplatform_assemble_surface_attachment"]
            
        case .x_processplatform_assemble_surface_work:
            return dic["x_processplatform_assemble_surface_work"]
            
        case .x_file_assemble_control:
            return dic["x_file_assemble_control"]
            
        case .x_pan_assemble_control:
            return dic["x_pan_assemble_control"]
            
        case .x_meeting_assemble_control:
            return dic["x_meeting_assemble_control"]
            
        case .x_attendance_assemble_control:
            return dic["x_attendance_assemble_control"]
            
        case .x_okr_assemble_control:
            return dic["x_okr_assemble_control"]
            
        case .x_bbs_assemble_control:
            return dic["x_bbs_assemble_control"]
            
        case .x_hotpic_assemble_control:
            return dic["x_hotpic_assemble_control"]
            
        case .x_processplatform_assemble_surface_applicationdict:
            return dic["x_processplatform_assemble_surface_applicationdict"]
            
        case .x_cms_assemble_control:
            return dic["x_cms_assemble_control"]
            
        case .x_organization_assemble_control:
            return dic["x_organization_assemble_control"]
            
        case .x_collaboration_assemble_websocket:
            return dic["x_collaboration_assemble_websocket"]
            
        case .x_organization_assemble_custom:
            return dic["x_organization_assemble_custom"]
            
        case .x_processplatform_assemble_surface:
            return dic["x_processplatform_assemble_surface"]
            
        case .x_processplatform_assemble_surface_read:
            return dic["x_processplatform_assemble_surface_read"]
            
        case .x_processplatform_assemble_surface_readcompleted:
            return dic["x_processplatform_assemble_surface_readcompleted"]
            
        case .x_organization_assemble_express:
            return dic["x_organization_assemble_express"]
            
        case .x_organization_assemble_personal:
            return dic["x_organization_assemble_personal"]
            
        case .x_processplatform_assemble_surface_taskcompleted:
            return dic["x_processplatform_assemble_surface_taskcompleted"]
            
        case .x_processplatform_assemble_surface_process:
            return dic["x_processplatform_assemble_surface_process"]
            
        case .x_component_assemble_control:
            return dic["x_component_assemble_control"]
            
        case .x_processplatform_assemble_surface_application:
            return dic["x_processplatform_assemble_surface_application"]
            
        case .x_processplatform_assemble_surface_data:
            return dic["x_processplatform_assemble_surface_data"]
            
        case .x_processplatform_assemble_designer:
            return dic["x_processplatform_assemble_designer"]
            
        case .x_processplatform_assemble_surface_review:
            return dic["x_processplatform_assemble_surface_review"]
            
        case .x_organization_assemble_authentication:
            return dic["x_organization_assemble_authentication"]
            
        case .x_portal_assemble_surface:
            return dic["x_portal_assemble_surface"]
            
        case .x_calendar_assemble_control:
            return dic["x_calendar_assemble_control"]
       
        case .x_jpush_assemble_control:
            return dic["x_jpush_assemble_control"]
            
        case .x_query_assemble_surface:
            return dic["x_query_assemble_surface"]
            
        case .x_organizationPermission:
            return dic["x_organizationPermission"]
            
        case .x_mind_assemble_control:
            return dic["x_mind_assemble_control"]
        }
        
        
    }
    
    /// 移动端配置信息
    ///
    /// - Returns:
    public func customStyle() -> O2CustomStyleModel? {
        return O2UserDefaults.shared.customStyle
    }
    
    /// 移动端配置hash值
    ///
    /// - Returns:
    public func customStyleHash() -> String? {
        return O2UserDefaults.shared.customStyleHash
    }
    
    /// 移动端应用列表
    ///
    /// - Returns:
    public func o2AppList() -> [O2AppModel] {
        var list: [O2AppModel] = []
        if let nativeList = O2UserDefaults.shared.customStyle?.nativeAppList {
            for native in nativeList {
                let app = O2AppModel()
                app.id = native.key
                app.name = native.name
                app.portalUrl = ""
                app.portalCategory = ""
                app.type = O2ConfigInfo.O2_APP_TYPE_NATIVE
                app.enable = native.enable
                list.append(app)
            }
        }
        if let portalList = O2UserDefaults.shared.customStyle?.portalList {
            for portal in portalList {
                let app = O2AppModel()
                app.id = portal.id
                app.name = portal.name
                if let webserver = O2UserDefaults.shared.centerServer?.webServer {
                    var baseURLString = "\(webserver.httpProtocol ?? "http")://\(webserver.host ?? ""):\(webserver.port ?? 80)/\(O2ConfigInfo.O2_DESKTOP_CONTEXT)/appMobile.html?app=portal.Portal&status={\"portalId\":\"\(portal.id ?? "")\"}"
                    if let trueUrl = O2AuthSDK.shared.bindUnitTransferUrl2Mapping(url: baseURLString) {
                        baseURLString = trueUrl
                    }
                    app.portalUrl = baseURLString
                }
                app.portalCategory = portal.portalCategory
                app.type = O2ConfigInfo.O2_APP_TYPE_PORTAL
                app.enable = portal.enable
                list.append(app)
            }
        }
        
        return list
    }

    
    //MARK: - public 公开方法
    
    /// 启动
    /// 整个过程包括绑定信息检查，客户端信息检查，登录检查
    /// - Parameter callback: O2LaunchProcessState
    public func launch(callback: @escaping (_ state: O2LaunchProcessState, _ msg: String?)->()) {
        _ = checkBindUnit()
//            .flatMap { (device) -> Observable<Response> in
//            return self.checkBindUnitIsExpired(device: device)
//            }
            .flatMap { (unit) -> Observable<Response> in
//                let o2Res = response.mapObject(BaseO2ResponseData<O2BindUnitModel>.self)
//                if o2Res?.isSuccess() == false {
//                    throw O2AuthError.bindExpireError
//                }else {
//                    guard let unit = o2Res?.data else {
//                        throw O2AuthError.bindExpireError
//                    }
//                    // 每次验证完成后更新unit 信息 ， 连接unit的中心服务器
//                    O2UserDefaults.shared.unit = unit
//                    return self.connectToCenterServer(unit: unit)
//                }
                return self.connectToCenterServer(unit: unit)
                
            }.flatMap({ (response) -> Observable<Response> in
                let result = response.mapObject(BaseO2ResponseData<O2CenterServerModel>.self)
                if let centerServer = result?.data {
                    let unit = O2UserDefaults.shared.unit
                    let httpProtocol = unit?.httpProtocol ?? "http"
                    centerServer.assembles?.forEach({ (key,value) in
                        value.httpProtocol = httpProtocol
                        centerServer.assembles![key] = value
                    })
                    centerServer.webServer?.httpProtocol = httpProtocol
                    // 保存中心服务器数据
                    O2UserDefaults.shared.centerServer = centerServer
                    return self.checkCustomStyleNeedUpdate(unit: unit!)
                }else {
                    throw O2AuthError.blockError("无法连接中心服务器！")
                }
            }).flatMap { (response) -> Observable<Bool> in
                let o2Res = response.mapObject(BaseO2ResponseData<O2StringValueModel>.self)
                let currentHash = O2UserDefaults.shared.customStyleHash ?? ""
                if o2Res?.isSuccess() == false {
                    throw O2AuthError.blockError("检查移动端配置是否需要更新时出错， \(o2Res?.message ?? "")")
                }else {
                    if let newHash = o2Res?.data?.value {
                        if newHash == currentHash { // 没有更新不需要下载
                            return self.boolObservableCreate(true)
                        }else {
                            //保存这个hash码，并下载
                            O2UserDefaults.shared.customStyleHash = newHash
                            return self.downloadCustomStyle()
                        }
                    }else {
                        throw O2AuthError.blockError("检查移动端配置是否需要更新时出错， 没有获取到hash值")
                    }
                }
            }.flatMap { (result) -> Observable<Response> in
                if result {
                    if let token = O2UserDefaults.shared.myInfo?.token {
                        return self.loginWithToken(token)
                    }else {
                        guard let mobile = O2UserDefaults.shared.device?.mobile, let code = O2UserDefaults.shared.device?.code else {
                            throw O2AuthError.noLoginError
                        }
                        return self.loginWithPhoneCode(mobile, code)
                    }
                }else {
                    throw O2AuthError.blockError("下载移动端配置时出错！！！")
                }
            }.flatMap { (response) -> Observable<Bool> in
                let account = response.mapObject(BaseO2ResponseData<O2LoginAccountModel>.self)
                if account?.isSuccess() == true {
                    if let myInfo = account?.data, myInfo.name != "anonymous" {
                        O2UserDefaults.shared.myInfo = myInfo
                        return self.boolObservableCreate(true)
                    }else {
                        throw O2AuthError.noLoginError
                    }
                }else {
                    throw O2AuthError.noLoginError
                }
            }
            .subscribe { (event) in
                switch event {
                case .next(let element):
                    if element {
                        callback(O2LaunchProcessState.success, nil)
                    }else {
                        callback(O2LaunchProcessState.loginError, "登录失败！")
                    }
                    break
                case .error(let error):
                    if error is O2AuthError {
                        let aError = error as! O2AuthError
                        switch aError {
                        case .noLoginError:
                            callback(O2LaunchProcessState.loginError, "登录失败！")
                            break
                        case .noBindError:
                            callback(O2LaunchProcessState.bindError, "绑定失败！")
                            break
                        case .bindExpireError:
                            callback(O2LaunchProcessState.bindError, "绑定过期！")
                            break
                        case .blockError(let msg):
                            callback(O2LaunchProcessState.unknownError, msg)
                            break
                        }
                    }else {
                        callback(O2LaunchProcessState.unknownError, "未知错误，\(String(describing: error))")
                    }
                    break
                case .completed:
                    break
                }
        }
        
    }
    
    
    /// 内网版本启动入口
    ///
    /// - Parameters:
    ///   - unit: 内网服务器信息
    ///   - callback: O2LaunchProcessState
    public func launchInner(unit: O2BindUnitModel,  callback: @escaping (_ state: O2LaunchProcessState, _ msg: String?)->()) {
        // 保存数据 连接unit的中心服务器
        O2UserDefaults.shared.unit = unit
        _ = connectToCenterServer(unit: unit).flatMap { (response) -> Observable<Response> in
            let result = response.mapObject(BaseO2ResponseData<O2CenterServerModel>.self)
            if let centerServer = result?.data {
                let httpProtocol = unit.httpProtocol ?? "http"
                centerServer.assembles?.forEach({ (key,value) in
                    value.httpProtocol = httpProtocol
                    centerServer.assembles![key] = value
                })
                centerServer.webServer?.httpProtocol = httpProtocol
                // 保存中心服务器数据
                O2UserDefaults.shared.centerServer = centerServer
                return self.checkCustomStyleNeedUpdate(unit: unit)
            }else {
                throw O2AuthError.blockError("无法连接中心服务器！")
            }
        }
        .flatMap { (response) -> Observable<Bool> in
            let o2Res = response.mapObject(BaseO2ResponseData<O2StringValueModel>.self)
            let currentHash = O2UserDefaults.shared.customStyleHash ?? ""
            if o2Res?.isSuccess() == false {
                throw O2AuthError.blockError("检查移动端配置是否需要更新时出错， \(o2Res?.message ?? "")")
            }else {
                if let newHash = o2Res?.data?.value {
                    if newHash == currentHash { // 没有更新不需要下载
                        return self.boolObservableCreate(true)
                    }else {
                        //保存这个hash码，并下载
                        O2UserDefaults.shared.customStyleHash = newHash
                        return self.downloadCustomStyle()
                    }
                }else {
                    throw O2AuthError.blockError("检查移动端配置是否需要更新时出错， 没有获取到hash值")
                }
            }
        }.flatMap { (result) -> Observable<Response> in
                if result {
                    if let token = O2UserDefaults.shared.myInfo?.token {
                        return self.loginWithToken(token)
                    }else {
                        guard let mobile = O2UserDefaults.shared.device?.mobile, let code = O2UserDefaults.shared.device?.code else {
                            throw O2AuthError.noLoginError
                        }
                        return self.loginWithPhoneCode(mobile, code)
                    }
                }else {
                    throw O2AuthError.blockError("下载移动端配置时出错！！！")
                }
        }.flatMap { (response) -> Observable<Bool> in
                let account = response.mapObject(BaseO2ResponseData<O2LoginAccountModel>.self)
                if account?.isSuccess() == true {
                    if let myInfo = account?.data, myInfo.name != "anonymous" {
                        O2UserDefaults.shared.myInfo = myInfo
                        return self.boolObservableCreate(true)
                    }else {
                        throw O2AuthError.noLoginError
                    }
                }else {
                    throw O2AuthError.noLoginError
                }
        }.subscribe { (event) in
                switch event {
                case .next(let element):
                    if element {
                        callback(O2LaunchProcessState.success, nil)
                    }else {
                        callback(O2LaunchProcessState.loginError, "登录失败！")
                    }
                    break
                case .error(let error):
                    if error is O2AuthError {
                        let aError = error as! O2AuthError
                        switch aError {
                        case .noLoginError:
                            callback(O2LaunchProcessState.loginError, "登录失败！")
                            break
                        case .blockError(let msg):
                            callback(O2LaunchProcessState.unknownError, msg)
                            break
                        default :
                            callback(O2LaunchProcessState.unknownError, "")
                            break
                        }
                    }else {
                        callback(O2LaunchProcessState.unknownError, "未知错误，\(String(describing: error))")
                    }
                    break
                case .completed:
                    break
                }
        }
    }
    
    
    /// 登录 手机号码 验证码
    ///
    /// - Parameters:
    ///   - mobile: 手机号码
    ///   - code: 验证码
    ///   - callback: 登录结果
    public func login(mobile: String, code: String, callback: @escaping (_ result: Bool, _ error: String?) ->() ) {
        _ = self.loginWithPhoneCode(mobile, code)
            .subscribe(onNext: { (response) in
            let account = response.mapObject(BaseO2ResponseData<O2LoginAccountModel>.self)
            if account?.isSuccess() == true {
                if let myInfo = account?.data, myInfo.name != "anonymous" {
                    O2UserDefaults.shared.myInfo = myInfo
                    callback(true, nil)
                }else {
                    callback(false, "登录失败，用户名是： 找不到该用户信息 ！ ")
                }
            }else {
                callback(false, "登录失败，\(account?.message ?? "")")
            }
        }, onError: { (error) in
            callback(false, "登录失败，\(String(describing: error))")
        }, onCompleted: {
            DDLogDebug("login completed!")
        }) {
            DDLogDebug("login finish!")
        }
    }
    
    /// 登录 扫码登录
    public func loginWithScanCode(meta: String, callback: @escaping (_ result: Bool, _ error: String?) ->()) {
        _ = self.loginAPI.rx.request(.loginWithScanCode(meta)).asObservable().subscribe(onNext: { (response) in
            let back = response.mapObject(BaseO2ResponseData<O2NodeResModel>.self)
            if back?.isSuccess() == true {
                if let v = back?.data, v.value == true {
                    callback(true, nil)
                }else {
                    callback(false, "登录失败!")
                }
            }else {
                callback(false, "登录失败，\(back?.message ?? "")")
            }
        }, onError: { (error) in
            callback(false, "登录失败，\(String(describing: error))")
        }, onCompleted: {
            DDLogDebug("loginWithScanCode completed!")
        }) {
            DDLogDebug("loginWithScanCode finish!")
        }
    }
    
    /// 登录 密码登录
    @available(*, deprecated, message: "新版后台已经取消了这个方法, 请使用loginWithCaptcha方法登录")
    public func loginWithPassword(username: String, password: String, callback: @escaping (_ result: Bool, _ error: String?) ->()) {
        _ = self.loginWithUsernamePassword(username, password)
            .subscribe(onNext: { (response) in
                let account = response.mapObject(BaseO2ResponseData<O2LoginAccountModel>.self)
                if account?.isSuccess() == true {
                    if let myInfo = account?.data, myInfo.name != "anonymous" {
                        O2UserDefaults.shared.myInfo = myInfo
                        callback(true, nil)
                    }else {
                        callback(false, "登录失败，用户名是： 找不到该用户信息 ！ ")
                    }
                }else {
                    callback(false, "登录失败，\(account?.message ?? "")")
                }
            }, onError: { (error) in
                callback(false, "登录失败，\(String(describing: error))")
            }, onCompleted: {
                DDLogDebug("login completed!")
            }) {
                DDLogDebug("login finish!")
        }
    }
    
    /// 登录 密码登录
    public func loginWithCaptcha(form: O2LoginWithCaptchaForm, callback: @escaping (_ result: Bool, _ error: String?) ->()) {
        _ = loginAPI.rx.request(.loginWithCaptcha(form)).asObservable()
            .subscribe(onNext: { (response) in
                let account = response.mapObject(BaseO2ResponseData<O2LoginAccountModel>.self)
                if account?.isSuccess() == true {
                    if let myInfo = account?.data, myInfo.name != "anonymous" {
                        O2UserDefaults.shared.myInfo = myInfo
                        callback(true, nil)
                    }else {
                        callback(false, "登录失败，用户名是： 找不到该用户信息 ！ ")
                    }
                }else {
                    callback(false, "登录失败，\(account?.message ?? "")")
                }
            }, onError: { (error) in
                callback(false, "登录失败，\(String(describing: error))")
            }, onCompleted: {
                DDLogDebug("loginWithCaptcha completed!")
            }) {
                DDLogDebug("loginWithCaptcha finish!")
        }
    }
    
    ///
    /// 登录模式
    /// 密码登录 短信登录
    ///
    public func loginMode(callback: @escaping (_ result: O2LoginMode?, _ error: String?) ->()) {
       _ = loginAPI.rx.request(.loginMode).asObservable()
            .subscribe { (response) in
                let mode = response.mapObject(BaseO2ResponseData<O2LoginMode>.self)
                if mode?.isSuccess() == true, let m = mode?.data {
                    callback(m, nil)
                } else {
                    callback(nil, "获取登录模式失败，返回结果为空！")
                }
            } onError: { (error) in
                callback(nil, "获取登录模式失败，\(String(describing: error))")
            } onCompleted: {
                DDLogDebug("loginMode completed!")
            } onDisposed: {
                DDLogDebug("loginMode finish!")
            }
    }
    
    ///
    /// 图片验证码获取
    ///
    public func getLoginCaptchaCode(callback: @escaping (_ result: O2LoginCaptchaImgData?, _ error: String?) ->()) {
        _ = loginAPI.rx.request(.getCaptchaCodeImg(120, 50)).asObservable()
            .subscribe { (response) in
                let mode = response.mapObject(BaseO2ResponseData<O2LoginCaptchaImgData>.self)
                if mode?.isSuccess() == true, let m = mode?.data {
                    callback(m, nil)
                } else {
                    callback(nil, "获取图片验证码失败，返回结果为空！")
                }
            } onError: { (error) in
                callback(nil, "获取图片验证码失败，\(String(describing: error))")
            } onCompleted: {
                DDLogDebug("getLoginCaptchaCode completed!")
            } onDisposed: {
                DDLogDebug("getLoginCaptchaCode finish!")
            }
    }
    
    /// 人脸识别登录
    ///
    /// - Parameters:
    ///   - userId: 用户uid
    ///   - callback:
    public func faceRecognizeLogin(userId: String, callback: @escaping (_ result: Bool, _ error: String?) ->()) {
        _ = self.desEncrypt(userId).flatMap { (token) -> Observable<Response> in
            return self.loginWithSSO(token)
            }.subscribe(onNext: { (response) in
                let account = response.mapObject(BaseO2ResponseData<O2LoginAccountModel>.self)
                if account?.isSuccess() == true {
                    if let myInfo = account?.data, myInfo.name != "anonymous" {
                        O2UserDefaults.shared.myInfo = myInfo
                        callback(true, nil)
                    }else {
                        callback(false, "登录失败，找不到该用户信息 ！ ")
                    }
                }else {
                    callback(false, "登录失败，\(account?.message ?? "")")
                }
            }, onError: { (error) in
                callback(false, "登录失败，\(String(describing: error))")
            }, onCompleted: nil, onDisposed: nil)
    }
    
    /// 登出 清除当前登录的用户信息
    ///
    /// - Parameter callback:
    public func logout(callback: @escaping (_ result: Bool, _ error: String?) ->()) {
        _ = Observable<Bool>.create { (observer) -> Disposable in
            O2UserDefaults.shared.myInfo = nil
            let device = O2UserDefaults.shared.device
            device?.code = nil
            O2UserDefaults.shared.device = device
            observer.onNext(true)
            observer.onCompleted()
            return Disposables.create()
        }.subscribe(onNext: { (result) in
            callback(result, nil)
        }, onError: { (error) in
            callback(false, "\(String(describing: error))")
        }, onCompleted: nil, onDisposed: nil)
    }
    
    /// 解除绑定前 清空本地数据
    ///
    /// - Parameter callback: 返回结果
    public func clearAllInformationBeforeReBind(callback: @escaping (_ result: Bool, _ error: String?) ->()) {
        _ = Observable<Bool>.create { (observer) -> Disposable in
            //清除本地关于账号 单位等信息
            O2UserDefaults.shared.unit = nil
            O2UserDefaults.shared.device = nil
            O2UserDefaults.shared.myInfo = nil
            O2UserDefaults.shared.customStyle = nil
            O2UserDefaults.shared.customStyleHash = nil
            O2UserDefaults.shared.centerServer = nil
            observer.onNext(true)
            observer.onCompleted()
            return Disposables.create()
        }.subscribe(onNext: { (result) in
                callback(result, nil)
        }, onError: { (error) in
                callback(false, "\(String(describing: error))")
        }, onCompleted: nil, onDisposed: nil)
        
    }
    
    /// 登录的时候 发送短信验证码
    ///
    /// - Parameters:
    ///   - mobile: 手机号码
    ///   - callback:
    public func sendLoginSMS(mobile: String, callback: @escaping (_ result: Bool, _ error: String?) ->()) {
        _ = loginAPI.rx.request(.createLoginCode(mobile)).asObservable()
            .subscribe(onNext: { (response) in
                let account = response.mapObject(BaseO2ResponseData<O2NodeResModel>.self)
                if let result = account?.data?.value, result == true {
                    callback(true, nil)
                }else {
                    callback(false, "发送短信失败！")
                }
            }, onError: { (error) in
                callback(false, "发送短信失败！\(error)")
            }, onCompleted: nil, onDisposed: nil)
    }
    
    
    /// 绑定手机的时候 发送短信验证码
    ///
    /// - Parameters:
    ///   - mobile: 手机号码
    ///   - callback:
    public func sendBindSMS(mobile: String, callback: @escaping (_ result: Bool, _ error: String?) ->()) {
        let req = O2NodeReqModel()
        req.mobile = mobile
        _ = registerAPI.rx.request(.generateVerifiyCode(req)).asObservable()
            .subscribe(onNext: { (response) in
                let account = response.mapObject(BaseO2ResponseData<O2MobileCodeResModel>.self)
                if account?.isSuccess() == true {
                    callback(true, nil)
                }else {
                    callback(false, "发送短信失败！")
                }
            }, onError: { (error) in
                callback(false, "发送短信失败！\(error)")
            }, onCompleted: nil, onDisposed: nil)
    }
    
    /// 绑定到sample 服务器，苹果上架使用
    
    /// - Parameters:
    ///   - mobile: 手机号码
    public func bindSampleServer(mobile: String, callback: @escaping (_ result: O2BindProcessState, _ error: String?) ->()) {
        //填入sample的服务器信息
        let _ = Observable<O2BindUnitModel>.create { (observer) -> Disposable in
            let unit: O2BindUnitModel = O2BindUnitModel()
            unit.id = "61a4d035-81ee-44a6-af3b-ab3d374ee24d"
            unit.name = "演示站点"
            unit.pinyin = "yanshizhandian"
            unit.pinyinInitial = "yszd"
            unit.centerHost = "sample.o2oa.net"
            unit.centerPort = 443
            unit.centerContext = "/x_program_center"
            unit.httpProtocol = "https"
            O2UserDefaults.shared.unit = unit
            observer.onNext(unit)
            observer.onCompleted()
            return Disposables.create()
        }.flatMap { (unit) -> Observable<Response> in
            let bindDevice: O2BindDeviceModel = O2BindDeviceModel()
            bindDevice.unit = unit.name
            bindDevice.name = O2UserDefaults.shared.deviceToken
            bindDevice.mobile = mobile
            bindDevice.code = ""
            bindDevice.deviceType = "ios"
            O2UserDefaults.shared.device = bindDevice
            return self.connectToCenterServer(unit: unit)
        }.flatMap({ (response) -> Observable<Response> in
            let result = response.mapObject(BaseO2ResponseData<O2CenterServerModel>.self)
            if let centerServer = result?.data {
                let unit = O2UserDefaults.shared.unit
                let httpProtocol = unit?.httpProtocol ?? "http"
                centerServer.assembles?.forEach({ (key,value) in
                    value.httpProtocol = httpProtocol
                    centerServer.assembles![key] = value
                })
                centerServer.webServer?.httpProtocol = httpProtocol
                // 保存中心服务器数据
                O2UserDefaults.shared.centerServer = centerServer
                return self.checkCustomStyleNeedUpdate(unit: unit!)
            }else {
                O2UserDefaults.shared.unit = nil
                O2UserDefaults.shared.device = nil
                throw O2BindDiscontinue.unknownError("无法连接中心服务器！")
            }
        }).flatMap { (response) -> Observable<Bool> in
            let o2Res = response.mapObject(BaseO2ResponseData<O2StringValueModel>.self)
            let currentHash = O2UserDefaults.shared.customStyleHash ?? ""
            if o2Res?.isSuccess() == false {
                throw O2BindDiscontinue.noLoginError("检查移动端配置是否需要更新时出错， \(o2Res?.message ?? "")")
            }else {
                if let newHash = o2Res?.data?.value {
                    if newHash == currentHash { // 没有更新不需要下载
                        return self.boolObservableCreate(true)
                    }else {
                        //保存这个hash码，并下载
                        O2UserDefaults.shared.customStyleHash = newHash
                        return self.downloadCustomStyle()
                    }
                }else {
                    throw O2BindDiscontinue.noLoginError("检查移动端配置是否需要更新时出错， 没有获取到hash值")
                }
            }
        }.flatMap { (result) -> Observable<Response> in
            if result {
                //sample的默认密码
                guard let mobile = O2UserDefaults.shared.device?.mobile else {
                    throw O2BindDiscontinue.noLoginError("登录失败！")
                }
                let form = O2LoginWithCaptchaForm()
                form.credential = mobile
                form.password = "345678"
                return self.loginAPI.rx.request(.loginWithCaptcha(form)).asObservable()
//                return self.loginWithUsernamePassword(mobile, "o2")
//                if let token = O2UserDefaults.shared.myInfo?.token {
//                    return self.loginWithToken(token)
//                }else {
//                    guard let mobile = O2UserDefaults.shared.device?.mobile, let code = O2UserDefaults.shared.device?.code else {
//                        throw O2BindDiscontinue.noLoginError("登录失败！")
//                    }
//                    return self.loginWithPhoneCode(mobile, code)
//                }
            }else {
                throw O2BindDiscontinue.noLoginError("下载移动端配置时出错！！！")
            }
        }.flatMap { (response) -> Observable<Bool> in
            let account = response.mapObject(BaseO2ResponseData<O2LoginAccountModel>.self)
            if account?.isSuccess() == true {
                if let myInfo = account?.data, myInfo.name != "anonymous" {
                    O2UserDefaults.shared.myInfo = myInfo
                    return self.boolObservableCreate(true)
                }else {
                    throw O2BindDiscontinue.noLoginError("登录失败！")
                }
            }else {
                throw O2BindDiscontinue.noLoginError("登录失败！")
            }
        }.subscribe(onNext: { (result) in
            if result {
                callback(O2BindProcessState.success, nil)
            }else {
                callback(O2BindProcessState.goToLogin, "登录失败！")
            }
        }, onError: { (error) in
            if error is O2BindDiscontinue {
                let bError = error as! O2BindDiscontinue
                switch bError {
                case O2BindDiscontinue.tooManyUnit(let list):
                    callback(O2BindProcessState.goToChooseBindServer(list), nil)
                    break
                case O2BindDiscontinue.noLoginError(let msg):
                    callback(O2BindProcessState.goToLogin, msg)
                    break
                case O2BindDiscontinue.noUnitCanBindError:
                    callback(O2BindProcessState.noUnitCanBindError, nil)
                    break
                case O2BindDiscontinue.unknownError(let msg):
                    callback(O2BindProcessState.unknownError, msg)
                    break
                }
            }else {
                callback(O2BindProcessState.unknownError, "\(error)")
            }
        }, onCompleted: nil, onDisposed: nil)
    }
    
    /// 绑定手机号码到服务器, 并且完成全部的登录过程。
    /// 第一步绑定的时候用的，如果单位列表大于1个就抛异常， 外面接收到这个特殊异常就走第二步选择单位
    ///
    /// - Parameters:
    ///   - mobile: 手机号码
    ///   - code: 验证码
    ///   - callback:
    public func bindMobileToSever(mobile: String, code: String, callback: @escaping (_ result: O2BindProcessState, _ error: String?) ->()) {
        let bindDevice: O2BindDeviceModel = O2BindDeviceModel()
        let req = O2NodeReqModel()
        req.mobile = mobile
        req.value = code
        _ = registerAPI.rx.request(.verifiyCode(req)).asObservable()
            .flatMap { (response) -> Observable<Response> in
                let listResult = response.mapObject(BaseO2ResponseData<[O2BindUnitModel]>.self)
                if let list = listResult?.data, list.count > 0 {
                    if list.count > 1 {
                        throw O2BindDiscontinue.tooManyUnit(list)
                    }else {
                        // 保存单位信息
                        O2UserDefaults.shared.unit = list[0]
                        bindDevice.unit = list[0].name
                        bindDevice.name = O2UserDefaults.shared.deviceToken
                        bindDevice.mobile = mobile
                        bindDevice.code = code
                        return self.bindToCollect(device: bindDevice)
                    }
                }else {
                    throw O2BindDiscontinue.noUnitCanBindError
                }
            }
            .flatMap { (response) -> Observable<Response> in
                let idData = response.mapObject(BaseO2ResponseData<O2IdDataModel>.self)
                if idData?.isSuccess() == true {
                    // 保存device
                    O2UserDefaults.shared.device = bindDevice
                    let unit = O2UserDefaults.shared.unit
                    return self.connectToCenterServer(unit: unit!)
                }else {
                    O2UserDefaults.shared.unit = nil
                    throw O2BindDiscontinue.unknownError("绑定失败！")
                }
            }.flatMap({ (response) -> Observable<Response> in
                let result = response.mapObject(BaseO2ResponseData<O2CenterServerModel>.self)
                if let centerServer = result?.data {
                    let unit = O2UserDefaults.shared.unit
                    let httpProtocol = unit?.httpProtocol ?? "http"
                    centerServer.assembles?.forEach({ (key,value) in
                        value.httpProtocol = httpProtocol
                        centerServer.assembles![key] = value
                    })
                    centerServer.webServer?.httpProtocol = httpProtocol
                    // 保存中心服务器数据
                    O2UserDefaults.shared.centerServer = centerServer
                    return self.checkCustomStyleNeedUpdate(unit: unit!)
                }else {
                    O2UserDefaults.shared.unit = nil
                    O2UserDefaults.shared.device = nil
                    throw O2BindDiscontinue.unknownError("无法连接中心服务器！")
                }
            }).flatMap { (response) -> Observable<Bool> in
                let o2Res = response.mapObject(BaseO2ResponseData<O2StringValueModel>.self)
                let currentHash = O2UserDefaults.shared.customStyleHash ?? ""
                if o2Res?.isSuccess() == false {
                    throw O2BindDiscontinue.noLoginError("检查移动端配置是否需要更新时出错， \(o2Res?.message ?? "")")
                }else {
                    if let newHash = o2Res?.data?.value {
                        if newHash == currentHash { // 没有更新不需要下载
                            return self.boolObservableCreate(true)
                        }else {
                            //保存这个hash码，并下载
                            O2UserDefaults.shared.customStyleHash = newHash
                            return self.downloadCustomStyle()
                        }
                    }else {
                        throw O2BindDiscontinue.noLoginError("检查移动端配置是否需要更新时出错， 没有获取到hash值")
                    }
                }
            }.flatMap { (result) -> Observable<Response> in
                if result {
                    if let token = O2UserDefaults.shared.myInfo?.token {
                        return self.loginWithToken(token)
                    }else {
                        guard let mobile = O2UserDefaults.shared.device?.mobile, let code = O2UserDefaults.shared.device?.code else {
                            throw O2BindDiscontinue.noLoginError("登录失败！")
                        }
                        return self.loginWithPhoneCode(mobile, code)
                    }
                }else {
                    throw O2BindDiscontinue.noLoginError("下载移动端配置时出错！！！")
                }
            }.flatMap { (response) -> Observable<Bool> in
                let account = response.mapObject(BaseO2ResponseData<O2LoginAccountModel>.self)
                if account?.isSuccess() == true {
                    if let myInfo = account?.data, myInfo.name != "anonymous" {
                        O2UserDefaults.shared.myInfo = myInfo
                        return self.boolObservableCreate(true)
                    }else {
                        throw O2BindDiscontinue.noLoginError("登录失败！")
                    }
                }else {
                    throw O2BindDiscontinue.noLoginError("登录失败！")
                }
            }.subscribe(onNext: { (result) in
                if result {
                    callback(O2BindProcessState.success, nil)
                }else {
                    callback(O2BindProcessState.goToLogin, "登录失败！")
                }
            }, onError: { (error) in
                if error is O2BindDiscontinue {
                    let bError = error as! O2BindDiscontinue
                    switch bError {
                    case O2BindDiscontinue.tooManyUnit(let list):
                        callback(O2BindProcessState.goToChooseBindServer(list), nil)
                        break
                    case O2BindDiscontinue.noLoginError(let msg):
                        callback(O2BindProcessState.goToLogin, msg)
                        break
                    case O2BindDiscontinue.noUnitCanBindError:
                        callback(O2BindProcessState.noUnitCanBindError, nil)
                        break
                    case O2BindDiscontinue.unknownError(let msg):
                        callback(O2BindProcessState.unknownError, msg)
                        break
                    }
                }else {
                    callback(O2BindProcessState.unknownError, "\(error)")
                }
            }, onCompleted: nil, onDisposed: nil)
    }
    
    /// 绑定手机到服务器，并完成全部的登录过程
    ///
    /// - Parameters:
    ///   - unit: 绑定的单位服务器对象
    ///   - mobile: 手机号码
    ///   - code: 验证码
    ///   - callback:
    public func bindMobileToServer(unit: O2BindUnitModel, mobile: String, code: String, callback: @escaping (_ result: O2BindProcessState, _ error: String?) ->()) {
        // 保存单位信息
        O2UserDefaults.shared.unit = unit
        let bindDevice: O2BindDeviceModel = O2BindDeviceModel()
        bindDevice.unit = unit.name
        bindDevice.name = O2UserDefaults.shared.deviceToken
        bindDevice.mobile = mobile
        bindDevice.code = code
        bindDevice.deviceType = "ios"
        _ = self.bindToCollect(device: bindDevice)
            .flatMap { (response) -> Observable<Response> in
                let idData = response.mapObject(BaseO2ResponseData<O2IdDataModel>.self)
                if idData?.isSuccess() == true {
                    // 保存device
                    O2UserDefaults.shared.device = bindDevice
                    let unit = O2UserDefaults.shared.unit
                    return self.connectToCenterServer(unit: unit!)
                }else {
                    O2UserDefaults.shared.unit = nil
                    throw O2BindDiscontinue.unknownError("绑定失败！")
                }
            }.flatMap({ (response) -> Observable<Response> in
                let result = response.mapObject(BaseO2ResponseData<O2CenterServerModel>.self)
                if let centerServer = result?.data {
                    let unit = O2UserDefaults.shared.unit
                    let httpProtocol = unit?.httpProtocol ?? "http"
                    centerServer.assembles?.forEach({ (key,value) in
                        value.httpProtocol = httpProtocol
                        centerServer.assembles![key] = value
                    })
                    centerServer.webServer?.httpProtocol = httpProtocol
                    // 保存中心服务器数据
                    O2UserDefaults.shared.centerServer = centerServer
                    return self.checkCustomStyleNeedUpdate(unit: unit!)
                }else {
                    O2UserDefaults.shared.unit = nil
                    O2UserDefaults.shared.device = nil
                    throw O2BindDiscontinue.unknownError("无法连接中心服务器！")
                }
            }).flatMap { (response) -> Observable<Bool> in
                let o2Res = response.mapObject(BaseO2ResponseData<O2StringValueModel>.self)
                let currentHash = O2UserDefaults.shared.customStyleHash ?? ""
                if o2Res?.isSuccess() == false {
                    throw O2BindDiscontinue.noLoginError("检查移动端配置是否需要更新时出错， \(o2Res?.message ?? "")")
                }else {
                    if let newHash = o2Res?.data?.value {
                        if newHash == currentHash { // 没有更新不需要下载
                            return self.boolObservableCreate(true)
                        }else {
                            //保存这个hash码，并下载
                            O2UserDefaults.shared.customStyleHash = newHash
                            return self.downloadCustomStyle()
                        }
                    }else {
                        throw O2BindDiscontinue.noLoginError("检查移动端配置是否需要更新时出错， 没有获取到hash值")
                    }
                }
            }.flatMap { (result) -> Observable<Response> in
                if result {
                    if let token = O2UserDefaults.shared.myInfo?.token {
                        return self.loginWithToken(token)
                    }else {
                        guard let mobile = O2UserDefaults.shared.device?.mobile, let code = O2UserDefaults.shared.device?.code else {
                            throw O2BindDiscontinue.noLoginError("登录失败！")
                        }
                        return self.loginWithPhoneCode(mobile, code)
                    }
                }else {
                    throw O2BindDiscontinue.noLoginError("下载移动端配置时出错！！！")
                }
            }.flatMap { (response) -> Observable<Bool> in
                let account = response.mapObject(BaseO2ResponseData<O2LoginAccountModel>.self)
                if account?.isSuccess() == true {
                    if let myInfo = account?.data, myInfo.name != "anonymous" {
                        O2UserDefaults.shared.myInfo = myInfo
                        return self.boolObservableCreate(true)
                    }else {
                        throw O2BindDiscontinue.noLoginError("登录失败！")
                    }
                }else {
                    throw O2BindDiscontinue.noLoginError("登录失败！")
                }
            }.subscribe(onNext: { (result) in
                if result {
                    callback(O2BindProcessState.success, nil)
                }else {
                    callback(O2BindProcessState.goToLogin, "登录失败！")
                }
            }, onError: { (error) in
                if error is O2BindDiscontinue {
                    let bError = error as! O2BindDiscontinue
                    switch bError {
                    case O2BindDiscontinue.tooManyUnit(let list):
                        callback(O2BindProcessState.goToChooseBindServer(list), nil)
                        break
                    case O2BindDiscontinue.noLoginError(let msg):
                        callback(O2BindProcessState.goToLogin, msg)
                        break
                    case O2BindDiscontinue.noUnitCanBindError:
                        callback(O2BindProcessState.noUnitCanBindError, nil)
                        break
                    case O2BindDiscontinue.unknownError(let msg):
                        callback(O2BindProcessState.unknownError, msg)
                        break
                    }
                }else {
                    callback(O2BindProcessState.unknownError, "\(error)")
                }
            }, onCompleted: nil, onDisposed: nil)
    }
    
    /// 绑定的设备列表
    ///
    /// - Parameters:
    ///   - unitId: 绑定的单位id
    ///   - mobile: 手机号码
    ///   - token: 设备号  O2BindDeviceModel.name
    ///   - callback:
    public func bindDeviceList(unitId: String, mobile: String, token: String, callback: @escaping (_ list: [O2BindDeviceModel], _ error: String?)->Void) {
        _ = registerAPI.rx.request(.deviceList(unitId, mobile, token)).asObservable()
            .subscribe(onNext: { (response) in
                let result = response.mapObject(BaseO2ResponseData<[O2BindDeviceModel]>.self)
                if result?.isSuccess() == true {
                    callback(result?.data ?? [], nil)
                }else {
                    let message = "查询设备失败，\(result?.message ?? "")"
                    callback([], message)
                }
            }, onError: { (error) in
                let message = "查询设备异常，\(error.localizedDescription)"
                callback([], message)
            }, onCompleted: nil, onDisposed: nil)
    }
    
    /// 解除设备绑定
    ///
    /// - Parameters:
    ///   - device: 设备对象 主要是name 就是设备号
    ///   - callback:
    public func unBindFromCollect(deviceId: String, callback: @escaping (_ result:Bool, _ error:String?)->Void)   {
        let device: O2BindDeviceModel = O2BindDeviceModel()
        device.name = deviceId
        _ = registerAPI.rx.request(.unBindFromDevice(device)).asObservable()
            .subscribe(onNext: { (response) in
                let result = response.mapObject(BaseO2ResponseData<O2IdDataModel>.self)
                if result?.isSuccess() == true {
                    callback(true, nil)
                }else {
                    let message = "解除绑定失败，\(result?.message ?? "")"
                    callback(false, message)
                }
            }, onError: { (error) in
                let message = "解除绑定异常，\(error.localizedDescription)"
                callback(false, message)
            }, onCompleted: nil, onDisposed: nil)
    }
    
    ///
    /// 文件下载地址
    ///  - fileId 文件id
    public func getFileDownloadUrl(fileId: String)-> String {
        //http://dev.o2oa.net:20020/x_file_assemble_control/jaxrs/file/b871a896-93f7-4245-8e5a-100fd4a67d9d/download/stream
        let model = O2AuthSDK.shared.o2APIServer(context: .x_file_assemble_control)
        var baseURLString = "\(model?.httpProtocol ?? "http")://\(model?.host ?? ""):\(model?.port ?? 80)\(model?.context ?? "")"
        if let trueUrl = O2AuthSDK.shared.bindUnitTransferUrl2Mapping(url: baseURLString) {
            baseURLString = trueUrl
        }
        return  "\(baseURLString)/jaxrs/file/\(fileId)/download/stream"
    }
    
    
    
    //MARK: - private
    
    private func boolObservableCreate(_ result: Bool) -> Observable<Bool> {
        return Observable<Bool>.create({ (observer) -> Disposable in
                observer.on(.next(result))
                observer.on(.completed)
                return Disposables.create()
            })
    }
    
    /// 检查是否绑定过
    ///
    /// - Returns: 
    private func checkBindUnit() -> Observable<O2BindUnitModel> {
//        return Observable<O2BindDeviceModel>.create({ (any) -> Disposable in
//            if let device = O2UserDefaults.shared.device {
//                any.onNext(device)
//                any.onCompleted()
//            }else {
//                any.onError(O2AuthError.noBindError)
//            }
//            return Disposables.create()
//        })
        
        return Observable<O2BindUnitModel>.create ({ (any) -> Disposable in
            if let unit = O2UserDefaults.shared.unit {
                any.onNext(unit)
                any.onCompleted()
            } else {
                any.onError(O2AuthError.noBindError)
            }
            return Disposables.create()
        })
    }
    /// 检查当前绑定信息是否过期
    ///
    /// - Parameter device: 手机号码等设备信息
    /// - Returns:
    private func checkBindUnitIsExpired(device: O2BindDeviceModel) -> Observable<Response> {
        return registerAPI.rx.request(.queryBindInfo(device)).asObservable()
    }
    
    
    /// 连接到O2OA中心服务器
    ///
    /// - Parameter unit: 单位服务器信息
    /// - Returns:
    private func connectToCenterServer(unit: O2BindUnitModel) -> Observable<Response> {
        return registerAPI.rx.request(.downloadNodeAPI(unit)).asObservable()
    }
    
    /// 检查移动端配置信息是否有更新
    ///
    /// - Parameter unit: 当前绑定的党委
    /// - Returns:
    private func checkCustomStyleNeedUpdate(unit: O2BindUnitModel) -> Observable<Response> {
        return registerAPI.rx.request(.verConfigInfo(unit)).asObservable()
    }
    
    /// 下载移动端配置信息
    ///
    /// - Returns:
    private func downloadCustomStyle() -> Observable<Bool>  {
        if let unit = O2UserDefaults.shared.unit {
            return registerAPI.rx.request(.downloadConfigInfo(unit))
                .asObservable()
                .flatMap { (response) -> Observable<Bool> in
                    
                let result = response.mapObject(BaseO2ResponseData<O2CustomStyleModel>.self)
                if result?.isSuccess() == true {
                    //保存移动端配置信息
                    O2UserDefaults.shared.customStyle = result?.data
                    return self.boolObservableCreate(true)
                }else {
                    throw O2AuthError.blockError("下载移动端配置时出错， \(result?.message ?? "")")
                }
            }
        }else {
            return self.boolObservableCreate(false)
        }
    }
    
    /// token登录
    ///
    /// - Parameter token: 用户登录的token
    /// - Returns:
    private func loginWithToken(_ token: String) -> Observable<Response> {
        return loginAPI.rx.request(.loginWithToken(token)).asObservable()
    }
    
    /// 手机验证码登录
    ///
    /// - Parameters:
    ///   - mobile: 手机号码
    ///   - code: 验证码
    /// - Returns:
    private func loginWithPhoneCode(_ mobile: String, _ code: String) -> Observable<Response> {
        return loginAPI.rx.request(.loginWithCredntial(mobile, code)).asObservable()
    }
    
    
    /// 用户名密码登录
    ///
    /// - Parameters:
    ///   - username: 用户名
    ///   - password: 密码
    /// - Returns:
    private func loginWithUsernamePassword(_ username: String, _ password: String) -> Observable<Response> {
        return loginAPI.rx.request(.loginWithPassword(username, password)).asObservable()
    }
    
    /// sso 登录
    ///
    /// - Parameter token: 加密后的token
    /// - Returns:
    private func loginWithSSO(_ token: String) -> Observable<Response> {
        return loginAPI.rx.request(.loginWithSSO(O2ConfigInfo.O2_OA_SSO_CLIENT, token)).asObservable()
    }
    
    /// 绑定到wcollect服务器
    ///
    /// - Parameters:
    ///   - device: 设备对象
    /// - Returns:
    private func bindToCollect(device: O2BindDeviceModel) -> Observable<Response> {
        return registerAPI.rx.request(.bindMobileToDevice(device)).asObservable()
    }
    
  
    
    /// des 加密
    ///
    /// - Parameter uid:
    /// - Returns:
    private func desEncrypt(_ uid: String) -> Observable<String> {
        return Observable<String>.create({ (observer) -> Disposable in
            let timeInterval = Date().timeIntervalSince1970
            let time = CLongLong(round(timeInterval*1000))
            let code = "\(uid)#\(time)"
            print("code: \(code)")
            let token = code.o2DESEncode() ?? ""
            observer.onNext(token)
            observer.onCompleted()
            return Disposables.create()
        })
    }
    
}
