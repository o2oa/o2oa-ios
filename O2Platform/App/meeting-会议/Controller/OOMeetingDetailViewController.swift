//
//  OOMeetingDetailViewController.swift
//  O2Platform
//
//  Created by FancyLou on 2020/11/18.
//  Copyright © 2020 zoneland. All rights reserved.
//

import UIKit
import Eureka
import QuickLook

class OOMeetingDetailViewController: FormViewController {

 
    private lazy var  viewModel:OOMeetingCreateViewModel = {
       return OOMeetingCreateViewModel()
    }()
    //预览文件
    private lazy var previewVC: CloudFilePreviewController = {
        return CloudFilePreviewController()
    }()
    var meetingInfo: OOMeetingInfo? //需要传入会议对象
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.meetingInfo?.subject ?? "会议详情"
        
        if self.meetingInfo?.status == "wait" && self.meetingInfo?.applicant == O2AuthSDK.shared.myInfo()?.distinguishedName {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "修改", style: .plain, target: self, action: #selector(toUpdateMeeting))
        }
        
        self.loadForm()
    }
    
 
    func loadForm() {
        var time = ""
        if let start = self.meetingInfo?.startTime,
           let startTime = Date.date(start, formatter: "yyyy-MM-dd HH:mm:ss"),
           let end = self.meetingInfo?.completedTime, let endTime = Date.date(end, formatter: "yyyy-MM-dd HH:mm:ss") {
            time = startTime.toString("HH:mm") + " 至 " + endTime.toString("HH:mm")
        }
        
        form +++ Section()
            <<< LabelRow(){ row in
                row.title = "申请人"
                row.value = self.meetingInfo?.applicant?.split("@").first
            }
            <<< LabelRow(){ row in
                row.title = "会议标题"
                row.value = self.meetingInfo?.subject
            }
            <<< LabelRow(){ row in
                row.title = "会议日期"
                row.value = self.meetingInfo?.startTime?.subString(from: 0, to: 10)
            }
            <<< LabelRow(){ row in
                row.title = "会议时间"
                row.value = time
            }
            <<< LabelRow(){ row in
                row.title = "会议室"
                row.value = self.meetingInfo?.woRoom?.name
            }
            <<< PersonListRow(){ row in
                row.cell.viewModel = self.viewModel
                row.cell.delegate = self
                row.title = "参会人员"
                row.value = self.meetingInfo
            }
            <<< LabelRow(){ row in
                row.title = "会议描述"
                row.value = self.meetingInfo?.summary
            }
            <<< MeetingFormAttachmentCellRow("attachmentList") { row in
                row.cell.openFileAction = { atta in
                    self.downloadFile(atta: atta)
                }
                row.value = self.meetingInfo?.attachmentList
            }
            
    }
    
    private func downloadFile(atta: OOMeetingAttachmentList) {
        self.showLoading()
        self.viewModel.downloadMeetingFile(file: atta) { (err, filePath) in
            self.hideLoading()
            if let path = filePath {
                self.previewFile(path: path)
            } else if let msg = err {
                self.showError(title: msg)
            }
        }
    }
    
    private func previewFile(path: URL) {
        let currentURL = NSURL(fileURLWithPath: path.path)
        print(currentURL.description)
        print(path.path)
        if QLPreviewController.canPreview(currentURL) {
            self.previewVC.currentFileURLS.removeAll()
            self.previewVC.currentFileURLS.append(currentURL)
            self.previewVC.reloadData()
            self.pushVC(self.previewVC)
        }else {
            self.showError(title: "当前文件类型不支持预览！")
        }
    }
    
    @objc private func toUpdateMeeting() {
        if let meeting = self.meetingInfo {
            self.performSegue(withIdentifier: "showEditMeetingNew", sender: meeting)
        }
    }
    
   
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEditMeetingNew" {
            if let vc = segue.destination as? OOMeetingFormViewController {
                if let meeting = sender as? OOMeetingInfo {
                    vc.meetingInfo = meeting
                    vc.fromDetail = true
                }
            }
        }
    }

}


extension OOMeetingDetailViewController: PersonListCellDelegate {
    func clickAccept(_ completedBlock: @escaping () -> Void) {
        if let meeting = self.meetingInfo {
            self.viewModel.acceptMeeting(meetingId: meeting.id!) { (err) in
                if let message = err {
                    self.showError(title: message)
                }else {
                    completedBlock()
                }
            }
        }
    }
    
    func clickReject(_ completedBlock: @escaping () -> Void) {
        if let meeting = self.meetingInfo {
            self.showDefaultConfirm(title: "提示", message: "确定要拒绝当前会议邀请？") { (action) in
                self.viewModel.rejectMeeting(meetingId: meeting.id!) { (err) in
                    if let message = err {
                        self.showError(title: message)
                    }else {
                        completedBlock()
                    }
                }
            }
        }
        
    }
    
    
}
