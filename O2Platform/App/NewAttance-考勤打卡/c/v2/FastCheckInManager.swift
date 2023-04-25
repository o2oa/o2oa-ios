//
//  FastCheckInManager.swift
//  O2Platform
//
//  Created by FancyLou on 2023/4/20.
//  Copyright © 2023 zoneland. All rights reserved.
//

import UIKit
import CocoaLumberjack


///
/// 极速打卡功能类
///
class FastCheckInManager: NSObject {
    
    private lazy var viewModel: OOAttandanceViewModel = {
        return OOAttandanceViewModel()
    }()
    
    
    static let shared: FastCheckInManager = {
        return FastCheckInManager()
    }()
    
    
    private override init() {}
    
    private var isRunning = false // 是否已经在跑了
    
    /// 启动极速打卡
    func start() {
        if self.isRunning {
            DDLogInfo("已经在进行中。。。。。")
            return
        }
        self.isRunning = true
        DDLogInfo("准备开始极速打卡==================================")
        DDLogInfo("获取考勤配置文件！")
        self.viewModel.v2Config().then { config in
            if config.onDutyFastCheckInEnable || config.offDutyFastCheckInEnable {
                self.onDutyFastCheckInEnable = config.onDutyFastCheckInEnable
                self.offDutyFastCheckInEnable = config.offDutyFastCheckInEnable
                self.loadPreCheckData()
            } else {
                DDLogInfo("没有开启极速打卡功能！")
                self.isRunning = false
            }
        }.catch { error in
            DDLogError("\(error.localizedDescription)")
            self.isRunning = false
        }
    }
    
    /// 结束极速打卡
    func stop() {
        self.isRunning = false
        self.stopTimer()
        self.stopLocationService()
        DDLogInfo("结束极速打卡====================================")
    }
    
    // MARK: - 消息推送
    private func pushMessage(title: String, content: String) {
        DDLogInfo("发送消息，\(title) \(content)")
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1, repeats: false)
        let nContent = UNMutableNotificationContent()
        nContent.title = title
        nContent.body = content
        nContent.sound = UNNotificationSound.default
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: nContent, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { err in
            if err != nil {
                DDLogError("发送通知失败，\(err?.localizedDescription ?? "")")
            }
        }
    }
    
    
    // MARK: -  定时器
    private var timer: Timer?
    private var timerCount = 0
    /// 启动计时器
    private func startTimer() {
        if self.timer == nil {
            //初始化定时器
            self.timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(timeTick), userInfo: nil, repeats: true)
        }
        self.timerCount = 0 // 初始化
        self.timer?.fire()
    }
    /// 关闭计时器
    private func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
    @objc private func timeTick() {
        if self.timerCount >= 2 * 60 { // 2分钟 强制结束
            self.stop()
        }
        self.timerCount += 10
    }
    
    // MARK: - 考勤数据
    private var onDutyFastCheckInEnable = false // 上班极速打卡
    private var offDutyFastCheckInEnable = false //下班极速打卡
    private var nextCheckInRecord: AttendanceV2CheckItemData? = nil // 当前要打卡的对象
    private var  workPlaceList: [AttendanceV2WorkPlace] = []
    private var isInWorkPlace = false
    private var currentWorkPlace: AttendanceV2WorkPlace? = nil
    private var canCheckIn: Bool = false // 是否能点击打卡
     
    
    /// 获取打卡数据 准备极速打卡
    private func loadPreCheckData() {
        self.viewModel.preCheckIn().then { data in
            // 先处理打卡场所
            self.workPlaceList.removeAll()
            data.workPlaceList.forEach { place in
                self.workPlaceList.append(place)
            }
            // 处理打卡数据展现
            self.canCheckIn = data.canCheckIn ?? false  //今天是否还需要打卡
            if self.canCheckIn {
                // 是否最后一条已经打卡过的数据
                self.nextCheckInRecord = data.checkItemList.first(where: { element in
                    return element.checkInResult == "PreCheckIn"
                })
                self.canCheckIn = self.nextCheckInRecord != nil
            }
            if self.canCheckIn {
                if (self.nextCheckInRecord?.checkInType == "OnDuty" && self.onDutyFastCheckInEnable)
                    || (self.nextCheckInRecord?.checkInType == "OffDuty" && self.offDutyFastCheckInEnable) {
                    DDLogInfo("开始启动定位并打卡！")
                    self.startLocationService()
                } else {
                    self.isRunning = false
                    DDLogInfo("当前打卡类型 不支持极速打卡！！！！")
                }
            } else {
                self.isRunning = false
                DDLogInfo("无需打卡！！！")
            }
        }.catch { error in
            DDLogError(error.localizedDescription)
            self.isRunning = false
        }
    }
    
    /// 尝试打卡
    private func tryCheckIn() {
        if self.bmkResult == nil {
            DDLogError("没有获取到当前位置信息，无法打卡。。。。。")
            return
        }
        if self.canCheckIn && self.nextCheckInRecord != nil {
            // 是否在打卡限制时间内
            let dutyTime = self.nextCheckInRecord?.preDutyTime ?? ""
            let preBeforeTime = self.nextCheckInRecord?.preDutyTimeBeforeLimit ?? ""
            let preAfterTime = self.nextCheckInRecord?.preDutyTimeAfterLimit ?? ""
            if !checkLimitTime(checkInType: self.nextCheckInRecord?.checkInType ?? "", dutyTime:dutyTime, preDutyTimeBeforeLimit: preBeforeTime, preDutyTimeAfterLimit: preAfterTime) {
                DDLogInfo("不在极速打卡时间内！！！！！！")
               return
           }
        
            if self.isInWorkPlace && self.currentWorkPlace != nil && self.currentWorkPlace?.id != nil {
                self.postCheckIn(record: self.nextCheckInRecord!, workPlaceId: self.currentWorkPlace!.id!)
            }
        }
    }
    
    private var isPosting = false // 防止重复提交
    private func postCheckIn(record: AttendanceV2CheckItemData, workPlaceId: String) {
        if isPosting {
            return
        }
        isPosting = true
        let body = AttendanceV2CheckInBody()
        body.recordId = record.id
        body.checkInType = record.checkInType
        body.latitude = String(self.bmkResult?.location.latitude ?? 0.0)
        body.longitude =  String(self.bmkResult?.location.longitude ?? 0.0)
        body.recordAddress = self.bmkResult?.address
        body.workPlaceId = workPlaceId
        body.fieldWork = false
        body.signDescription =  ""
        self.viewModel.checkIn(body: body).then { res in
            var msg = "极速打卡 成功"
            if res.recordDate != nil {
                msg = "\(res.recordDate!) 极速打卡 成功"
            }
            self.pushMessage(title: "考勤通知", content: msg)
            self.stop()
        }.catch { error in
            DDLogError("打卡提交失败，\(error.localizedDescription)")
            self.isPosting = false
        }
    }
    
    // 是否有打卡时间限制
    private func checkLimitTime(checkInType: String,  dutyTime: String, preDutyTimeBeforeLimit: String, preDutyTimeAfterLimit: String) -> Bool {
        let now = Date()
        let today = now.formatterDate(formatter: "yyyy-MM-dd")
        let dutyTimeDate = Date.date("\(today) \(dutyTime):00")
        if dutyTimeDate == nil {
            DDLogError("没有打卡时间！！！！！！！！！！！！！！！！！")
            return false
        }
        // 极速打卡开始时间
        var fastCheckInBeforeLimit = dutyTimeDate!
        if checkInType == "OnDuty" { // 上班打卡 ，提前一小时可以极速打卡
            fastCheckInBeforeLimit = dutyTimeDate!.add(component: .hour, value: -1)
        } else {
            fastCheckInBeforeLimit = dutyTimeDate!
        }
        // 极速打卡结束时间
        var fastCheckInAfterLimit = dutyTimeDate!
        if checkInType == "OnDuty" { //
            fastCheckInAfterLimit = dutyTimeDate!
        } else {
            fastCheckInAfterLimit = dutyTimeDate!.add(component: .hour, value: 1)
        }
        
        if (!preDutyTimeBeforeLimit.isEmpty) {
            if let beforeTime = Date.date("\(today) \(preDutyTimeBeforeLimit):00"), fastCheckInBeforeLimit.isBefore(date: beforeTime) {
                fastCheckInBeforeLimit = beforeTime
            }
        }
        if (!preDutyTimeAfterLimit.isEmpty) {
            if let afterTime =  Date.date("\(today) \(preDutyTimeAfterLimit):00"), afterTime.isBefore(date: fastCheckInAfterLimit) {
                fastCheckInAfterLimit = afterTime
            }
        }
        DDLogInfo("极速打卡时间限制：\(now) \(fastCheckInBeforeLimit) \(fastCheckInAfterLimit)")
        if fastCheckInBeforeLimit.isBefore(date: now) && now.isBefore(date: fastCheckInAfterLimit) {
            return true
        }
        return false
    }
    
    /// 接收到位置信息
    private func locationReceive(bmkResult: BMKReverseGeoCodeSearchResult, isIn: Bool, workPlace: AttendanceV2WorkPlace?) {
        self.isInWorkPlace = isIn
        self.bmkResult = bmkResult
        self.currentWorkPlace = workPlace
        if isIn {
            self.tryCheckIn()
        }
    }
    
    // MARK: - 定位
    //定位
    private var userLocation: BMKUserLocation? = nil
    private var locService: BMKLocationManager? = nil
    private var searchAddress: BMKGeoCodeSearch? = nil
    private var bmkResult: BMKReverseGeoCodeSearchResult? = nil
    /// 开启定位
    private func startLocationService() {
        // 定位开始 启动计时
        self.startTimer()
        if locService == nil {
            locService = BMKLocationManager()
            locService?.desiredAccuracy = kCLLocationAccuracyBest
            //设置返回位置的坐标系类型
            locService?.coordinateType = .BMK09LL
            //设置距离过滤参数
            locService?.distanceFilter = kCLDistanceFilterNone;
            //设置预期精度参数
            locService?.desiredAccuracy = kCLLocationAccuracyBest;
            //设置应用位置类型
            locService?.activityType = .automotiveNavigation
            //设置是否自动停止位置更新
            locService?.pausesLocationUpdatesAutomatically = false
            
            locService?.delegate = self
            locService?.startUpdatingLocation()
        }
        if searchAddress == nil {
            searchAddress = BMKGeoCodeSearch()
            searchAddress?.delegate = self
        }
    }
    /// 结束定位
    private func stopLocationService() {
        locService?.stopUpdatingLocation()
        locService?.delegate = nil
        searchAddress?.delegate = nil
        locService = nil
        searchAddress = nil
    }
}



extension FastCheckInManager: BMKLocationManagerDelegate {

    func bmkLocationManager(_ manager: BMKLocationManager, didUpdate location: BMKLocation?, orError error: Error?) {
        if let loc = location?.location {
            DDLogDebug("当前位置,\(loc.coordinate.latitude),\(loc.coordinate.longitude)")
            //搜索到指定的地点
            let re = BMKReverseGeoCodeSearchOption()
            re.location = CLLocationCoordinate2D(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)
            let s = searchAddress?.reverseGeoCode(re)
            DDLogDebug("查询地址结果: \(s ?? false)")
        } else {
            DDLogError("没有获取到定位信息！！！！！")
        }
    }


}

extension FastCheckInManager: BMKGeoCodeSearchDelegate {

    /// 计算所有位置是否有一个位置在误差范围内
    func calcErrorRange(_ checkinLocation: CLLocationCoordinate2D) -> (Bool, AttendanceV2WorkPlace?) {
        var result = false
        for item in self.workPlaceList {
            let longitude = Double((item.longitude)!)
            let latitude = Double((item.latitude)!)
            let eRange = item.errorRange!
            let theLocation = CLLocationCoordinate2DMake(latitude!, longitude!)
            result = BMKCircleContainsCoordinate(theLocation, checkinLocation, Double(eRange))
            if result == true {
                return (true, item)
            }
        }
        return (false, nil)
    }

    func onGetReverseGeoCodeResult(_ searcher: BMKGeoCodeSearch?, result: BMKReverseGeoCodeSearchResult?, errorCode error: BMKSearchErrorCode) {
        //发送定位的实时位置及名称信息
        if let location = result?.location {
            let calResult = calcErrorRange(location)
            self.locationReceive(bmkResult: result!, isIn: calResult.0, workPlace: calResult.1)
        } else {
            DDLogError("GeoCodeSearch 查询到 地址信息为空！！")
        }
    }

    func onGetGeoCodeResult(_ searcher: BMKGeoCodeSearch!, result: BMKGeoCodeSearchResult!, errorCode error: BMKSearchErrorCode) {
        if Int(error.rawValue) == 0 {
            DDLogError("GeoCodeSearch 查询错误 \(String(describing: result))")
        } else {
            DDLogError("GeoCodeSearch 查询错误  errorCode = \(Int(error.rawValue))")
        }

    }
}

