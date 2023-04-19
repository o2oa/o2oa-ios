//
//  O2MainController.swift
//  O2Platform
//
//  Created by FancyLou on 2019/1/25.
//  Copyright © 2019 zoneland. All rights reserved.
//

import UIKit
import CocoaLumberjack
import Starscream
import AudioToolbox

class O2MainController: O2BaseForRotateUITabBarController, UITabBarControllerDelegate {

    static var tabBarVC: O2MainController!

    static func genernateVC() -> O2MainController {
        return O2MainController()
    }

    private var isSimple = false
    private var currentIndex: Int = 0
    // demo服务器弹出公告
    private var demoAlertView = O2DemoAlertView()
    private let viewModel: OOLoginViewModel = {
        return OOLoginViewModel()
    }()
    private lazy var mainViewModel: O2MainViewModel = {
        return O2MainViewModel()
    }()
    //获取消息数量
    private lazy var imViewModel: IMViewModel = {
        return IMViewModel()
    }()
    //考勤判断版本
    private lazy var attendanceViewModel: OOAttandanceViewModel = {
        return OOAttandanceViewModel()
    }()
    // 云盘
    private lazy var cFileVM: CloudFileViewModel = {
        return CloudFileViewModel()
    }()
    // 论坛
    private lazy var bbsVm: BBSViewModel = {
        return BBSViewModel()
    }()
    
    private let barIm = L10n.mainBarIm
    private let barContact = L10n.mainBarContacts
    private let barApps = L10n.mainBarApps
    private let barSettings = L10n.mainBarSettings


    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.deviceModelReadable() != "Simulator" {
            self.checkAppVersion()
        }
        //查询通讯录权限
        self.mainViewModel.loadOrgContactPermission()
        
        self.tabBar.tintColor = O2ThemeManager.color(for: "Base.base_color")!
        self.delegate = self
        // 配置是否简易模式
        if let mode = O2AuthSDK.shared.customStyle()?.simpleMode, mode == true {
            DDLogDebug("进入简易模式！！！！！！！")
            isSimple = true
        }
        if isSimple {
            _initSimpleControllers()
            selectedIndex = 0
            currentIndex = 0
        }else {
            _initControllers()
            selectedIndex = 2
            currentIndex = 2
        }
        O2JPushManager.shared.o2JPushBind()
//        if O2IsConnect2Collect == false {
//            //处理内部直连的时候推送的设备绑定
//            
//        }
        //连接websocket
        self._startWebsocket()
        //读取消息
        self.getConversationList()
        //检查考勤版本
        self.checkAttendanceVersion()
        //检查云盘版本
        self.checkCloudFileVersion()
        // 论坛禁言问题
        self.checkBBSMuteInfo()
    }

    deinit {
        //关闭websocket
        self._stopWebsocket()
    }

    override func viewDidAppear(_ animated: Bool) {
        // 判断是否 第一次安装 是否是连接的demo服务器
        if let unit = O2AuthSDK.shared.bindUnit() {
            if "demo.o2oa.net" == unit.centerHost || "demo.o2oa.io" == unit.centerHost || "demo.o2server.io" == unit.centerHost || "sample.o2oa.net" == unit.centerHost {
                let tag = AppConfigSettings.shared.demoAlertTag
                if !tag {
                    demoAlertView.showFallDown()
                    AppConfigSettings.shared.demoAlertTag = true
                }
            }
        }
    }

    //MARK: -- delegate
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        self.currentIndex = tabBarController.selectedIndex
    }

    /// 普通模式
    private func _initControllers() {
        //消息
        let conversationVC = IMConversationListViewController()
        conversationVC.title = barIm
        let messages = ZLNavigationController(rootViewController: conversationVC)
        messages.tabBarItem = UITabBarItem(title: barIm, image: UIImage(named: "icon_news_nor"), selectedImage: O2ThemeManager.image(for: "Icon.icon_news_pre"))

        //通讯录
        let addressVC = OOTabBarHelper.getVC(storyboardName: "contacts", vcName: nil)
        let address = ZLNavigationController(rootViewController: addressVC)
        address.tabBarItem = UITabBarItem(title: barContact, image: UIImage(named: "icon_address_g"), selectedImage: O2ThemeManager.image(for: "Icon.icon_address_list_pro"))

        // main
        let mainVC = mainController()
        mainVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "icon_zhuye_nor"), selectedImage: O2ThemeManager.image(for: "Icon.icon_zhuye_pre"))
        mainVC.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        let blurImage = OOCustomImageManager.default.loadImage(.index_bottom_menu_logo_blur)
        let newBlurImage = blurImage?.withRenderingMode(.alwaysOriginal)
        mainVC.tabBarItem.image = newBlurImage
        let focusImage = OOCustomImageManager.default.loadImage(.index_bottom_menu_logo_focus)
        let newFocusImage = focusImage?.withRenderingMode(.alwaysOriginal)
        mainVC.tabBarItem.selectedImage = newFocusImage

        //应用
        let appsVC = OOTabBarHelper.getVC(storyboardName: "apps", vcName: nil)
        let apps = ZLNavigationController(rootViewController: appsVC)
        apps.tabBarItem = UITabBarItem(title: barApps, image: UIImage(named: "icon_yingyong"), selectedImage: O2ThemeManager.image(for: "Icon.icon_yingyong_pro"))

        //设置
        let settingsVC = OOTabBarHelper.getVC(storyboardName: "setting", vcName: nil)
        let settings = ZLNavigationController(rootViewController: settingsVC)
        settings.tabBarItem = UITabBarItem(title: barSettings, image: UIImage(named: "setting_normal"), selectedImage: O2ThemeManager.image(for: "Icon.setting_selected"))

        self.viewControllers = [messages, address, mainVC, apps, settings]

    }
    
    /// 简版 只有首页和设置
    private func _initSimpleControllers() {
        // main
        let mainVC = mainController()
        mainVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "icon_zhuye_nor"), selectedImage: O2ThemeManager.image(for: "Icon.icon_zhuye_pre"))
        mainVC.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        let blurImage = OOCustomImageManager.default.loadImage(.index_bottom_menu_logo_blur)
        let newBlurImage = blurImage?.withRenderingMode(.alwaysOriginal)
        mainVC.tabBarItem.image = newBlurImage
        let focusImage = OOCustomImageManager.default.loadImage(.index_bottom_menu_logo_focus)
        let newFocusImage = focusImage?.withRenderingMode(.alwaysOriginal)
        mainVC.tabBarItem.selectedImage = newFocusImage
        //设置
        let settingsVC = OOTabBarHelper.getVC(storyboardName: "setting", vcName: nil)
        let settings = ZLNavigationController(rootViewController: settingsVC)
        settings.tabBarItem = UITabBarItem(title: barSettings, image: UIImage(named: "setting_normal"), selectedImage: O2ThemeManager.image(for: "Icon.setting_selected"))

        self.viewControllers = [mainVC, settings]
    }

    private func mainController() -> UIViewController {
        let appid = O2AuthSDK.shared.customStyle()?.indexPortal
        let indexType = O2AuthSDK.shared.customStyle()?.indexType ?? "default"
        if indexType == "portal" {
            let app = DBManager.shared.queryData(appid!)
            let destVC = OOTabBarHelper.getVC(storyboardName: "apps", vcName: "OOMainWebVC")
            if let mail = destVC as? MailViewController {
                mail.app = app
                mail.isIndexShow = true
                let nav = ZLNavigationController(rootViewController: mail)
                return nav
            } else {
                let nav = ZLNavigationController(rootViewController: destVC)
                return nav
            }
        } else {
            let destVC = OOTabBarHelper.getVC(storyboardName: "task", vcName: nil)
            let nav = ZLNavigationController(rootViewController: destVC)
            return nav
        }
    }
    
    // MARK: - 论坛 禁言问题查询
    private func checkBBSMuteInfo() {
        self.bbsVm.getMuteInfo().then { info in
            O2AuthSDK.shared.setupMuteInfo(muteInfo: info)
        }.catch { err in
            O2AuthSDK.shared.setupMuteInfo(muteInfo: nil)
        }
    }
    
    // MARK: - 考勤判断版本
    private func checkAttendanceVersion() {
        self.attendanceViewModel.checkVersion { version in
            if let v = version?.version, v == "2" {
                StandDefaultUtil.share.userDefaultCache(value: "2" as AnyObject, key: O2.O2_Attendance_version_key)
                DDLogInfo("考勤v2")
            } else {
                DDLogInfo("老版考勤")
                StandDefaultUtil.share.userDefaultCache(value: "1" as AnyObject, key: O2.O2_Attendance_version_key)
            }
        }
    }
    
    // MARK: - 云盘判断是否v3版本
    private func checkCloudFileVersion() {
        self.cFileVM.v3Echo().then { result in
            StandDefaultUtil.share.userDefaultCache(value: result as AnyObject, key: O2.O2CloudFileVersionKey)
        }.catch { error in
            StandDefaultUtil.share.userDefaultCache(value: false as AnyObject, key: O2.O2CloudFileVersionKey)
            DDLogError(error.localizedDescription)
        }
    }

    
    // MARK: - IM message
    func getConversationList() {
        imViewModel.myConversationList().then { (list) in
            var n = 0
            if !list.isEmpty {
                for item in list {
                    if let number = item.unreadNumber {
                        n += number
                    }
                }
            }
            DispatchQueue.main.async {
                DDLogDebug("消息数量: \(n)")
                if n > 0 && n < 100 {
                    self.showRedPoint(number: "\(n)")
                } else if n >= 100 {
                    self.showRedPoint(number: "99..")
                }
            }
        }
    }

    private func showRedPoint(number: String) {
        self.viewControllers?.forEach({ (vc) in
            if let zl = vc as? ZLNavigationController, zl.tabBarItem?.title == barIm {
                zl.tabBarItem.badgeValue = number
            }
        })
    }
    
    //消息模块未读消息数量加1
    private func addUnreadNumber() {
        self.viewControllers?.forEach({ (vc) in
            if let zl = vc as? ZLNavigationController, zl.tabBarItem?.title == barIm {
                if let badge = zl.tabBarItem.badgeValue {
                    if badge != "99.." {
                        if let n = Int(string: badge) {
                            let number = n + 1
                            if number > 0 && number < 100 {
                                self.showRedPoint(number: "\(number)")
                            } else if number >= 100 {
                                self.showRedPoint(number: "99..")
                            }
                        }
                    }
                }else {
                    self.showRedPoint(number: "1")
                }
            }
        })
    }

    
    // MARK: - app update 
    private func checkAppVersion() {
        O2VersionManager.shared.checkAppUpdate { (info, error) in
            if let iosInfo = info {
                DDLogDebug(iosInfo.toJSONString() ?? "")
                let alertController = UIAlertController(title: "版本更新", message: "更新内容：\(iosInfo.content ?? "")", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "确定", style: .default, handler: { ok in
                    O2VersionManager.shared.updateAppVersion(info?.downloadUrl)
                })
                let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: { c in
                    //
                })
                alertController.addAction(cancelAction)
                alertController.addAction(okAction)
                UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
            } else {
                DDLogInfo("没有版本更新：\(error ?? "")")
            }
        }
    }



    // MARK: - websocket
    private var timer: Timer?
    private var isWsOpen = false

    private func _startWebsocket() {
        DDLogDebug("启动websocket连接。。。。。。")
        let url = AppDelegate.o2Collect.generateWebsocketURL()
        DDLogDebug("这个是wsurl ：\(url)")
        O2WebsocketManager.instance.startConnect(wsUrl: url, delegate: self)
    }

    private func _stopWebsocket() {
        DDLogDebug("关闭websocket连接。。。。。。")
        self.stopTiming()
        O2WebsocketManager.instance.closeConnect()
    }

    private func startTiming() {
        DDLogDebug("开启定时器 。。。。。。")
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
        timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(sendHeartbeatMsg), userInfo: nil, repeats: true)
        timer?.fire()
    }
    private func stopTiming() {
        DDLogDebug("关闭定时器 。。。。。。")
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
    //发送心跳
    @objc private func sendHeartbeatMsg() {
        if isWsOpen {
            O2WebsocketManager.instance.send(msg: o2_im_ws_heartbeat)
        } else { //重新启动
            _startWebsocket()
        }
    }

}

extension O2MainController: WebSocketDelegate {


    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .text(let text):
            if text != o2_im_ws_heartbeat { //忽略心跳消息
                DDLogDebug("接收的ws消息：\(text)")
                //判断type im消息就发送通知
                do {
                    if let dicArr = try JSONSerialization.jsonObject(with: String(text).data(using: .utf8)!, options: .allowFragments) as? [String: AnyObject] {
                        guard let type = dicArr["type"] as? String else {
                            return
                        }
                        if type == O2.O2_MESSAGE_TYPE_IM_CREATE {
                            if let messageInfo = WsMessage.deserialize(from: text) {
                                DDLogDebug("接收到im消息 发送通知。。")
                                NotificationCenter.post(customeNotification: OONotification.imCreate, object: messageInfo.body)
                            }
                            self.addUnreadNumber()
                            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                        } else if type == O2.O2_MESSAGE_TYPE_IM_REVOKE {
                            if let messageInfo = WsMessage.deserialize(from: text) {
                                DDLogDebug("接收到im消息 撤回消息")
                                NotificationCenter.post(customeNotification: OONotification.imRevoke, object: messageInfo.body)
                            }
                        }
                    }
                } catch { }
            }
            break
        case .connected(let headers):
            DDLogDebug("websocket is connected: \(headers)")
            isWsOpen = true
            self.startTiming()
            break
        case .disconnected(let reason, let code):
            DDLogDebug("websocket is disconnected: \(reason) with code: \(code)")
            isWsOpen = false
            break
        case .binary(let data):
            DDLogDebug("websocket binary Received  二进制对象: \(data.count)")
            break
        case .ping(_):
            break
        case .pong(_):
            break
//        case .viablityChanged(_):
//            DDLogDebug("websocket viablityChanged")
//            break
        case .reconnectSuggested(_):
            DDLogDebug("websocket reconnectSuggested")
            break
        case .cancelled:
            DDLogDebug("websocket is canceled")
            isWsOpen = false
            break
        case .error(let error):
            DDLogError("websocket is error, \(String(describing: error?.localizedDescription))")
            isWsOpen = false
            break
        case .viabilityChanged(_):
            DDLogDebug("websocket viablityChanged")
            break
         
        }
    }


}

