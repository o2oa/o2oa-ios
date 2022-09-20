//
//  AttendanceAppealViewController.swift
//  O2Platform
//
//  Created by FancyLou on 2022/9/20.
//  Copyright © 2022 zoneland. All rights reserved.
//

import UIKit
import Eureka
import ViewRow
import CocoaLumberjack

class AttendanceAppealViewController: FormViewController {

    private lazy var viewModel: OOAttandanceViewModel = {
        return OOAttandanceViewModel()
    }()
    
    var detail: AttendanceDetailInfoJson? = nil
    
    let appealReasonList:[String] = ["临时请假","出差","因公外出","其他"]
    let appealLeaveTypeList:[String] = ["带薪年休假","带薪病假","带薪福利假","扣薪事假","其他"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "申诉"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "提交", style: .plain, target: self, action: #selector(submitAppealApprove))
        self.loadForm()
    }
    
    private func loadForm() {

        var person = self.detail?.empName ?? ""
        person = person.contains("@") ? person.split("@")[0] : person
        
        var status = "正常"
        if self.detail?.isGetSelfHolidays == true {
            status = "请假"
        } else if self.detail?.isLate == true {
            status = "迟到"
        } else if self.detail?.isAbsent == true {
            status = "缺勤"
        } else if self.detail?.isAbnormalDuty == true {
            status = "异常打卡"
        } else if self.detail?.isLackOfTime == true {
            status = "工时不足"
        }
        
        form +++ Section()
            <<< ViewRow<UILabel>("view") { (row) in
//                    row.title = "My View Title" // optional
                }
                .cellSetup { (cell, row) in
                    let label = UILabel(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 48))
//                    var attrs =  NSAttributedString(string: "申诉申请单")
//                    var style = NSParagraphStyle()
//                    style.setValue(<#T##value: Any?##Any?#>, forKey: <#T##String#>)
//                    attrs.attribute(<#T##attrName: NSAttributedString.Key##NSAttributedString.Key#>, at: <#T##Int#>, effectiveRange: <#T##NSRangePointer?#>) .addAttribute(.paragraphStyle, value: style, range: NSRange(location: 0, length: 5))
                    label.text = "申诉申请单"
                    label.textAlignment = .center
                    label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
                    cell.view = label
                }
            <<< TextRow("person") { row in
                row.title = "员工姓名"
                row.disabled = true
                row.value = person
            }
            <<< TextRow("recordDateString") { row in
                row.title = "考勤日期"
                row.disabled = true
                row.value = self.detail?.recordDateString ?? ""
            }
            <<< TextRow("onDutyTime") { row in
                row.title = "上班打卡时间"
                row.disabled = true
                row.value = self.detail?.onDutyTime ?? ""
            }
            <<< TextRow("offDutyTime") { row in
                row.title = "下班打卡时间"
                row.disabled = true
                row.value = self.detail?.offDutyTime ?? ""
            }
            <<< TextRow("status") { row in
                row.title = "考勤状态"
                row.disabled = true
                row.value = status
            }
            <<< ActionSheetRow<String>("reason") {
                $0.title = "申诉原因"
                $0.selectorTitle = "请选择申诉原因"
                $0.options = self.appealReasonList
            }
            <<< ActionSheetRow<String>("appealLeave") {
                $0.title = "请假类型"
                $0.selectorTitle = "请选择请假类型"
                $0.options = self.appealLeaveTypeList
                $0.hidden = Condition.function(["reason"], { form in
                    let reasonValue = (form.rowBy(tag: "reason") as? ActionSheetRow<String>)?.value ?? ""
                    return !(reasonValue == "临时请假")
                })
            }
            <<< TextRow("appealAddress") { row in
                row.title = "地点"
                row.placeholder = "请输入地点"
                row.hidden = Condition.function(["reason"], { form in
                    let reasonValue = (form.rowBy(tag: "reason") as? ActionSheetRow<String>)?.value ?? ""
                    return (reasonValue != "出差" && reasonValue != "因公外出" )
                })
            }
            <<< MeetingFormDatePickerRow("appealDate") { row in
                row.title = "日期"
                row.hidden = Condition.function(["reason"], { form in
                    let reasonValue = (form.rowBy(tag: "reason") as? ActionSheetRow<String>)?.value ?? ""
                    return (reasonValue == "其他")
                })
//                if let startTime = self.meetingInfo?.startTime {
//                    let date = Date.date(startTime, formatter: "yyyy-MM-dd HH:mm:ss")
//                    row.value = date
//                }
                
            }
            <<< MeetingFormTimeDuringRow("appealDuring") { row in
                row.title = "时间"
                row.hidden = Condition.function(["reason"], { form in
                    let reasonValue = (form.rowBy(tag: "reason") as? ActionSheetRow<String>)?.value ?? ""
                    return (reasonValue == "其他")
                })
//                let during = DuringTime()
//                if let startTime = self.meetingInfo?.startTime {
//                    let s = Date.date(startTime, formatter: "yyyy-MM-dd HH:mm:ss")
//                    during.startTime = s
//                }
//                if let completedTime = self.meetingInfo?.completedTime {
//                    let c = Date.date(completedTime, formatter: "yyyy-MM-dd HH:mm:ss")
//                    during.endTime = c
//                }
//                row.value = during
            }
            <<< TextAreaRow("appealDesc") { row in
                row.title = "事由"
                row.placeholder = "请输入事由"
                row.hidden = Condition.function(["reason"], { form in
                    let reasonValue = (form.rowBy(tag: "reason") as? ActionSheetRow<String>)?.value ?? ""
                    return !(reasonValue == "因公外出" || reasonValue == "其他")
                })
            }
        
    }
    
    @objc private func submitAppealApprove() {
        guard let detail = detail else {
            DDLogError("数据错误！！！！！")
            return
        }

        guard let reasonValue = (form.rowBy(tag: "reason") as? ActionSheetRow<String>)?.value else {
            self.showError(title: "请选择申诉原因")
            return
        }
        DDLogDebug("原因： \(reasonValue)")
        detail.appealReason = reasonValue
        let appealLeaveValue = (form.rowBy(tag: "appealLeave") as? ActionSheetRow<String>)?.value ?? ""
        DDLogDebug("请假： \(appealLeaveValue)")
        let appealAddress = (form.rowBy(tag: "appealAddress") as? TextRow)?.value ?? ""
        DDLogDebug("appealAddress： \(appealAddress)")
        let meetingDateRow = form.rowBy(tag: "appealDate") as? MeetingFormDatePickerRow
        let appealDuring = form.rowBy(tag: "appealDuring") as? MeetingFormTimeDuringRow
        let appealDesc = (form.rowBy(tag: "appealDesc") as? TextAreaRow)?.value ?? ""
        DDLogDebug("appealDesc： \(appealDesc)")
        switch(reasonValue) {
        case "临时请假":
            if appealLeaveValue.isEmpty {
                self.showError(title: "请选择请假类型")
                return
            }
            detail.selfHolidayType = appealLeaveValue
            break
        case "出差":
            if appealAddress.isEmpty {
                self.showError(title: "请输入地点")
                return
            }
            break
        case "因公外出":
            if appealAddress.isEmpty {
                self.showError(title: "请输入地点")
                return
            }
            if appealDesc.isEmpty {
                self.showError(title: "请输入事由")
                return
            }
            break
        case "其他":
            if appealDesc.isEmpty {
                self.showError(title: "请输入事由")
                return
            }
            break
        default :
            DDLogError("不正确的原因，\(reasonValue)")
            return
        }
        DDLogDebug("进入。。。。。。")
        if reasonValue != "其他" {
            guard let appealDate = meetingDateRow?.value else {
                self.showError(title: "请选择日期")
                return
            }
            guard let appealDuringDateStart = appealDuring?.value?.startTime else {
                self.showError(title: "请选择开始时间")
                return
            }
            guard let appealDuringDateEnd = appealDuring?.value?.endTime else {
                self.showError(title: "请选择结束时间")
                return
            }
            detail.address = appealAddress
            detail.startTime = appealDate.toString("yyyy-MM-dd") + " " + appealDuringDateStart.toString("HH:mm:ss")
            detail.endTime = appealDate.toString("yyyy-MM-dd") + " " + appealDuringDateEnd.toString("HH:mm:ss")
        } else {
            detail.appealDescription = appealDesc
        }
        
        DDLogDebug("进入。。。。。2222。")
        
        viewModel.submitAppealApprove(form: detail) { resultType in
            switch resultType {
            case .ok(_):
                self.popVC()
                break
            case .fail(let errorMessage):
                DDLogError(errorMessage)
                self.showError(title: "申诉失败！")
                break
            default:
                break
            }
        }
        
    }
    
 
}
