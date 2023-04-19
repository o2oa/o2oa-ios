//
//  OOAttendanceAPI.swift
//  O2Platform
//
//  Created by 刘振兴 on 2018/5/16.
//  Copyright © 2018年 zoneland. All rights reserved.
//

import Foundation
import Moya



// MARK:- 所有调用的API枚举
enum OOAttendanceAPI {
    case attendanceDetailCheckIn(OOAttandanceMobileCheckinForm) //打卡
    case myAttendanceDetailMobileByPage(CommonPageModel,OOAttandanceMobileQueryBean) //获取打卡数据
    case myWorkplace //我的打卡地点列表
    case addWorkplace(OOAttandanceNewWorkPlace) //增加打卡地点
    case delWorkplace(String) //删除打卡地点
    case attendanceAdmin //是否可以设置打卡地点
    case checkinCycle(String,String) //考勤周期
    case checkinTotalForMonth(OOAttandanceTotalBean) //考勤统计
    case checkinAnalyze(OOAttandanceTotalBean) //考勤分析
    case listMyRecord //当前用户当前的打卡情况和班次
    case attendancedetailList(AttendanceDetailQueryFilterJson) // 查询打卡记录
    case attendanceAppealInfoList(String, AppealApprovalQueryFilterJson) // 审核数据列表
    case attendanceappealInfoApprovel(AppealApprovalFormJson) // 审核数据
    case submitAppealApprove(String, AttendanceDetailInfoJson) // 申诉
    
    // v2 版本
    case versionCheck
    case v2PreCheckIn
    case v2CheckIn(AttendanceV2CheckInBody)
    case V2MyStatistic(AttendanceV2StatisticBody)
    case v2AppealListByPage(Int, Int, AttendanceV2AppealPageListFilter)
}

// MARK:- 上下文实现
extension OOAttendanceAPI:OOAPIContextCapable {
    var apiContextKey: String {
        return "x_attendance_assemble_control"
    }
}


// MARK: - 是否需要加入x-token访问头
extension OOAttendanceAPI:OOAccessTokenAuthorizable {
    public var shouldAuthorize: Bool {
        return true
    }
}

extension OOAttendanceAPI:TargetType {
    var baseURL: URL {
        let model = O2AuthSDK.shared.o2APIServer(context: .x_attendance_assemble_control)
        let baseURLString = "\(model?.httpProtocol ?? "http")://\(model?.host ?? ""):\(model?.port ?? 80)\(model?.context ?? "")"
        if let trueUrl = O2AuthSDK.shared.bindUnitTransferUrl2Mapping(url: baseURLString) {
            return URL(string: trueUrl)!
        }
        return URL(string: baseURLString)!
    }
    
    var path: String {
        switch self {
        case .addWorkplace(_):
            return "/jaxrs/workplace"
        case .attendanceAdmin:
            return "/jaxrs/attendanceadmin/list/all"
        case .attendanceDetailCheckIn(_):
            return "/jaxrs/attendancedetail/mobile/recive"
        case .delWorkplace(let id):
            return "/jaxrs/workplace/\(id)"
        case .myAttendanceDetailMobileByPage(let model, _):
            return "/jaxrs/attendancedetail/mobile/filter/list/page/1/count/\(model.pageSize)"
        case .myWorkplace:
            return "/jaxrs/workplace/list/all"
        case .checkinCycle(let year, let month):
            return "/jaxrs/attendancestatisticalcycle/cycleDetail/\(year)/\(month)"
        case .checkinTotalForMonth(_):
            return "/jaxrs/attendancedetail/filter/list"
        case .checkinAnalyze(let bean):
            return "/jaxrs/statisticshow/person/\(bean.q_empName!)/\(bean.q_year!)/\(bean.q_month!)"
        case .listMyRecord:
            return "/jaxrs/attendancedetail/mobile/my"
        case .attendancedetailList(_):
            return "/jaxrs/attendancedetail/filter/list/user"
        case .attendanceAppealInfoList(let id, _):
            return "/jaxrs/attendanceappealInfo/filter/list/\(id)/next/\(O2.defaultPageSize)"
        case .attendanceappealInfoApprovel(_):
            return "/jaxrs/attendanceappealInfo/audit"
        case .submitAppealApprove(let id, _):
            return "/jaxrs/attendanceappealInfo/appeal/\(id)"
        // v2 版本
        case .versionCheck:
            return "/jaxrs/v2/my/version"
        case .v2PreCheckIn:
            return "/jaxrs/v2/mobile/check/pre"
        case .v2CheckIn(_):
            return "/jaxrs/v2/mobile/check"
        case .V2MyStatistic(_):
            return "/jaxrs/v2/my/statistic"
        case .v2AppealListByPage(let page, let size, _):
            return "/jaxrs/v2/appeal/list/\(page)/size/\(size)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .addWorkplace(_):
            return .post
        case .attendanceAdmin:
            return .get
        case .attendanceDetailCheckIn(_):
            return .post
        case .delWorkplace(_):
            return .delete
        case .myAttendanceDetailMobileByPage(_, _):
            return .put
        case .myWorkplace:
            return .get
        case .checkinCycle(_, _):
            return .get
        case .checkinTotalForMonth(_):
            return .put
        case .checkinAnalyze(_):
            return .get
        case .listMyRecord:
            return .get
        case .attendancedetailList(_), .attendanceAppealInfoList(_, _), .attendanceappealInfoApprovel(_), .submitAppealApprove(_, _):
            return .put
        // v2 版本
        case .versionCheck, .v2PreCheckIn:
            return .get
        case .v2CheckIn(_), .V2MyStatistic(_), .v2AppealListByPage(_, _, _):
            return .post
        
        }
    }
    
    var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }
    
    var task: Task {
        switch self {
        case .addWorkplace(let bean):
            return .requestParameters(parameters: bean.toJSON() ?? [:], encoding: JSONEncoding.default)
        case .attendanceAdmin:
            return .requestPlain
        case .attendanceDetailCheckIn(let bean):
            return .requestParameters(parameters: bean.toJSON() ?? [:], encoding: JSONEncoding.default)
        case .delWorkplace(_):
            return .requestPlain
        case .myAttendanceDetailMobileByPage(_,let bean):
            return .requestParameters(parameters: bean.toJSON() ?? [:], encoding: JSONEncoding.default)
        case .myWorkplace:
            return .requestPlain
        case .checkinCycle(_,_):
            return .requestPlain
        case .checkinTotalForMonth(let bean):
            return .requestParameters(parameters: bean.toJSON() ?? [:], encoding: JSONEncoding.default)
        case .checkinAnalyze(_):
            return .requestPlain
        case .listMyRecord:
            return .requestPlain
        case .attendancedetailList(let filter):
            return .requestParameters(parameters: filter.toJSON() ?? [:], encoding: JSONEncoding.default)
        case .attendanceAppealInfoList(_, let filter):
            return .requestParameters(parameters: filter.toJSON() ?? [:], encoding: JSONEncoding.default)
        case .attendanceappealInfoApprovel(let form):
            return .requestParameters(parameters: form.toJSON() ?? [:], encoding: JSONEncoding.default)
        case .submitAppealApprove(_, let form):
            return .requestParameters(parameters: form.toJSON() ?? [:], encoding: JSONEncoding.default)
        // v2 版本
        case .versionCheck, .v2PreCheckIn:
            return .requestPlain
        case .v2CheckIn(let form):
            return .requestParameters(parameters: form.toJSON() ?? [:], encoding: JSONEncoding.default)
        case .V2MyStatistic(let form):
            return .requestParameters(parameters: form.toJSON() ?? [:], encoding: JSONEncoding.default)
        case .v2AppealListByPage(_, _, let form):
            return .requestParameters(parameters: form.toJSON() ?? [:], encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
}



