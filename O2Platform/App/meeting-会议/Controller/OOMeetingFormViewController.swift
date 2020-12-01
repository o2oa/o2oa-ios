//
//  OOMeetingFormViewController.swift
//  O2Platform
//
//  Created by FancyLou on 2020/11/20.
//  Copyright © 2020 zoneland. All rights reserved.
//

import UIKit
import Eureka

class OOMeetingFormViewController: FormViewController {

    private lazy var  viewModel:OOMeetingCreateViewModel = {
       return OOMeetingCreateViewModel()
    }()
    
    var fromDetail: Bool = false //是否从OOMeetingDetailViewController来的，如果是，就需要返回两层
    
    var meetingInfo: OOMeetingInfo? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 返回按钮重新定义
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_fanhui"), style: .plain, target: self, action: #selector(closeSelf))
        self.navigationItem.leftItemsSupplementBackButton = true
        if let _ = meetingInfo { //修改会议申请
            title = "修改申请"
            self.navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "保存", style: .plain, target: self, action: #selector(createOrUpdateMeetingAction)),
                                                      UIBarButtonItem(title: "取消会议", style: .plain, target: self, action: #selector(deleteMeeting))]
        } else { //申请会议
            title = "申请会议"
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "创建", style: .plain, target: self, action: #selector(createOrUpdateMeetingAction))
            self.meetingInfo = OOMeetingInfo()
        }
        self.loadForm()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPickRoom" {
            if let vc = segue.destination as? OOMeetingMeetingRoomManageController {
                vc.currentMode = 1 //单选
                vc.delegate = self
                if let during = sender as? DuringTime {
                    if let start = during.startTime {
                        vc.startDate = start
                    }
                    if let end = during.endTime {
                        vc.endDate = end
                    }
                }
            }
        }
    }
    
    /// 关闭
    @objc private func closeSelf() {
        if fromDetail {
            //返回两层
            if let index = self.navigationController?.viewControllers.firstIndex(of: self) {
                if let secVC = self.navigationController?.viewControllers.get(at: index - 2) {
                    self.navigationController?.popToViewController(secVC, animated: true)
                }
            }
        }else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    /// 保存或者修改会议
    @objc private func createOrUpdateMeetingAction() {
        if self.validateForm() {
            if self.meetingInfo!.id == nil { //新增
                self.viewModel.createMeetingActionNew(self.meetingInfo!) { (err, id) in
                    if let msg = err {
                        self.showError(title: msg)
                    }else {
                        self.closeSelf()
                    }
                }
            }else { // 修改
                self.viewModel.updateMeetingAction(meeting: self.meetingInfo!) { (err) in
                    if let msg = err {
                        self.showError(title: msg)
                    }else {
                        self.closeSelf()
                    }
                }
            }
        }
        
    }
    
    /// 删除会议
    @objc private func deleteMeeting() {
        if let meeting = self.meetingInfo {
            self.showDefaultConfirm(title: "提示", message: "确定要取消当前会议，数据会被删除？") { (action) in
                self.viewModel.deleteMeeting(meetingId: meeting.id!) { (err) in
                    if let message = err {
                        self.showError(title: message)
                    }else {
                        self.closeSelf()
                    }
                }
            }
        }
    }
    
    private func loadForm() {

        form +++ Section()
            <<< TextRow("subject") { row in
                row.title = "会议标题"
                row.placeholder = "请输入标题"
                row.value = self.meetingInfo?.subject
            }
            <<< MeetingFormDatePickerRow("meetingDate") { row in
                row.title = "会议日期"
                if let startTime = self.meetingInfo?.startTime {
                    let date = Date.date(startTime, formatter: "yyyy-MM-dd HH:mm:ss")
                    row.value = date
                }
            }
            <<< MeetingFormTimeDuringRow("meetingTimeDuring") { row in
                row.title = "会议时间"
                let during = DuringTime()
                if let startTime = self.meetingInfo?.startTime {
                    let s = Date.date(startTime, formatter: "yyyy-MM-dd HH:mm:ss")
                    during.startTime = s
                }
                if let completedTime = self.meetingInfo?.completedTime {
                    let c = Date.date(completedTime, formatter: "yyyy-MM-dd HH:mm:ss")
                    during.endTime = c
                }
                row.value = during
            }
            <<< MeetingFormRoomPickerCellRow("room") { row in
                row.title = "会议室"
                row.onPresent = {
                    self.openChooseRoom()
                }
                row.value = self.meetingInfo?.woRoom
            }
            <<< MeetingFormChoosePersonCellRow("invitePerson") { row in
                row.title = "参会人员"
                row.cell.viewModel = self.viewModel
                row.cell.isUpdate = self.meetingInfo?.id != nil
                if let persons = self.meetingInfo?.invitePersonList, persons.count > 0 {
                    var selectPersons: [OOPersonModel] = []
                    for person in persons {
                        let pModel = OOPersonModel()
                        pModel.distinguishedName = person
                        pModel.name = person.split("@").first ?? ""
                        selectPersons.append(pModel)
                    }
                    row.value = selectPersons
                }
            }
            <<< TextAreaRow("summary") { row in
                row.title = "会议描述"
                row.placeholder = "会议描述"
                row.value = self.meetingInfo?.summary
            }
            <<< MeetingFormAttachmentCellRow("attachmentList") { row in
                row.cell.editMode = true
                row.cell.uploadAction = {
                    self.uploadFileAction()
                }
                row.cell.deleteAction = { atta in
                    self.deleteMeetingFile(file: atta)
                }
                row.value = self.meetingInfo?.attachmentList
            }
    }
    
    
 
    private func openChooseRoom() {
        let meetingDateRow = form.rowBy(tag: "meetingDate") as? MeetingFormDatePickerRow
        guard let date = meetingDateRow?.value else {
            self.showError(title: "请选择会议日期")
            return
        }
        let meetingTimeDuringRow = form.rowBy(tag: "meetingTimeDuring") as? MeetingFormTimeDuringRow
        guard let startTime = meetingTimeDuringRow?.value?.startTime else {
            self.showError(title: "请选择开始时间")
            return
        }
        guard let endTime = meetingTimeDuringRow?.value?.endTime else {
            self.showError(title: "请选择结束时间")
            return
        }
        let startString = "\(date.toString("yyyy-MM-dd")) \(startTime.toString("HH:mm:ss"))"
        let endString = "\(date.toString("yyyy-MM-dd")) \(endTime.toString("HH:mm:ss"))"
        let during = DuringTime()
        during.startTime =  Date.date(startString, formatter: "yyyy-MM-dd HH:mm:ss")
        during.endTime = Date.date(endString, formatter: "yyyy-MM-dd HH:mm:ss")
        self.performSegue(withIdentifier: "showPickRoom", sender: during)
    }
    /// 验证表单 同时赋值
    private func validateForm() -> Bool {
        if self.meetingInfo == nil {
            self.meetingInfo = OOMeetingInfo()
        }
        let subjectRow = form.rowBy(tag: "subject") as? TextRow
        guard let subject = subjectRow?.value else {
            self.showError(title: "请输入会议标题")
            return false
        }
        self.meetingInfo?.subject = subject
        let meetingDateRow = form.rowBy(tag: "meetingDate") as? MeetingFormDatePickerRow
        guard let date = meetingDateRow?.value else {
            self.showError(title: "请选择会议日期")
            return false
        }
        let meetingTimeDuringRow = form.rowBy(tag: "meetingTimeDuring") as? MeetingFormTimeDuringRow
        guard let startTime = meetingTimeDuringRow?.value?.startTime else {
            self.showError(title: "请选择开始时间")
            return false
        }
        guard let endTime = meetingTimeDuringRow?.value?.endTime else {
            self.showError(title: "请选择结束时间")
            return false
        }
        self.meetingInfo?.startTime = "\(date.toString("yyyy-MM-dd")) \(startTime.toString("HH:mm:ss"))"
        self.meetingInfo?.completedTime = "\(date.toString("yyyy-MM-dd")) \(endTime.toString("HH:mm:ss"))"
        let roomRow = form.rowBy(tag: "room") as? MeetingFormRoomPickerCellRow
        guard let room = roomRow?.value else {
            self.showError(title: "请选择会议室")
            return false
        }
        self.meetingInfo?.room = room.id
        let personRow = form.rowBy(tag: "invitePerson") as? MeetingFormChoosePersonCellRow
        guard let personList = personRow?.value else {
            self.showError(title: "请选择参会人员")
            return false
        }
        var personIds : [String] = []
        personList.forEach { (p) in
            if let dn = p.distinguishedName {
                personIds.append(dn)
            }
        }
        self.meetingInfo?.invitePersonList = personIds
        let summaryRow = form.rowBy(tag: "summary") as? TextAreaRow
        self.meetingInfo?.summary = summaryRow?.value
        
        return true
    }
    
    /// 上传附件到服务器
    fileprivate func uploadFile(_ meetingId: String, _ fileName: String, _ imageData: Data) {
        self.viewModel.uploadMeetingFile(meetingId: meetingId, fileName: fileName, file: imageData) { (err, list) in
            self.hideLoading()
            if let aList = list  {
                self.reloadAttachmentCell(list: aList)
            }
            if let msg = err {
                self.showError(title: msg)
            }
        }
    }
    
    /// 点击附件
    private func uploadFileAction() {
        if self.validateForm() {
            self.choosePhotoWithImagePicker { (fileName, imageData) in
                self.showLoading()
                if let meetingId = self.meetingInfo?.id  { // 直接上传
                    self.uploadFile(meetingId, fileName, imageData)
                } else { // 新表单需要先保存会议 再上传
                    if let meeting = self.meetingInfo {
                        self.viewModel.createMeetingActionNew(meeting) { (err, id) in
                            if let meetingId = id  {
                                self.meetingInfo?.id = meetingId
                                self.uploadFile(meetingId, fileName, imageData)
                            }else if let msg = err {
                                self.showError(title: msg)
                            }
                        }
                    }
                }
            }
        }
    }
    
    /// 删除会议材料 刷新附件模块数据
    private func deleteMeetingFile(file: OOMeetingAttachmentList) {
        guard let meetingId = self.meetingInfo?.id else {
            return
        }
        guard let fileId = file.id else {
            return
        }
        self.showLoading()
        self.viewModel.deleteMeetingFile(meetingId: meetingId, fileId: fileId) { (err, list) in
            self.hideLoading()
            if let attaList = list  {
                self.reloadAttachmentCell(list: attaList)
            }else if let msg = err {
                self.showError(title: msg)
            }
        }
    }
    
    /// 刷新附件模块数据
    private func reloadAttachmentCell(list: [OOMeetingAttachmentList]) {
        let row = form.rowBy(tag: "attachmentList") as? MeetingFormAttachmentCellRow
        row?.value = list
        row?.updateCell()
        print("refesh attaList size : \(list.count)")
    }

     
}

extension OOMeetingFormViewController: OOCommonBackResultDelegate {
    func backResult(_ vcIdentifiter: String, _ result: Any?) {
        if vcIdentifiter == "OOMeetingMeetingRoomManageController" {
            if let rooms = result as? [OOMeetingRoomInfo] {
                if !rooms.isEmpty {
                    if let roomRow = form.rowBy(tag: "room") as? MeetingFormRoomPickerCellRow {
                        roomRow.value = rooms.first
                        roomRow.updateCell()
                    }
                }
            }
        }
    }
    
    
}
