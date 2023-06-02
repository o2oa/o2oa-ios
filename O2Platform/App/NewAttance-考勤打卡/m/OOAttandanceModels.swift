//
//  OOAttandanceModels.swift
//  O2Platform
//
//  Created by 刘振兴 on 2018/5/16.
//  Copyright © 2018年 zoneland. All rights reserved.
//

import Foundation
import HandyJSON




// MARK: - V2

//版本检查
class OOAttendanceV2Version: NSObject, DataModel {
   
    @objc var version:String?
    
    required override init() {
        
    }
}

// 打卡记录
class AttendanceV2CheckItemData: NSObject, DataModel {
    @objc  var id: String?
    @objc var userId: String?
    @objc  var recordDateString: String?
    @objc  var recordDate: String?
    @objc var preDutyTime: String?
    @objc var preDutyTimeBeforeLimit: String?
    @objc  var preDutyTimeAfterLimit: String?
    @objc var sourceType: String?
    @objc  var checkInResult: String?
    @objc var checkInType: String?
    @objc  var sourceDevice: String?
    @objc  var desc: String?
    @objc var groupId: String?
    @objc  var groupName: String?
    @objc var groupCheckType: String? // 考勤组的类型，1：固定班制
    @objc var shiftId: String?
    @objc var shiftName: String?
    var fieldWork: Bool = false
   

    // 是否最后一条已经打卡过的数据
    var isLastRecord: Bool = false
    var isRecord: Bool = false
    @objc var recordTime: String? // 已打卡的显示内容
    @objc var checkInTypeString: String? // 打卡类型
    
    override required init() {
        
    }
    func mapping(mapper: HelpingMapper) {
        mapper <<< self.desc <-- "description"
    }
    
    
    func resultText()-> String {
        if self.checkInResult == "Normal" {
            return "正常"
        } else if self.checkInResult == "Early" {
            return "早退"
        } else if self.checkInResult == "Late" {
            return "迟到"
        } else if self.checkInResult == "SeriousLate" {
            return "严重迟到"
        } else if self.checkInResult == "Absenteeism" {
            return "旷工迟到"
        } else if self.checkInResult == "NotSigned" {
            return "未打卡"
        } else {
            return ""
        }
    }
    
    func resultTextColor() -> UIColor {
        if self.fieldWork == true {
            return UIColor(hex: "#E233FF")
        } else {
            if self.checkInResult == "Normal" {
                return UIColor(hex: "#4A90E2")
            } else if self.checkInResult == "Early" {
                return UIColor(hex: "#8B572A")
            } else if self.checkInResult == "Late" {
                return UIColor(hex: "#F5A623")
            } else if self.checkInResult == "SeriousLate" {
                return UIColor(hex: "#FF8080")
            }else if self.checkInResult == "NotSigned" {
                return UIColor(hex: "#fb4747")
            } else {
                return  UIColor(hex: "#4A90E2")
            }
        }
    }
}
// 工作场所
class AttendanceV2WorkPlace: NSObject, DataModel {
    @objc var id: String?
    @objc  var placeName: String?
    @objc  var placeAlias: String?
    @objc  var creator: String?
    @objc  var longitude: String?
    @objc  var latitude: String?
    var errorRange: Int?
    @objc  var desc: String?
    override required init() {
        
    }
    func mapping(mapper: HelpingMapper) {
        mapper <<< self.desc <-- "description"
    }

}
// 预打卡记录
class AttendanceV2PreCheckData: NSObject, DataModel {
    var allowFieldWork:Bool? 
    var requiredFieldWorkRemarks: Bool?
    var canCheckIn: Bool?
    @objc var checkItemList: [AttendanceV2CheckItemData] = []
    @objc var workPlaceList: [AttendanceV2WorkPlace] = []
    override required init() {
        
    }
}

// 打卡提交对象
class AttendanceV2CheckInBody: NSObject, DataModel {
    @objc var recordId: String?
    @objc var checkInType: String?
    @objc  var workPlaceId: String?
    var fieldWork: Bool? // 是否外勤打卡
    @objc var signDescription: String? //打卡说明:上班打卡，下班打卡, 可以为空.
    @objc var sourceDevice: String? //操作设备类别：Mac|Windows|IOS|Android|其他, 可以为空.
    @objc  var recordAddress: String? //打卡地点描述, 可以为空.
    @objc var longitude: String? //经度
    @objc var latitude: String? //纬度
    @objc var sourceType: String = "USER_CHECK" // FAST_CHECK
    
    override required init() {
        
    }
}
// 打卡返回结果
class AttendanceV2CheckResponse: NSObject, DataModel {
    @objc var checkInRecordId: String?
    @objc   var checkInResult: String?
    @objc  var recordDate: String?
    override required init() {
        
    }
}
// 统计查询提交对象
class AttendanceV2StatisticBody: NSObject, DataModel {
    @objc var startDate: String? // 开始日期 yyyy-MM-dd
    @objc var endDate: String? // 结束日期 yyyy-MM-dd
    
    override required init() {
        
    }
}
// 统计查询返回对象
class AttendanceV2StatisticResponse: NSObject, DataModel {
    @objc var userId: String?
    var workTimeDuration: Int = 0
    @objc var averageWorkTimeDuration: String = "0.0"
    var attendance: Int = 0
    var rest: Int = 0
    var absenteeismDays: Int = 0
    var lateTimes: Int = 0
    var leaveEarlierTimes: Int = 0
    var absenceTimes: Int = 0
    var fieldWorkTimes: Int = 0
    var leaveDays: Int = 0
    var appealNums: Int = 0
    
    override required init() {
        
    }
}

class AttendanceV2AppealPageListFilter: NSObject, DataModel {
    @objc var recordDate: String = ""
    override required init() {
        
    }
}

// 打卡异常信息对象
class AttendanceV2AppealInfo: NSObject, DataModel {

    @objc var id: String = ""
    @objc var recordId: String = ""
    @objc var userId: String = ""
    @objc var recordDateString: String = ""
    @objc var recordDate: String = ""
    @objc var startTime: String = ""
    @objc var endTime: String = ""
    @objc var reason: String = ""

//public static final Integer status_TYPE_INIT = 0; // 待处理
//public static final Integer status_TYPE_PROCESSING = 1; // 审批中
//public static final Integer status_TYPE_PROCESS_AGREE = 2; // 审批通过
//public static final Integer status_TYPE_PROCESS_DISAGREE = 3; // 审批不通过
    var status: Int = 0
    @objc var jobId: String = ""
    @objc var record: AttendanceV2CheckItemData?
    
    override required init() {
        
    }
 

    func statsText() -> String {
        switch status {
        case 0:
            return "待处理"
        case 1:
            return "流转中"
        case 2:
            return "审批通过"
        case 3:
            return "审批不通过"
        default:
            return ""
        }
    }

}

/// 配置文件
class AttendanceV2Config: NSObject, DataModel {
    var holidayList: [String] = []
        var workDayList: [String] = []
        var appealEnable: Bool  = false
        var appealMaxTimes: Int = 0
    @objc var processId: String = ""
    @objc var processName: String = ""
        var onDutyFastCheckInEnable: Bool = false
        var offDutyFastCheckInEnable: Bool = false
        var checkInAlertEnable: Bool = false
        var exceptionAlertEnable: Bool = false
    override required init() {
        
    }
}
/// 启动流程的时候提交给流程的 data 数据
class AttendanceV2AppealInfoToProcessData: NSObject, DataModel {
    @objc var appealId: String = ""
              @objc var record: AttendanceV2CheckItemData?
    override required init() {
        
    }
}
/// 启动流程后 更新考勤异常数据传递 job 字段
class OOAttandanceV2StartProcessBody: NSObject, DataModel {
    @objc var job: String = ""
    override required init() {
        
    }
}




// MARK:- 移动端获到打卡记录Bean
class OOAttandanceMobileQueryBean:NSObject,DataModel {
    
    @objc var empNo:String? //员工号，根据员工号查询记录
    
    @objc var empName:String? //员工姓名，根据员工姓名查询记录.
    
    @objc var startDate:String? //开始日期：yyyy-mm-dd.
    
    @objc var endDate:String? //结束日期：yyyy-mm-dd,如果开始日期填写，结束日期不填写就是只查询开始日期那一天
    
    @objc var signDescription:String? //打卡说明:上班打卡，下班打卡.
    
    override required init() {
        
    }
}



// MARK:- 移动端打卡数据
class OOAttandanceMobileDetail:NSObject,DataModel {

    @objc var id:String? //数据库主键,自动生成.
    @objc var createTime:String? //创建时间,自动生成.
    @objc var updateTime:String? //修改时间,自动生成.
    @objc var empNo:String? //员工号
    @objc var empName:String? //员工姓名
    @objc var recordDateString:String? //打卡记录日期字符串
    @objc var recordDate:String? //打卡记录日期
    @objc var signTime:String? //打卡时间
    @objc var signDescription:String? //打卡说明
    @objc var desc:String? //其他说明备注
    @objc var recordAddress:String?  //打卡地点描述
    @objc var longitude:String? //经度
    @objc var latitude:String?  //纬度
    @objc var optMachineType:String? // 操作设备类别：手机品牌|PAD|PC|其他
    @objc var optSystemName:String?  // 操作设备类别：Mac|Windows|IOS|Android|其他
    var recordStatus:Int?  //记录状态：0-未分析 1-已分析
    @objc var checkin_type: String? // 打卡类型 上午上班打卡 下午下班打卡
    
    required override init() {
        
    }
    
    func mapping(mapper: HelpingMapper) {
        mapper <<< self.desc <-- "description"
    }

}

// MARK: - 打卡班次对象
class OOAttandanceScheduleSetting: NSObject, DataModel {
    /**
     "id": "7c89ddfe-7e69-40ce-9908-d699081aa660",
                "topUnitName": "浙江兰德纵横网络技术股份有限公司@1@U",
                "unitName": "移动开发组@320494093@U",
                "unitOu": "移动开发组@320494093@U",
                "onDutyTime": "09:00",
                "offDutyTime": "17:00",
                "signProxy": 0,
                "lateStartTime": "9:05",
                "createTime": "2020-05-27 09:19:16",
                "updateTime": "2020-05-27 09:19:16"
     */
    @objc var id: String?
    @objc var topUnitName: String?
    @objc var unitName: String?
    @objc var unitOu: String?
    @objc var onDutyTime: String?
    @objc var offDutyTime: String?
    var signProxy: Int?
    @objc var lateStartTime: String?
    @objc var createTime: String?
    @objc var updateTime: String?
    
    required override init() {
        
    }
    
}

// MARK: - 当前用户当天打卡功能
class OOAttandanceFeature: NSObject, DataModel {
    /**
     "signSeq": 1,
     "signDate": "2020-06-02",
     "signTime": "09:00",
     "checkinType": "上午上班打卡"
     */
    @objc var signDate: String?
    @objc var signTime: String?
    @objc var checkinType: String?
    var signSeq: Int? //第几次打卡 -1就不能打卡了
    
    required override init() {
        
    }
    
}

// MARK: - 打卡班次对象 和 打卡结果拼接的结果
class OOAttandanceMobileScheduleInfo: NSObject, DataModel {
    @objc var signDate: String?
    @objc var signTime: String?
    @objc var checkinType: String?
    var signSeq: Int?
    @objc var checkinStatus: String? // 未打卡 已打卡
    @objc var checkinTime: String? //打卡时间
    @objc var recordId: String? //打卡结果的id 更新打卡用
    
    required override init() {
        
    }
    
}

// MARK: - MyRecords 登录者当天的所有移动打卡信息记录 排版情况等
class OOMyAttandanceRecords: NSObject, DataModel {
   
    @objc var records:[OOAttandanceMobileDetail]?
    @objc var scheduleSetting:OOAttandanceScheduleSetting?
    @objc var feature: OOAttandanceFeature?
    //2020-07-21 新添加的
    @objc var scheduleInfos: [OOAttandanceFeature]?
    
    required override init() {
        
    }
}

// MARK:- 提交打卡数据FormBean
class OOAttandanceMobileCheckinForm:NSObject,DataModel {
    
    @objc var id:String? //id 为空就是新增 有id就是更新
    
    @objc var empNo:String? //员工号, 可以为空.
    
    @objc var empName:String? //员工姓名, 必须填写.
    
    @objc var recordDateString:String? //打卡记录日期字符串：yyyy-mm-dd, 必须填写.
    
    @objc var signTime:String? //打卡时间: hh24:mi:ss, 必须填写.
    
    @objc var signDescription:String? //打卡说明:上班打卡，下班打卡, 可以为空.
    
    @objc var desc:String? //其他说明备注, 可以为空.
    
    @objc var recordAddress:String? //打卡地点描述, 可以为空.
    
    @objc var longitude:String? //经度, 可以为空.
    
    @objc var latitude:String? //纬度, 可以为空.
    
    @objc var optMachineType:String? //操作设备类别：手机品牌|PAD|PC|其他, 可以为空.
    
    @objc var optSystemName:String? //操作设备类别：Mac|Windows|IOS|Android|其他, 可以为空
    
    @objc var checkin_type: String? //上午上班打卡 下午下班打卡 。。。。 对应OOAttandanceFeature里面的checkinType
    
    var isExternal: Bool? // 是否外勤打卡
    
    @objc var workAddress: String? // 当前打卡的工作地点
    
    required override init() {
        
    }
    
    func mapping(mapper: HelpingMapper) {
        mapper <<< self.desc <-- "description"
    }
}

// MARK:- 打卡地点配置
class OOAttandanceWorkPlace:NSObject,DataModel{
    
    @objc var desc: String?
    @objc var id:String? // 数据库主键,自动生成.
    @objc var createTime:String?  //   创建时间,自动生成.
    @objc var updateTime:String?  // 修改时间,自动生成.
    @objc var placeName:String?   // 场所名称
    @objc var placeAlias:String?  // 场所别名
    @objc var creator:String?    // 创建人
    @objc var longitude:String?  //  经度
    @objc var latitude:String?   //  纬度
    var errorRange:Int? //   误差范围
    
    required override init() {
        
    }
    
    func mapping(mapper: HelpingMapper) {
        mapper <<< self.desc <-- "description"
    }
}

// MARK:- 提交新的打卡地点
class OOAttandanceNewWorkPlace:NSObject,DataModel {
    
    @objc var placeName:String? //场所名称
    
    @objc var placeAlias:String? //场所别名
    
    @objc var creator:String? //创建人
    
    @objc var longitude:String? //经度
    
    @objc var latitude:String? //纬度
    
    @objc var errorRange:String? //误差范围
    
    @objc var desc:String? //说明备注
    
    required override init() {
        
    }
    
    func mapping(mapper: HelpingMapper) {
        mapper <<< self.desc <-- "description"
    }
}

// MARK:- 考勤配置管理员
class OOAttandanceAdmin:NSObject,DataModel {
    @objc var desc: String?
    @objc var id:String? //   数据库主键,自动生成.
    @objc var createTime:String? //   创建时间,自动生成.
    @objc var updateTime:String? //    修改时间,自动生成.
    @objc var unitName:String? //    组织名称
    @objc var unitOu:String?  //    组织编号
    @objc var adminName:String? //    管理员姓名
    @objc var adminLevel:String? //    管理级别:UNIT|TOPUNIT
    required override init() {
        
    }
    
    func mapping(mapper: HelpingMapper) {
        mapper <<< self.desc <-- "description"
    }
    
}

class OOAttandanceTotalBean:NSObject,DataModel {
    @objc var q_year:String? //  : 打卡年份
    @objc var q_month:String? // : 打卡月份
    @objc var cycleYear:String? // : 考勤周期年份
    @objc var cycleMonth:String? // : 考勤周期月份
    @objc var q_empName:String? //：人员全名
    
    required override init() {
        
    }
}


// MARK:- cycleDetail
class OOAttandanceCycleDetail:NSObject,DataModel {
    @objc var id:String? //: "ea55970a-bd18-4388-a40b-b0cc7d6cc576",
    @objc var createTime:String? //: "2018-04-12 12:49:37",
    @objc var updateTime:String? //: "2018-04-12 12:49:37",
    @objc var topUnitName:String? //": "*",
    @objc var unitName:String? //: "*",
    @objc var cycleYear:String? //: "2018",
    @objc var cycleMonth:String? //: "04",
    @objc var cycleStartDateString:String? //: "2018-04-01",
    @objc var cycleEndDateString:String? //: "2018-05-01",
    @objc var cycleStartDate:String? //: "2018-04-01",
    @objc var cycleEndDate:String? //: "2018-05-01",
    @objc var desc:String? //: "系统自动创建"
    
    required override init() {
        
    }
    
    func mapping(mapper: HelpingMapper) {
        mapper <<< self.desc <-- "description"
    }
}

// MARK:- OOAttandanceCheckinTotal
class OOAttandanceCheckinTotal:NSObject,DataModel {
    @objc var abnormalDutyDayTime : String?
    var absence : Int?
    @objc var absentDayTime : String?
    @objc var appealDescription : String?
    @objc var appealProcessor : String?
    @objc var appealReason : String?
    var appealStatus : Int?
    var attendance : Int?
    @objc var batchName : String?
    @objc var createTime : String?
    @objc var cycleMonth : String?
    @objc var cycleYear : String?
    @objc var descriptionField : String?
    @objc var empName : String?
    @objc var empNo : String?
    var getSelfHolidayDays : Int?
    @objc var id : String?
    var isAbnormalDuty : Bool?
    var isAbsent : Bool?
    var isGetSelfHolidays : Bool?
    var isHoliday : Bool?
    var isLackOfTime : Bool?
    var isLate : Bool?
    var isLeaveEarlier : Bool?
    var isWeekend : Bool?
    var isWorkOvertime : Bool?
    var isWorkday : Bool?
    var lateTimeDuration : Int?
    var leaveEarlierTimeDuration : Int?
    @objc var monthString : String?
    @objc var offDutyTime : String?
    @objc var offWorkTime : String?
    @objc var onDutyTime : String?
    @objc var onWorkTime : String?
    @objc var recordDate : String?
    @objc var recordDateString : String?
    var recordStatus : Int?
    @objc var selfHolidayDayTime : String?
    @objc var topUnitName : String?
    @objc var unitName : String?
    @objc var updateTime : String?
    var workOvertimeTimeDuration : Int?
    var workTimeDuration : Int?
    @objc var yearString : String?
    
    
    required override init() {
        
    }
}

// MARK:- 考勤统计分析model
class OOAttandanceAnalyze:NSObject,DataModel {
    var abNormalDutyCount : Int?
    var absenceDayCount : Int?
    @objc var createTime : String?
    @objc var employeeName : String?
    @objc var id : String?
    var lackOfTimeCount : Int?
    var lateTimes : Int?
    var leaveEarlyTimes : Int?
    var offDutyTimes : Int?
    var onDutyDayCount : Int?
    var onDutyTimes : Int?
    var onSelfHolidayCount : Int?
    @objc var statisticMonth : String?
    @objc var statisticYear : String?
    @objc var topUnitName : String?
    @objc var unitName : String?
    @objc var updateTime : String?
    var workDayCount : Int?
    
    required override init() {
        
    }
}

// 考勤打卡信息查询对象
class AttendanceDetailQueryFilterJson:NSObject,DataModel {
    @objc var cycleYear:  String?//年份 如 2016
    @objc var cycleMonth:  String? //月份 如 04
    @objc var key:  String? //recordDateString
    @objc  var order:  String?//排序 desc asc
    @objc var q_empName:  String?//当前用户
    required override init() {
        
    }
}

/**
 * 查询审批的过滤条件
 */

class AppealApprovalQueryFilterJson:NSObject,DataModel {
    @objc var status: String? // 0待审批 1审批通过 -1审批未通过 999所有
    @objc var yearString: String?//年份 2016
    @objc var monthString: String?
    @objc var processPerson1: String? //审批人 就是当前用户
    @objc var appealReason: String?
    @objc var departmentName: String?
    @objc var empName: String?
    
    required override init() {
        
    }
}


/**
 * 考勤详细信息
 */
class AttendanceDetailInfoJson :NSObject,DataModel {
    @objc var id:   String?
    @objc var createTime:   String?
    @objc var updateTime:   String?
    @objc var sequence:   String?
    @objc var empNo:   String?
    @objc var empName:   String?
    @objc var companyName:   String?
    @objc var departmentName:   String?
    @objc var yearString:   String?
    @objc var monthString:   String?
    @objc var recordDateString:   String?
    @objc var recordDate:   String?
    @objc var cycleYear:   String?
    @objc var cycleMonth:   String?
        var isHoliday: Bool?
        var isWorkday: Bool?
        var isGetSelfHolidays: Bool?
    @objc var selfHolidayDayTime:   String?
    @objc var absentDayTime:   String?
    @objc var abnormalDutyDayTime:   String?
        var getSelfHolidayDays: Double?
        var isWeekend: Bool?
    @objc var onWorkTime:   String?
    @objc var offWorkTime:   String?
    @objc var onDutyTime:   String?
    @objc var offDutyTime:   String?
        var isLate: Bool?
        var lateTimeDuration: Int?
        var isLeaveEarlier: Bool?
        var leaveEarlierTimeDuration: Int?
        var isAbsent: Bool?
        var isAbnormalDuty: Bool?
        var isLackOfTime: Bool?
        var isWorkOvertime: Bool?
        var workOvertimeTimeDuration: Int?
        var workTimeDuration: Int?
        var attendance: Double?
        var absence: Double?
        var recordStatus: Int?
    @objc var batchName:   String?
//    @objc var description:   String?
        //申诉相关信息
    @objc var identity:   String? //多身份的时候选择的身份dn
        var appealStatus: Int? //申诉状态:0-未申诉，1-申诉中，-1-申诉未通过，9-申诉通过
    @objc var appealReason:   String? //原因  临时请假  出差 因公外出 其他
    @objc var appealDescription:   String? //事由
    @objc var selfHolidayType:   String? //如果原因是临时请假 这里需要选择一个请假类型 ：带薪年休假 带薪病假 带薪福利假 扣薪事假 其他
    @objc var address:   String? //外出地址
    @objc var startTime:   String? // yyyy-MM-dd HH:mm
    @objc var endTime:   String? // yyyy-MM-dd HH:mm
    @objc var appealProcessor:   String?//申诉审批人
    @objc var processPerson1 :  String?// 审批人一
    
    required override init() {
        
    }
        }



/**
 * 申诉对象
 */
class AppealInfoJson:NSObject,DataModel {
    @objc var id: String?
    @objc var createTime: String?
    @objc var updateTime: String?
    @objc var sequence: String?
    @objc var detailId: String?
    @objc var empName: String?  //distinguishedName
    @objc var topUnitName: String?  //distinguishedName
    @objc var unitName: String?  //distinguishedName
    @objc var companyName: String?
    @objc var departmentName: String?
    @objc var yearString: String?
    @objc var monthString: String?
    @objc var appealDateString: String?
    @objc var recordDateString: String?
    @objc var recordDate: String?
     var status: Int?
    @objc var startTime: String?
    @objc var endTime: String?
    @objc var appealReason: String?
    @objc var selfHolidayType: String?
    @objc var address: String?
    @objc var appealDescription: String?
    @objc var currentProcessor: String?
    @objc var processPerson1: String?
    @objc var processPersonDepartment1: String?
    @objc var processPersonCompany1: String?
    
    required override init() {
        
    }
}




/**
 * 审批申诉对象
 */
class AppealApprovalFormJson:NSObject,DataModel {
    @objc  var ids: [String]?
    @objc var opinion: String? //审核意见
    @objc var status: String?//审核状态:1-通过;2-需要进行复核;-1-不通过
    
    
    required override init() {
        
    }
}

/**
 * 反馈对象 status：SUCCESS
 */
class AppealApprovalBackInfoJson: NSObject,DataModel {
        var message: String?
        var status: String?
    
    required override init() {
        
    }
}
