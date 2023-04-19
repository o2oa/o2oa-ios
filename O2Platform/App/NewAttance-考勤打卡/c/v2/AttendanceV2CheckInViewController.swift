//
//  AttendanceV2CheckInViewController.swift
//  O2Platform
//
//  Created by FancyLou on 2023/4/18.
//  Copyright © 2023 zoneland. All rights reserved.
//

import UIKit
import CocoaLumberjack

class AttendanceV2CheckInViewController: UIViewController {

    @IBOutlet weak var checkInBtnTitle: UILabel!
    
    @IBOutlet weak var checkInBtnTime: UILabel!
    
    @IBOutlet weak var recordItemsCollectionView: UICollectionView!
    
    @IBOutlet weak var locationIcon: UIImageView!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var checkInBtn: UIView!
    
    
    fileprivate let itemNumberInRow = 2
    //定位
    private var userLocation: BMKUserLocation? = nil
    private var locService: BMKLocationManager? = nil
    private var searchAddress: BMKGeoCodeSearch? = nil
    private var bmkResult: BMKReverseGeoCodeSearchResult? = nil
    
    //定时器
    private var timer: Timer?
    private lazy var viewModel: OOAttandanceViewModel = {
        return OOAttandanceViewModel()
    }()
    
    private var checkItemList: [AttendanceV2CheckItemData] = []
    private var nextCheckInRecord: AttendanceV2CheckItemData? = nil // 当前要打卡的对象
    private var  workPlaceList: [AttendanceV2WorkPlace] = []
    private var isInWorkPlace = false
    private var currentWorkPlace: AttendanceV2WorkPlace? = nil
    private var allowFieldWork:Bool = false // 是否能外勤打卡
    private var requiredFieldWorkRemarks: Bool = false // 外勤打卡是否必填描述
    private var canCheckIn: Bool = false // 是否能点击打卡
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(backForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "关闭", style: .plain, target: self, action: #selector(closeParent))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "返回老版", style: .plain, target: self, action: #selector(closeSelfOpenOld))
        // 列表
        self.recordItemsCollectionView.delegate = self
        self.recordItemsCollectionView.dataSource = self
        self.recordItemsCollectionView.register(UINib(nibName: "OOAttendanceScheduleViewCell", bundle: nil), forCellWithReuseIdentifier: "OOAttendanceScheduleViewCell")
        self.checkInBtn.addTapGesture { (tap) in
            self.clickCheckIn()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DDLogDebug("回到viewWillAppear。。。。。。。")
        if self.timer == nil {
            //初始化定时器
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timeTick), userInfo: nil, repeats: true)
        }
        self.timer?.fire()
        // 开始定位
        self.startLocationService()
        self.loadPreCheckData()
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.timer?.invalidate()
        self.timer = nil
        self.stopLocationService()
        NotificationCenter.default.removeObserver(self)
    }
 
    // 关闭考勤
    @objc private func closeParent() {
        // 上级是OONewAttanceController
        self.navigationController?.parent?.navigationController?.popViewController(animated: true)
    }
    // 重新打卡旧版考勤
    @objc private func closeSelfOpenOld() {
        // 存储老版的key
        StandDefaultUtil.share.userDefaultCache(value: "1" as AnyObject, key: O2.O2_Attendance_version_key)
        // 先关闭当前
        self.navigationController?.parent?.navigationController?.popViewController(animated: false)
        // 然后通知重新打开
        NotificationCenter.default.post(name: OONotification.reloadAttendance.notificationName, object: nil)
    }
    
    @objc private func backForeground() {
        DDLogDebug("回到前端。。重新请求数据，防止数据错误。")
        self.loadPreCheckData()
    }
    
    /// 打卡
    private func clickCheckIn () {
        if self.bmkResult == nil {
            DDLogError("没有获取到当前位置信息，无法打卡。。。。。")
            self.showError(title: "无法获取到当前位置信息，请确认是否开启定位权限！")
            return
        }
        if self.canCheckIn && self.nextCheckInRecord != nil {
            // 是否在打卡限制时间内
            let preBeforeTime = self.nextCheckInRecord?.preDutyTimeBeforeLimit ?? ""
            let preAfterTime = self.nextCheckInRecord?.preDutyTimeAfterLimit ?? ""
            if !checkLimitTime(preDutyTimeBeforeLimit: preBeforeTime, preDutyTimeAfterLimit: preAfterTime) {
               return
           }
        
            if self.isInWorkPlace && self.currentWorkPlace != nil {
                self.postCheckIn(record: self.nextCheckInRecord!, workPlaceId: self.currentWorkPlace?.id, fieldWork: false,fieldWorkRemark: nil)
            } else {
                self.outSideCheckIn(record: self.nextCheckInRecord!)
            }
        }
    }
    
    /// 更新打卡
    private func updateCheckIn(record:AttendanceV2CheckItemData) {
        if self.bmkResult == nil {
            DDLogError("没有获取到当前位置信息，无法打卡。。。。。")
            self.showError(title: "无法获取到当前位置信息，请确认是否开启定位权限！")
            return
        }
        if record.isLastRecord {
            if self.isInWorkPlace && self.currentWorkPlace != nil {
                self.postCheckIn(record: record, workPlaceId: self.currentWorkPlace?.id, fieldWork: false,fieldWorkRemark: nil)
            } else {
                self.outSideCheckIn(record: record)
            }
        }
    }
    
    /// 外勤打卡
    private func outSideCheckIn(record: AttendanceV2CheckItemData) {
        if self.allowFieldWork {
            if self.requiredFieldWorkRemarks {
                self.showPromptAlert(title: "提示", message: "当前不在打卡范围内，你确定要进行外勤打卡吗？", inputText: "", placeholder: "请输入外勤打卡说明") { action, text in
                    if text.isBlank {
                        self.showError(title: "请输入外勤打卡说明")
                    } else {
                        self.postCheckIn(record: record, workPlaceId: nil, fieldWork: true ,fieldWorkRemark: text)
                    }
                }
            } else {
                self.postCheckIn(record: record, workPlaceId: nil, fieldWork: true ,fieldWorkRemark: nil)
            }
        } else {
            DDLogInfo("不允许外勤打卡！")
        }
    }
    
    // 是否有打卡时间限制
    private func checkLimitTime(preDutyTimeBeforeLimit: String, preDutyTimeAfterLimit: String) -> Bool {
        if (!preDutyTimeBeforeLimit.isEmpty) {
            let now = Date()
            let today = now.formatterDate(formatter: "yyyy-MM-dd")
            if let beforeTime = Date.date("\(today) \(preDutyTimeBeforeLimit):00"), now.isBefore(date: beforeTime) {
                self.showError(title: "当前时间不在可打卡范围内！")
                return false
            }
        }
        if (!preDutyTimeAfterLimit.isEmpty) {
            let now = Date()
            let today = now.formatterDate(formatter: "yyyy-MM-dd")
            if let afterTime =  Date.date("\(today) \(preDutyTimeAfterLimit):00"), afterTime.isBefore(date: now) {
                self.showError(title: "当前时间不在可打卡范围内！")
                return false
            }
        }
        return true
    }
    
    private func postCheckIn(record: AttendanceV2CheckItemData, workPlaceId: String?, fieldWork: Bool, fieldWorkRemark: String?) {
        self.showLoading()
        let body = AttendanceV2CheckInBody()
        body.recordId = record.id
        body.checkInType = record.checkInType
        body.latitude = String(self.bmkResult?.location.latitude ?? 0.0)
        body.longitude =  String(self.bmkResult?.location.longitude ?? 0.0)
        body.recordAddress = self.bmkResult?.address
        body.workPlaceId = workPlaceId ?? ""
        body.fieldWork = fieldWork
        body.signDescription = fieldWorkRemark ?? ""
        self.viewModel.checkIn(body: body).then { res in
            self.hideLoading()
            self.loadPreCheckData()
        }.catch { error in
            DDLogError("打卡提交失败，\(error.localizedDescription)")
            self.showError(title: "打卡提交失败！\(error.localizedDescription)")
        }
    }
    
    
    
    private func loadPreCheckData() {
        self.viewModel.preCheckIn().then { data in
            // 先处理打卡场所
            self.workPlaceList.removeAll()
            data.workPlaceList.forEach { place in
                self.workPlaceList.append(place)
            }
            // 处理打卡数据展现
            self.canCheckIn = data.canCheckIn ?? false  //今天是否还需要打卡
            self.allowFieldWork = data.allowFieldWork ?? false
            self.requiredFieldWorkRemarks = data.requiredFieldWorkRemarks ?? false
            if self.canCheckIn {
                // 是否最后一条已经打卡过的数据
                self.nextCheckInRecord = data.checkItemList.first(where: { element in
                    return element.checkInResult == "PreCheckIn"
                })
                self.canCheckIn = self.nextCheckInRecord != nil
                self.checkItemList.removeAll()
                data.checkItemList.forEachEnumerated { index, item in
                    var isRecord = false
                    var recordTime = ""
                    if (item.checkInResult != "PreCheckIn") {
                        isRecord = true
                        var signTime = item.recordDate ?? ""
                        if (signTime.length >= 16) {
                            signTime = signTime.subString(from: 11, to: 16)
                        }
                        var status = "已打卡"
                        if (item.checkInResult != "Normal") {
                            status = item.resultText()
                        }
                        recordTime = "\(status) \(signTime)"
                    }
                    item.recordTime = recordTime
                    item.isRecord = isRecord // 是否已经打卡
                    
                    if(item.checkInType == "OnDuty") {
                        item.checkInTypeString = "上班打卡"
                    } else{
                        item.checkInTypeString = "下班打卡"
                    }
                    var preDutyTime = item.preDutyTime
                    if (item.shiftId == nil || item.shiftId?.isEmpty == true) {
                        preDutyTime = "" // 如果没有班次信息 表示 自由工时 或者 休息日 不显示 打卡时间
                    }
                    item.preDutyTime = preDutyTime
                    // 处理是否是最后一个已经打卡的记录
                    if (item.checkInResult != "PreCheckIn") {
                        if (index == data.checkItemList.count - 1) { // 最后一条
                            item.isLastRecord = true // 最后一条已经打卡的记录
                        } else {
                            let nextItem = data.checkItemList[index+1]
                            if (nextItem.checkInResult == "PreCheckIn") {
                                item.isLastRecord = true
                            }
                        }
                    }
                    self.checkItemList.append(item)
                }
            }
            self.setCheckInBtnEnable(self.canCheckIn)
            self.recordItemsCollectionView.reloadData()
        }.catch { error in
            DDLogError(error.localizedDescription)
            self.setCheckInBtnEnable(false)
        }
    }
    
    
    // MARK: - UI
    /// 设置打卡按钮样式
    private func setCheckInBtnEnable(_ enable: Bool) {
        self.canCheckIn = enable
        if enable {
            self.checkInBtn.backgroundColor = base_color
        } else {
            self.checkInBtn.backgroundColor = UIColor(hex: "#cccccc")
        }
    }
    
    ///刷新按钮时间
    @objc private func timeTick() {
        let now = Date().toString("HH:mm:ss")
        DDLogDebug("timeTick ： \(now)")
        self.checkInBtnTime.text = now
    }
    
    
    ///接收到位置信息
    private func locationReceive(bmkResult: BMKReverseGeoCodeSearchResult, isIn: Bool, workPlace: AttendanceV2WorkPlace?) {
        self.isInWorkPlace = isIn
        self.bmkResult = bmkResult
        if isIn {
            self.locationLabel.text = workPlace?.placeName
            self.locationIcon.image = UIImage(named: "icon__ok2_click")
            self.currentWorkPlace = workPlace
        } else {
            self.locationLabel.text = bmkResult.address
            self.locationIcon.image = UIImage(named: "icon_delete_1")
        }
    }
    
    
    // MARK: - 定位
    
    /// 开启定位
    private func startLocationService() {
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




extension AttendanceV2CheckInViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.checkItemList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OOAttendanceScheduleViewCell", for: indexPath) as? OOAttendanceScheduleViewCell {
            let s = self.checkItemList[indexPath.row]
            cell.setDataV2(data: s)
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        DDLogDebug("点击。。。\(indexPath.row)")
        let s = self.checkItemList[indexPath.row]
        if s.isLastRecord == true {
            DDLogDebug("更新打卡。。。。")
            self.updateCheckIn(record: s)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: ((SCREEN_WIDTH - 62) / 2), height: 64)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }

}


extension AttendanceV2CheckInViewController: BMKLocationManagerDelegate {

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

extension AttendanceV2CheckInViewController: BMKGeoCodeSearchDelegate {

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
