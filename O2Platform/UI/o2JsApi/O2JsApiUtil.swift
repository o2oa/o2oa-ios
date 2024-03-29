//
//  O2JsApiUtil.swift
//  O2Platform
//
//  Created by FancyLou on 2019/5/7.
//  Copyright © 2019 zoneland. All rights reserved.
//

import UIKit
import WebKit
import CocoaLumberjack


class O2JsApiUtil: O2WKScriptMessageHandlerImplement {
   
    
    let viewController: BaseWebViewUIViewController
    
    init(viewController: BaseWebViewUIViewController) {
        self.viewController = viewController
    }
    
    func userController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.body is NSString {
            let json = message.body as! NSString
            DDLogDebug("message json:\(json)")
            if let jsonData = String(json).data(using: .utf8) {
                let dicArr = try! JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as! [String:AnyObject]
                if let type = dicArr["type"] as? String {
                    switch type {
                    case "date.datePicker":
                        datePicker(json: String(json))
                        break
                    case "date.timePicker":
                        timePicker(json: String(json))
                        break
                    case "date.dateTimePicker":
                        dateTimePicker(json: String(json))
                        break
                    case "calendar.chooseOneDay":
                        calendarPickDay(json: String(json))
                        break
                    case "calendar.chooseDateTime":
                        calendarPickerDateTime(json: String(json))
                        break
                    case "calendar.chooseInterval":
                        calendarPickerDateInterval(json: String(json))
                        break
                    case "device.rotate":
                        rotateToggle(json: String(json))
                        break
                    case "device.getPhoneInfo":
                        getPhoneInfo(json: String(json))
                        break
                    case "device.scan":
                        scan(json: String(json))
                        break
                    case "device.location":
                        locationSingle(json: String(json))
                        break
                    case "device.openMap":
                        openMap(json: String(json))
                        break
                    case "navigation.setTitle":
                        navigationSetTitle(json: String(json))
                        break
                    case "navigation.close":
                        navigationClose(json: String(json))
                        break
                    case "navigation.goBack":
                        navigationGoBack(json: String(json))
                        break
                    case "navigation.openOtherApp":
                        navigationOpenOtherApp(json: String(json))
                        break
                    case "navigation.openInnerApp":
                        navigationOpenInnerApp(json: String(json))
                        break
                    case "navigation.openWindow":
                        navigationOpenWindow(json: String(json))
                        break
                    default:
                        DDLogError("notification类型不正确, type: \(type)")
                    }
                }else {
                    DDLogError("util类型不存在 json解析异常。。。。。")
                }
            }else {
                DDLogError("消息json解析异常。。。")
            }
        }else {
            DDLogError("message 消息 body 类型不正确。。。")
        }
    }
   
    
    private func datePicker(json: String) {
        if let alert = O2WebViewBaseMessage<O2UtilPicker>.deserialize(from: json) {
            let title = alert.data?.value ?? ""
            DDLogDebug("value:\(title)")
            let defaultDate: Date!
            if title.isBlank {
                defaultDate = Date()
            }else {
                defaultDate = title.toDate(formatter: "yyyy-MM-dd")
            }
            let picker = QDatePicker{ (date: String) in
                print(date)
                if alert.callback != nil {
                    let callJs = "\(alert.callback!)('{\"value\":\"\(date)\"}')"
                    self.evaluateJs(callBackJs: callJs)
                }
            }
            picker.themeColor = O2ThemeManager.color(for: "Base.base_color")!
            picker.datePickerStyle = .YMD
            picker.pickerStyle = .datePicker
            picker.showDatePicker(defaultDate: defaultDate)
        }else {
            DDLogError("datePicker, 解析json失败")
        }
    }
    private func timePicker(json: String) {
        if let alert = O2WebViewBaseMessage<O2UtilPicker>.deserialize(from: json) {
            let title = alert.data?.value ?? ""
            let defaultDate: Date!
            if title.isBlank {
                defaultDate = Date()
            }else {
                let ymd = Date().formatterDate(formatter: "yyyy-MM-dd")
                defaultDate = (ymd+" "+title).toDate(formatter: "yyyy-MM-dd HH:mm")
            }
            let picker = QDatePicker{ (date: String) in
                print(date)
                if alert.callback != nil {
                    let callJs = "\(alert.callback!)('{\"value\":\"\(date)\"}')"
                    self.evaluateJs(callBackJs: callJs)
                }
            }
            picker.themeColor = O2ThemeManager.color(for: "Base.base_color")!
            picker.datePickerStyle = .HM
            picker.pickerStyle = .datePicker
            picker.showDatePicker(defaultDate: defaultDate)
        }else {
            DDLogError("datePicker, 解析json失败")
        }
    }
    private func dateTimePicker(json: String) {
        if let alert = O2WebViewBaseMessage<O2UtilPicker>.deserialize(from: json) {
            let title = alert.data?.value ?? ""
            let defaultDate: Date!
            if title.isBlank {
                defaultDate = Date()
            }else {
                defaultDate = title.toDate(formatter: "yyyy-MM-dd HH:mm")
            }
            let picker = QDatePicker{ (date: String) in
                print(date)
                if alert.callback != nil {
                    let callJs = "\(alert.callback!)('{\"value\":\"\(date)\"}')"
                    self.evaluateJs(callBackJs: callJs)
                }
            }
            picker.themeColor = O2ThemeManager.color(for: "Base.base_color")!
            picker.datePickerStyle = .YMDHM
            picker.pickerStyle = .datePicker
            picker.showDatePicker(defaultDate: defaultDate)
        }else {
            DDLogError("datePicker, 解析json失败")
        }
    }
    
    private func calendarPickDay(json: String) {
        if let alert = O2WebViewBaseMessage<O2UtilPicker>.deserialize(from: json) {
            let title = alert.data?.value ?? ""
            DDLogDebug("value:\(title)")
            let defaultDate: Date!
            if title.isBlank {
                defaultDate = Date()
            }else {
                defaultDate = title.toDate(formatter: "yyyy-MM-dd")
            }
            let calendarPicker = QCalendarPicker{ (date: String) in
                if alert.callback != nil {
                    let callJs = "\(alert.callback!)('{\"value\":\"\(date)\"}')"
                    self.evaluateJs(callBackJs: callJs)
                }
            }
            calendarPicker.calendarPickerStyle = .datePicker
            calendarPicker.showPickerWithDefault(defaultDate: defaultDate)
        }else {
            DDLogError("datePicker, 解析json失败")
        }
    }
    private func calendarPickerDateTime(json: String) {
        if let alert = O2WebViewBaseMessage<O2UtilPicker>.deserialize(from: json) {
            let title = alert.data?.value ?? ""
            DDLogDebug("value:\(title)")
            let defaultDate: Date!
            if title.isBlank {
                defaultDate = Date()
            }else {
                defaultDate = title.toDate(formatter: "yyyy-MM-dd HH:mm")
            }
            let calendarPicker = QCalendarPicker{ (date: String) in
                if alert.callback != nil {
                    let callJs = "\(alert.callback!)('{\"value\":\"\(date)\"}')"
                    self.evaluateJs(callBackJs: callJs)
                }
            }
            calendarPicker.calendarPickerStyle = .dateTimePicker
            calendarPicker.showPickerWithDefault(defaultDate: defaultDate)
        }else {
            DDLogError("datePicker, 解析json失败")
        }
    }
    
    private func calendarPickerDateInterval(json: String) {
        if let alert = O2WebViewBaseMessage<O2UtilPicker>.deserialize(from: json) {
            let start = alert.data?.startDate ?? ""
            let end = alert.data?.endDate ?? ""
            DDLogDebug("start:\(start) , end:\(end)")
            let startDate: Date!
            if start.isBlank {
                startDate = Date()
            }else {
                startDate = start.toDate(formatter: "yyyy-MM-dd")
            }
            let endDate: Date!
            if end.isBlank {
                endDate = Date()
            }else {
                endDate = end.toDate(formatter: "yyyy-MM-dd")
            }
            let calendarPicker = QCalendarPicker{ (date: String) in
                if alert.callback != nil {
                    let result = date.split(" ")
                    let callJs = "\(alert.callback!)('{\"startDate\":\"\(result[0])\", \"endDate\":\"\(result[1])\"}')"
                    self.evaluateJs(callBackJs: callJs)
                }
            }
            calendarPicker.calendarPickerStyle = .dateIntervalPicker
            calendarPicker.showPickerWithDefault(defaultDate: startDate, endDate: endDate)
        }else {
            DDLogError("calendarPickerDateInterval, 解析json失败")
        }
    }
    
    
    // 手机屏幕旋转 横屏转竖屏 竖屏转横屏
    private func rotateToggle(json: String) {
        if let alert = O2WebViewBaseMessage<O2UtilNavigation>.deserialize(from: json) {
            self.viewController.onChangeOrientationBtnTapped(nil)
            if alert.callback != nil {
                let callJs = "\(alert.callback!)('{}')"
                self.evaluateJs(callBackJs: callJs)
            }
        }else {
            DDLogError("rotate 屏幕旋转, 解析json失败")
        }
    }
    
    //获取手机信息
    private func getPhoneInfo(json: String) {
        if let alert = O2WebViewBaseMessage<O2UtilNavigation>.deserialize(from: json) {
            if alert.callback != nil {
                DeviceUtil.shared.getDeviceInfoForJsApi { (info) in
                    let backData = info.toJSONString(prettyPrint: false) ?? ""
                    let callJs = "\(alert.callback!)('\(backData)')"
                    self.evaluateJs(callBackJs: callJs)
                }
            }
        }else {
            DDLogError("getPhoneInfo, 解析json失败")
        }
    }
    //扫二维码返回结果
    private func scan(json: String) {
        if let alert = O2WebViewBaseMessage<O2UtilNavigation>.deserialize(from: json) {
            if alert.callback != nil {
                //扫一扫 。。。返回结果
                ScanHelper.openScan(vc: self.viewController, callbackResult: { (result) in
                    var resultCode = result.replacingOccurrences(of: "'", with: #"\u0027"#) // 单引号冲突
                    resultCode = resultCode.replacingOccurrences(of: "\n", with: "") // 换行
                    resultCode = resultCode.replacingOccurrences(of: "\r", with: "") // 回车
//                    let resultData = O2UtilScanResult(text: resultCode).toJSONString() ?? "{}"
                    let callJs = "\(alert.callback!)('\(resultCode)')"
                    self.evaluateJs(callBackJs: callJs)
                })
            }
        }else {
            DDLogError("getPhoneInfo, 解析json失败")
        }
    }
    //单次定位
    private func locationSingle(json: String) {
        if let alert = O2WebViewBaseMessage<O2UtilNavigation>.deserialize(from: json) {
            if alert.callback != nil {
                DispatchQueue.main.async {
                    self.viewController.locationCallBack = { result in
                        guard let r = result else {
                            DDLogError("没有获取到位置信息")
                            return
                        }
                        let callJs = "\(alert.callback!)('\(r)')"
                        self.evaluateJs(callBackJs: callJs)
                    }
                    self.viewController.startLocation()
                }
            }
        }else {
            DDLogError("locationSingle, 解析json失败")
        }
    }
    
    //打开地图位置
    private func openMap(json: String) {
        if let map = O2WebViewBaseMessage<O2UtilOpenMap>.deserialize(from: json) {
            if let callback = map.callback, let data = map.data  {
                DispatchQueue.main.async {
                    IMShowLocationViewController.pushShowLocation(vc: self.viewController, latitude: data.latitude,
                                                                  longitude: data.longitude, address: data.address, addressDetail: data.addressDetail)
                    let callJs = "\(callback)('{}')"
                    self.evaluateJs(callBackJs: callJs)
                }
            }
        }else {
            DDLogError("openMap, 解析json失败")
        }
    }
    
    //设置t标题
    private func navigationSetTitle(json: String) {
        if let alert = O2WebViewBaseMessage<O2UtilNavigation>.deserialize(from: json) {
            let title = alert.data?.title ?? ""
            if title != "" {
                self.viewController.title = title
            }
            if alert.callback != nil {
                let callJs = "\(alert.callback!)('{}')"
                self.evaluateJs(callBackJs: callJs)
            }
        }else {
            DDLogError("navigationSetTitle, 解析json失败")
        }
    }
    //关闭窗口
    private func navigationClose(json: String) {
        if let alert = O2WebViewBaseMessage<O2UtilNavigation>.deserialize(from: json) {
            self.closeSelf()
            if alert.callback != nil {
                let callJs = "\(alert.callback!)('{}')"
                self.evaluateJs(callBackJs: callJs)
            }
        }else {
            DDLogError("navigationClose, 解析json失败")
        }
    }
    //返回上级 html history
    private func navigationGoBack(json: String) {
        if let alert = O2WebViewBaseMessage<O2UtilNavigation>.deserialize(from: json) {
            if self.viewController.webView.canGoBack {
                self.viewController.webView.goBack()
            }else {
                self.closeSelf()
            }
            if alert.callback != nil {
                let callJs = "\(alert.callback!)('{}')"
                self.evaluateJs(callBackJs: callJs)
            }
        }else {
            DDLogError("navigationGoBack, 解析json失败")
        }
    }
    
    // 打开其他app schema方式
    private func navigationOpenOtherApp(json: String) {
        if let alert = O2WebViewBaseMessage<O2UtilNavigationOpenOtherApp>.deserialize(from: json) {
            var backresult = "{\"result\": true, \"message\": \"\"}"
            if let schema = alert.data?.schema {
                DDLogDebug("打开app schema：\(schema)")
                if let url = URL(string: "\(schema)") {
                    if #available(iOS 10, *) {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        } else {
                            DDLogError("无法打开url，\(schema)")
                            backresult = "{\"result\": false, \"message\": \"ios 当前不支持这个app打开，schema:\(schema)\"}"
                        }
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                } else {
                    DDLogError("url 为空。。。。。")
                }
            }
            if alert.callback != nil {
                let callJs = "\(alert.callback!)('\(backresult)')"
                self.evaluateJs(callBackJs: callJs)
            }
        }else {
            DDLogError("navigationOpenOtherApp, 解析json失败")
        }
    }
    // 打开内部应用
    private func navigationOpenInnerApp(json: String) {
        if let alert = O2WebViewBaseMessage<O2UtilNavigationOpenInnerApp>.deserialize(from: json) {
            let backresult = "{\"result\": true, \"message\": \"\"}"
            if let appKey = alert.data?.appKey {
                DDLogDebug("打开app appKey：\(appKey)")
                switch appKey {
                case "task":
                    self.openNative(appKey: appKey, storyBoardName: "task", "todoTask")
                    break
                case "taskcompleted":
                    self.openNative(appKey: appKey, storyBoardName: "task", "todoTask")
                    break
                case "read":
                    self.openNative(appKey: appKey, storyBoardName: "task", "todoTask")
                    break
                case "readcompleted":
                    self.openNative(appKey: appKey, storyBoardName: "task", "todoTask")
                    break
                case "meeting":
                    self.openNative(appKey: appKey, storyBoardName: "meeting")
                    break
                case "clouddisk":
                    self.openNative(appKey: appKey, storyBoardName: "CloudFile")
                    break
                case "bbs":
                    self.openNative(appKey: appKey, storyBoardName: "bbs")
                    break
                case "cms":
                    self.openNative(appKey: appKey, storyBoardName: "information")
                    break
                case "attendance":
                    self.openNative(appKey: appKey, storyBoardName: "checkin")
                    break
                case "calendar":
                    self.openNative(appKey: appKey, storyBoardName: "calendar")
                    break
                case "mindMap":
                    let storyBoard = UIStoryboard(name: "mindMap", bundle: nil)
                    if let destVC = storyBoard.instantiateInitialViewController() {
                        destVC.modalPresentationStyle = .fullScreen
                        self.viewController.show(destVC, sender: nil)
                    } else {
                        DDLogError("没有找到view controller。。。。")
                    }
                    break
                case "portal":
                    if let portalId = alert.data?.portalFlag {
                        let title = alert.data?.portalTitle
                        let page = alert.data?.portalPage
                        var webUrl: String? = nil
                        if let page = page, page.isEmpty == false {
                            webUrl = AppDelegate.o2Collect.genrateURLWithWebContextKey(DesktopContext.DesktopContextKey, query: DesktopContext.portalMobileWithPageQuery, parameter: ["##portalId##":portalId  as AnyObject, "##page##":page  as AnyObject],covertd:false)
                        } else {
                            webUrl = AppDelegate.o2Collect.genrateURLWithWebContextKey(DesktopContext.DesktopContextKey, query: DesktopContext.portalMobileQuery, parameter: ["##portalId##":portalId  as AnyObject],covertd:false)
                        }
                        let destVC = OOTabBarHelper.getVC(storyboardName: "apps", vcName: "OOMainWebVC")
                        if let mail = destVC as? MailViewController {
                            let o2app = O2App()
                            o2app.title = title
                            o2app.vcName = webUrl
                            mail.app = o2app
                            let nav = ZLNavigationController(rootViewController: mail)
                            self.viewController.present(nav, animated: true, completion: nil)
                        } else {
                            DDLogDebug("没有webview ？？？？？？")
                        }
                    }else {
                        DDLogDebug("没有portalFlag ？？？？？？")
                    }
                    break
                default:
                    DDLogError("navigationOpenOtherApp, 解析json失败")
                    break
                }
            }
            if alert.callback != nil {
                let callJs = "\(alert.callback!)('\(backresult)')"
                self.evaluateJs(callBackJs: callJs)
            }
        }else {
            DDLogError("navigationOpenOtherApp, 解析json失败")
        }
    }
    
    private func openNative(appKey: String, storyBoardName: String, _ vcName: String? = nil) {
        DDLogDebug("storyboard: \(storyBoardName) , app:\(appKey), vcName: \(vcName ?? "")")
        let storyBoard = UIStoryboard(name: storyBoardName, bundle: nil)
        //let storyBoard = UIStoryboard(name: app.storyBoard!, bundle: nil)
        var destVC:UIViewController!
        /// 云盘v3版本 入口换了
        if let value = StandDefaultUtil.share.userDefaultGetValue(key: O2.O2CloudFileVersionKey) as? Bool, value == true, storyBoardName == "CloudFile" {
            destVC = storyBoard.instantiateViewController(withIdentifier: "cloudFileV3") // v3 入口
            DDLogDebug("网盘V3版本")
        } else if let vc = vcName, vc.isEmpty == false {
            if vc == "todoTask" {
                if "taskcompleted" == appKey {
                    AppConfigSettings.shared.taskIndex = 2
                }else if "read" == appKey {
                    AppConfigSettings.shared.taskIndex = 1
                }else if "readcompleted" == appKey {
                    AppConfigSettings.shared.taskIndex = 3
                }else {
                    AppConfigSettings.shared.taskIndex = 0
                }
            }
            destVC = storyBoard.instantiateViewController(withIdentifier: vc)
        }else{
            destVC = storyBoard.instantiateInitialViewController()
        }
        destVC.modalPresentationStyle = .fullScreen
        if destVC.isKind(of: ZLNavigationController.self) {
            self.viewController.show(destVC, sender: nil)
        }else{
            self.viewController.navigationController?.pushViewController(destVC, animated: false)
        }
    }
    
    // 新窗口打开网页
    private func navigationOpenWindow(json: String) {
        if let alert = O2WebViewBaseMessage<O2UtilNavigationOpenWindow>.deserialize(from: json) {
            var backresult = "{\"result\": true, \"message\": \"\"}"
            if let url = alert.data?.url {
                DDLogDebug("打开 网页 ：\(url)")
                if let _ = URL(string: "\(url)") {
                    let destVC = OOTabBarHelper.getVC(storyboardName: "apps", vcName: "OOMainWebVC")
                    if let mail = destVC as? MailViewController {
                        mail.openUrl = url
                        let nav = ZLNavigationController(rootViewController: mail)
                        self.viewController.present(nav, animated: true, completion: nil)
                    } else {
                        DDLogDebug("没有webview ？？？？？？")
                    }
                } else {
                    DDLogError("url 为空。。。。。")
                    backresult = "{\"result\": false, \"message\": \"url不能为空！\"}"
                }
            }
            if alert.callback != nil {
                let callJs = "\(alert.callback!)('\(backresult)')"
                self.evaluateJs(callBackJs: callJs)
            }
        }else {
            DDLogError("navigationOpenWindow, 解析json失败")
        }
    }
    
    private func closeSelf() {
        guard let vcs = self.viewController.navigationController?.viewControllers else {
            self.viewController.navigationController?.dismiss(animated: false, completion: nil)
            return
        }
        if vcs.count > 0 {
            if vcs[vcs.count - 1] == self.viewController {
                self.viewController.navigationController?.popViewController(animated: false)
            }
        }else {
             self.viewController.navigationController?.dismiss(animated: false, completion: nil)
        }
    }
    
    
    private func evaluateJs(callBackJs: String) {
        DDLogDebug("执行回调js："+callBackJs)
        self.viewController.webView.evaluateJavaScript(callBackJs, completionHandler: { (result, err) in
            DDLogDebug("回调js执行完成！")
        })
    }
} 
