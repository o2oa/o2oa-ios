//
//  OOAttandanceViewModel.swift
//  O2Platform
//
//  Created by 刘振兴 on 2018/5/16.
//  Copyright © 2018年 zoneland. All rights reserved.
//

import Foundation
import Moya
import Promises
import CocoaLumberjack


public enum OOAttandanceResultType {
    case ok(Any?)
    case fail(String)
    case reload
}

public enum OOAttandanceCustomError:Error {
    case checkinCycle(OOAppError)
    case checkinTotal(OOAppError)
}

final class OOAttandanceViewModel: NSObject {
    //HTTP API
    private let ooAttanceAPI = OOMoyaProvider<OOAttendanceAPI>()
    // 流程api
    private let o2ProcessAPI = OOMoyaProvider<OOApplicationAPI>()
    //当天我的所有打卡记录
    private var myAttanceDetailList:[OOAttandanceMobileDetail] = []
    //回调块类型定义
    typealias CallbackBlockDefine = (_ resultType:OOAttandanceResultType) -> Void
    //回调块定义
    var callbackExecutor:CallbackBlockDefine?
    
    override init() {
        super.init()
    }
    
}

extension OOAttandanceViewModel{
    
    //
    func submitAppealApprove(form: AttendanceDetailInfoJson, completedBlock:@escaping CallbackBlockDefine) {
        ooAttanceAPI.request(.submitAppealApprove(form.id!, form)) { response in
            let myResult = OOResult<BaseModelClass<AppealApprovalBackInfoJson>>(response)
            if myResult.isResultSuccess() {
                let records = myResult.model?.data
                completedBlock(.ok(records))
            }else {
                let errorMessage = myResult.error?.errorDescription ?? ""
                completedBlock(.fail(errorMessage))
            }
        }
    }
    
    //考勤审核数据列表
    func attendanceappealInfoApprovel(form: AppealApprovalFormJson, completedBlock:@escaping CallbackBlockDefine) {
        ooAttanceAPI.request(.attendanceappealInfoApprovel(form)) { response in
            let myResult = OOResult<BaseModelClass<AppealApprovalBackInfoJson>>(response)
            if myResult.isResultSuccess() {
                let records = myResult.model?.data
                completedBlock(.ok(records))
            }else {
                let errorMessage = myResult.error?.errorDescription ?? ""
                completedBlock(.fail(errorMessage))
            }
        }
    }
    
    //考勤审核数据列表
    func attendanceAppealInfoList(lastId: String, filter: AppealApprovalQueryFilterJson, completedBlock:@escaping CallbackBlockDefine) {
        ooAttanceAPI.request(.attendanceAppealInfoList(lastId, filter)) { response in
            let myResult = OOResult<BaseModelClass<[AppealInfoJson]>>(response)
            if myResult.isResultSuccess() {
                let records = myResult.model?.data
                completedBlock(.ok(records))
            }else {
                let errorMessage = myResult.error?.errorDescription ?? ""
                completedBlock(.fail(errorMessage))
            }
        }
    }
    
    // 获取打卡list
    func attendancedetailList(filter: AttendanceDetailQueryFilterJson,  completedBlock:@escaping CallbackBlockDefine) {
        ooAttanceAPI.request(.attendancedetailList(filter)) { response in
            let myResult = OOResult<BaseModelClass<[AttendanceDetailInfoJson]>>(response)
            if myResult.isResultSuccess() {
                let records = myResult.model?.data
                completedBlock(.ok(records))
            }else {
                let errorMessage = myResult.error?.errorDescription ?? ""
                completedBlock(.fail(errorMessage))
            }
        }
    }
    
    // MARK: - 当天打卡记录和打卡班次情况
    func listMyRecords(_ completedBlock:@escaping CallbackBlockDefine) {
        ooAttanceAPI.request(.listMyRecord) { response in
            let myResult = OOResult<BaseModelClass<OOMyAttandanceRecords>>(response)
            if myResult.isResultSuccess() {
                let records = myResult.model?.data
                completedBlock(.ok(records))
            }else {
                let errorMessage = myResult.error?.errorDescription ?? ""
                completedBlock(.fail(errorMessage))
            }
        }
    }
    
    // MARK:- 读取配置的打卡位置
    func getLocationWorkPlace(_ completedBlock:@escaping CallbackBlockDefine) {
        ooAttanceAPI.request(.myWorkplace) { (responseResult) in
            let myResult = OOResult<BaseModelClass<[OOAttandanceWorkPlace]>>(responseResult)
            if myResult.isResultSuccess() {
                let workPlaces = myResult.model?.data ?? []
                completedBlock(.ok(workPlaces))
            }else{
                let errorMessage = myResult.error?.errorDescription ?? ""
                completedBlock(.fail(errorMessage))
            }
        }
    }
    
    // MARK:- 删除配置
    func deleteLocationWorkPlace(_ bean:OOAttandanceWorkPlace,_ completedBlock:@escaping CallbackBlockDefine) {
        ooAttanceAPI.request(.delWorkplace(bean.id!)) { (responseResult) in
            let myResult = OOResult<BaseModelClass<OOCommonModel>>(responseResult)
            if myResult.isResultSuccess() {
                completedBlock(.reload)
            }else{
                let errorMessage = myResult.error?.errorDescription ?? ""
                completedBlock(.fail(errorMessage))
            }
        }
    }
    // MARK:- 检测
    // MARK:- 读取本人当天的打卡记录
    func getMyCheckinList(_ pageModel:CommonPageModel,_ bean:OOAttandanceMobileQueryBean,_ completedBlock:@escaping CallbackBlockDefine) {
        myAttanceDetailList.removeAll()
        ooAttanceAPI.request(.myAttendanceDetailMobileByPage(pageModel, bean)) { (responseResult) in
            let myResult = OOResult<BaseModelClass<[OOAttandanceMobileDetail]>>(responseResult)
            if myResult.isResultSuccess() {
                self.myAttanceDetailList.append(contentsOf: myResult.model?.data ?? [])
                completedBlock(.reload)
            }else{
                let errorMessage = myResult.error?.errorDescription ?? ""
                completedBlock(.fail(errorMessage))
            }
        }
    }
    
    
    // MARK:- 提交打卡
    func postMyCheckin(_ bean:OOAttandanceMobileCheckinForm,completedBlock:@escaping CallbackBlockDefine) {
        ooAttanceAPI.request(.attendanceDetailCheckIn(bean)) { (responseResult) in
            let myResult = OOResult<BaseModelClass<[OOAttandanceMobileDetail]>>(responseResult)
            if myResult.isResultSuccess() {
                completedBlock(.ok(nil))
            }else{
                let errorMessage = myResult.error?.errorDescription ?? ""
                completedBlock(.fail(errorMessage))
            }
        }
    }
    
    //MARK:- 提交位置
    func postCheckinLocation(_ bean:OOAttandanceNewWorkPlace,completedBlock:@escaping CallbackBlockDefine){
        ooAttanceAPI.request(.addWorkplace(bean)) { (responseResult) in
            let myResult = OOResult<BaseModelClass<OOCommonModel>>(responseResult)
            if myResult.isResultSuccess() {
                completedBlock(.ok(nil))
            }else{
                let errorMessage = myResult.error?.errorDescription ?? ""
                completedBlock(.fail(errorMessage))
            }
        }
    }
    
    // MARK:- 读取打卡周期
    func getCheckinCycle(_ year:String,_ month:String) -> Promise<OOAttandanceCycleDetail> {
        return Promise { fulfill,reject in
            self.ooAttanceAPI.request(.checkinCycle(year, month), completion: { (result) in
                let myResult = OOResult<BaseModelClass<OOAttandanceCycleDetail>>(result)
                if myResult.isResultSuccess() {
                    fulfill((myResult.model?.data!)!)
                }else{
                    reject(myResult.error!)
                }
            })
            
        }
    }
    
    // MARK:- 读取指定月份及及本月打卡周期的所有打统统计数据
    func getCheckinTotal(_ cycleDetail:OOAttandanceCycleDetail) -> Promise<[OOAttandanceCheckinTotal]> {
       let bean = getRequestBean(cycleDetail)
        return Promise { fulfill,reject in
            self.ooAttanceAPI.request(.checkinTotalForMonth(bean), completion: { (result) in
                let myResult = OOResult<BaseModelClass<[OOAttandanceCheckinTotal]>>(result)
                if myResult.isResultSuccess() {
                    fulfill((myResult.model?.data!)!)
                }else{
                    reject(myResult.error!)
                }
            })
            
        }
    }
    
    private func getRequestBean(_ cycleDetail:OOAttandanceCycleDetail) -> OOAttandanceTotalBean {
        let bean = OOAttandanceTotalBean()
        bean.q_year = cycleDetail.cycleYear
        bean.q_month = cycleDetail.cycleMonth
        bean.cycleYear = cycleDetail.cycleYear
        bean.cycleMonth = cycleDetail.cycleMonth
        bean.q_empName = O2AuthSDK.shared.myInfo()?.distinguishedName
        return bean
    }
    
    // MARK:- 读取考勤分析数据
    func getCheckinAnalyze(_ cycleDetail:OOAttandanceCycleDetail) -> Promise<OOAttandanceAnalyze?>{
        let bean = getRequestBean(cycleDetail)
        return Promise { fulfill,reject in
            self.ooAttanceAPI.request(.checkinAnalyze(bean)) { (result) in
                let myResult = OOResult<BaseModelClass<[OOAttandanceAnalyze]>>(result)
                if myResult.isResultSuccess() {
                    if let data =  myResult.model?.data {
                        fulfill((data.first)!)
                    }else{
//                        reject(OOAppError.common(type: "checkinError", message: "本月无考勤数据", statusCode: 5001))
                        fulfill(nil)
                    }
                }else{
                    //let errorMessage = myResult.error?.errorDescription
                    reject(myResult.error!)
                }
            }
        }
    }
    
    // MARK:- 读取配置管理员
    func getAttendanceAdmin() -> Promise<[OOAttandanceAdmin]> {
        return Promise { fulfill,reject in
            self.ooAttanceAPI.request(.attendanceAdmin, completion: { (result) in
                let myResult = OOResult<BaseModelClass<[OOAttandanceAdmin]>>(result)
                if myResult.isResultSuccess() {
                    if let data =  myResult.model?.data {
                        fulfill(data)
                    }else{
                        reject(OOAppError.common(type: "checkinError", message: "没有配置管理员", statusCode: 5002))
                    }
                }else{
                    //let errorMessage = myResult.error?.errorDescription
                    reject(myResult.error!)
                }
            })
            
        }
    }
    
    
    // MARK: - V2
    // 检查版本
    func checkVersion(_ completedBlock:@escaping ((OOAttendanceV2Version?) -> Void)) {
        ooAttanceAPI.request(.versionCheck) { response in
            let myResult = OOResult<BaseModelClass<OOAttendanceV2Version>>(response)
            if myResult.isResultSuccess() {
                let version = myResult.model?.data
                completedBlock(version)
            }else {
                let errorMessage = myResult.error?.errorDescription ?? ""
                DDLogError("检查错误： \(errorMessage)")
                completedBlock(nil)
            }
        }
    }
    // 预打卡数据 打开打卡页面的时候请求
    func preCheckIn() -> Promise<AttendanceV2PreCheckData>   {
        return Promise { fulfill,reject in
            self.ooAttanceAPI.request(.v2PreCheckIn) { result in
                let res = OOResult<BaseModelClass<AttendanceV2PreCheckData>>(result)
                if res.isResultSuccess()  {
                    if let data =  res.model?.data {
                        fulfill(data)
                    }else{
                        reject(OOAppError.common(type: "checkinError", message: "获取打卡数据异常！", statusCode: 5002))
                    }
                } else {
                    reject(res.error!)
                }
            }
        }
    }
    // 打卡
    func checkIn(body: AttendanceV2CheckInBody) -> Promise<AttendanceV2CheckResponse> {
        return Promise { fulfill, reject in
            self.ooAttanceAPI.request(.v2CheckIn(body)) { result in
                let myResult = OOResult<BaseModelClass<AttendanceV2CheckResponse>>(result)
                if myResult.isResultSuccess() {
                    if let data =  myResult.model?.data {
                        fulfill(data)
                    }else{
                        reject(OOAppError.common(type: "checkinError", message: "打卡失败！", statusCode: 5002))
                    }
                }else{
                    reject(myResult.error!)
                }
            }
        }
    }
    
    // 我的统计页面数据 查询当前一个月的统计数据
    func myStatistic() -> Promise<AttendanceV2StatisticResponse> {
        return Promise { fulfill, reject in
            let body = AttendanceV2StatisticBody()
            let currentDate = Date()
            body.startDate = currentDate.firstDayInThisMonth.formatterDate(formatter: "yyyy-MM-dd")
            body.endDate = currentDate.lastDayInThisMonth.formatterDate(formatter: "yyyy-MM-dd")

            self.ooAttanceAPI.request(.V2MyStatistic(body)) { result in
                let myResult = OOResult<BaseModelClass<AttendanceV2StatisticResponse>>(result)
                if myResult.isResultSuccess() {
                    if let data =  myResult.model?.data {
                        fulfill(data)
                    }else{
                        reject(OOAppError.common(type: "statisticError", message: "获取统计信息失败！", statusCode: 5002))
                    }
                }else{
                    reject(myResult.error!)
                }
            }
        }
    }
    /// 分页查询打卡异常数据
    func appealListByPage(page: Int) -> Promise<[AttendanceV2AppealInfo]> {
        return Promise{ fulfill, reject in
            self.ooAttanceAPI.request(.v2AppealListByPage(page, O2.defaultPageSize, AttendanceV2AppealPageListFilter())) { result in
                let myResult = OOResult<BaseModelClass<[AttendanceV2AppealInfo]>>(result)
                if myResult.isResultSuccess() {
                    if let data =  myResult.model?.data {
                        fulfill(data)
                    }else{
                        reject(OOAppError.common(type: "appealListError", message: "获取打卡异常数据失败！", statusCode: 5002))
                    }
                }else{
                    reject(myResult.error!)
                }
            }
        }
    }
    
    /// 查询考勤配置文件
    func v2Config() -> Promise<AttendanceV2Config> {
        return Promise { fulfill, reject in
            self.ooAttanceAPI.request(.v2Config) { result in
                let myResult = OOResult<BaseModelClass<AttendanceV2Config>>(result)
                if myResult.isResultSuccess() {
                    if let data =  myResult.model?.data {
                        fulfill(data)
                    }else{
                        reject(OOAppError.common(type: "configError", message: "获取配置文件失败！", statusCode: 5002))
                    }
                }else{
                    reject(myResult.error!)
                }
            }
        }
    }
    /// 检查是否能够启动流程 有可能申诉次数超过限制了
    func appealCheckCanStartProcess(id: String) -> Promise<OOCommonValueBoolModel> {
        return Promise { fulfill, reject in
            self.ooAttanceAPI.request(.v2CheckAppeal(id)) { result in
                let myResult = OOResult<BaseModelClass<OOCommonValueBoolModel>>(result)
                if myResult.isResultSuccess() {
                    if let data =  myResult.model?.data {
                        fulfill(data)
                    }else{
                        reject(OOAppError.common(type: "appealError", message: "申请申诉失败！", statusCode: 5002))
                    }
                }else{
                    reject(myResult.error!)
                }
            }
        }
    }
    /// 申诉流程启动后 修改状态
    func appealStartProcess(id: String, jobId:String) -> Promise<OOCommonValueBoolModel> {
        return Promise { fulfill, reject in
            let body = OOAttandanceV2StartProcessBody()
            body.job = jobId
            self.ooAttanceAPI.request(.v2AppealStartProcess(id, body)) { result in
                let myResult = OOResult<BaseModelClass<OOCommonValueBoolModel>>(result)
                if myResult.isResultSuccess() {
                    if let data =  myResult.model?.data {
                        fulfill(data)
                    }else{
                        reject(OOAppError.common(type: "appealError", message: "申请申诉失败！", statusCode: 5002))
                    }
                }else{
                    reject(myResult.error!)
                }
            }
        }
    }
    
    /// 申诉流程对应的身份信息
    func loadAppealProcessAvailableIdentity(processId: String) -> Promise<[OOMeetingProcessIdentity]> {
        return Promise { fulfill, reject in
            self.o2ProcessAPI.request(.availableIdentityWithProcess(processId), completion: { (result) in
                let myResult = OOResult<BaseModelClass<[OOMeetingProcessIdentity]>>(result)
                if myResult.isResultSuccess() {
                    if let item = myResult.model?.data {
                        fulfill(item)
                    }else{
                        let customError = OOAppError.common(type: "appealError", message: "流程身份读取错误！", statusCode: 7001)
                        reject(customError)
                    }
                }else{
                    reject(myResult.error!)
                }
            })
        }
    }
    
    /// 启动申诉流程
    func startProcess(processId: String, identity: String, processData: AttendanceV2AppealInfoToProcessData) -> Promise<StartProcessData> {
        return Promise { fulfill, reject in
            self.o2ProcessAPI.request(.startProcess(processId, identity, "", processData.toJSON() ?? [:]), completion: { (result) in
                let myResult = OOResult<BaseModelClass<[StartProcessData]>>(result)
                if myResult.isResultSuccess() {
                     if let item = myResult.model?.data, item.count > 0 {
                         fulfill(item[0])
                     } else {
                         reject(OOAppError.apiEmptyResultError)
                    }
                } else {
                     reject(myResult.error!)
                }
            })
        }
    }
    /// 根据job查询工作列表
    func loadWorkByJob(jobId: String) -> Promise<WorkOrWorkcompleted> {
        return Promise { fulfill, reject in
            self.o2ProcessAPI.request(.workOrWorkcompletedByJob(jobId)) { result in
                let myResult = OOResult<BaseModelClass<WorkOrWorkcompleted>>(result)
                if myResult.isResultSuccess() {
                     if let item = myResult.model?.data {
                         fulfill(item)
                     } else {
                         let customError = OOAppError.common(type: "processError", message: "job读取工作错误！", statusCode: 7001)
                         reject(customError)
                    }
                } else {
                     reject(myResult.error!)
                }
            }
        }
    }
    
    
}


// MARK:- UITableView DataSource
extension OOAttandanceViewModel {
    func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        return myAttanceDetailList.count
    }
    
    func nodeForIndexPath(_ indexPath:IndexPath) -> OOAttandanceMobileDetail? {
        return myAttanceDetailList[indexPath.row]
    }
    
    
    
}

