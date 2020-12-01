//
//  OOMeetingCreateViewModel.swift
//  o2app
//
//  Created by 刘振兴 on 2018/1/26.
//  Copyright © 2018年 zone. All rights reserved.
//

import UIKit

class OOMeetingCreateViewModel: NSObject {
    //Meeting API
    private let ooMeetingAPI = OOMoyaProvider<O2MeetingAPI>()
    //Contact API
    private let ooContactAPI = OOMoyaProvider<OOContactAPI>()
    
    private var persons:[OOPersonModel] = []
    
    var selectedPersons:[OOPersonModel] = []
    
    typealias CallDefine = (_ msg:String?) -> Void
    //人员列表回调
    var contactCallBlock:CallDefine?
    
    //选择人员列表回调
    var selectedContactCallBlock:CallDefine?
    
    override init() {
        super.init()
    }
    
}



extension OOMeetingCreateViewModel{
    
    func getLastPerson() -> OOPersonModel? {
        return self.persons.last ?? nil
    }
    //所有用户列表
    func getAllPerson(_ next:String?){
        if let nextId = next {
            ooContactAPI.request(.personListNext(nextId, 20)) { (result) in
                let myResult = OOResult<BaseModelClass<[OOPersonModel]>>(result)
                if myResult.isResultSuccess() {
                    if let model = myResult.model?.data {
                        model.forEach({ (item) in
                            self.persons.append(item)
                        })
                    }
                }
                guard let block = self.contactCallBlock else {
                    return
                }
                if myResult.isResultSuccess() {
                    block(nil)
                }else{
                    block(myResult.error?.errorDescription)
                }
            }
            
        }else{
            self.persons.removeAll()
            ooContactAPI.request(.personListNext("(0)", 20)) { (result) in
                let myResult = OOResult<BaseModelClass<[OOPersonModel]>>(result)
                if myResult.isResultSuccess() {
                    if let model = myResult.model?.data {
                        model.forEach({ (item) in
                            self.persons.append(item)
                        })
                    }
                }
                guard let block = self.contactCallBlock else {
                    return
                }
                if myResult.isResultSuccess() {
                    block(nil)
                }else{
                    block(myResult.error?.errorDescription)
                }
            }
        }
    }
    // MARK: - 获取icon
    func getIconOfPerson(_ person:OOPersonModel,compeletionBlock:@escaping (_ image:UIImage?,_ errMsg:String?) -> Void) {
        ooContactAPI.request(.iconByPerson(person.distinguishedName!)) { (result) in
            switch result {
            case .success(let res):
                guard let image = UIImage(data: res.data) else {
                    compeletionBlock(#imageLiteral(resourceName: "icon_？"),"image transform error")
                    return
                }
                compeletionBlock(image,nil)
                break
            case .failure(let err):
                compeletionBlock(#imageLiteral(resourceName: "icon_？"),err.errorDescription)
                break
            }
        }
    }
    //创建会议
    func createMeetingAction(_ meeting:OOMeetingFormBean,completedBlock:@escaping (_ returnMessage:String?) -> Void){
        ooMeetingAPI.request(.meetingItemByCreate(meeting)) { (result) in
            let myResult = OOResult<BaseModelClass<OOCommonIdModel>>(result)
            if myResult.isResultSuccess() {
                completedBlock(nil)
            }else{
                completedBlock(myResult.error?.errorDescription)
            }
        }
        
    }
    
    /// 创建会议
    func createMeetingActionNew(_ meeting:OOMeetingInfo, completedBlock:@escaping (_ returnMessage:String?, _ meetingId: String?) -> Void){
        ooMeetingAPI.request(.meetingCreate(meeting)) { (result) in
            let myResult = OOResult<BaseModelClass<OOCommonIdModel>>(result)
            if myResult.isResultSuccess() {
                completedBlock(nil, myResult.model?.data?.id)
            }else{
                completedBlock(myResult.error?.errorDescription, nil)
            }
        }
        
    }
    /// 更新会议
    func updateMeetingAction(meeting: OOMeetingInfo, completedBlock: @escaping (_ returnMessage:String?) -> Void) {
        ooMeetingAPI.request(.meetingItemUpdate(meeting)) { (result) in
            let myResult = OOResult<BaseModelClass<OOCommonIdModel>>(result)
            if myResult.isResultSuccess() {
                completedBlock(nil)
            }else{
                completedBlock(myResult.error?.errorDescription)
            }
        }
    }
    
    /// 上传会议材料 返回当前会议的材料列表
    func uploadMeetingFile(meetingId: String, fileName: String, file: Data, completedBlock:@escaping (_ returnMessage:String?, _ list: [OOMeetingAttachmentList]?) -> Void) {
        ooMeetingAPI.request(.meetingUploadFile(meetingId, fileName, file)) { result in
            let myResult = OOResult<BaseModelClass<OOCommonIdModel>>(result)
            if myResult.isResultSuccess() {
                self.ooMeetingAPI.request(.meetingAttachmentList(meetingId)) { attListResult in
                    let attList = OOResult<BaseModelClass<[OOMeetingAttachmentList]>>(attListResult)
                    if attList.isResultSuccess() {
                        completedBlock(nil, attList.model?.data)
                    }else {
                        completedBlock(attList.error?.errorDescription, nil)
                    }
                }
            }else{
                completedBlock(myResult.error?.errorDescription, nil)
            }
        }
    }
    
    /// 删除一个会议材料 返回当前会议的材料列表
    func deleteMeetingFile(meetingId: String, fileId: String, completedBlock:@escaping (_ returnMessage:String?, _ list: [OOMeetingAttachmentList]?) -> Void) {
        ooMeetingAPI.request(.meetingAttachmentDelete(fileId)) { deleteResult in
            let myDeleteResult = OOResult<BaseModelClass<OOCommonIdModel>>(deleteResult)
            if myDeleteResult.isResultSuccess() {
                self.ooMeetingAPI.request(.meetingAttachmentList(meetingId)) { attListResult in
                    let myAttListResult = OOResult<BaseModelClass<[OOMeetingAttachmentList]>>(attListResult)
                    if myAttListResult.isResultSuccess() {
                        completedBlock(nil, myAttListResult.model?.data)
                    }else {
                        completedBlock(myAttListResult.error?.errorDescription, nil)
                    }
                }
            }else {
                completedBlock(myDeleteResult.error?.errorDescription, nil)
            }
        }
    }
    
    ///接受会议邀请
    func acceptMeeting(meetingId: String, completedBlock: @escaping (_ returnMessage:String?) -> Void) {
        ooMeetingAPI.request(.meetingItemAcceptById(meetingId)) { result in
            let myResult = OOResult<BaseModelClass<OOCommonIdModel>>(result)
            if myResult.isResultSuccess() {
                completedBlock(nil)
            } else {
                completedBlock(myResult.error?.errorDescription)
            }
        }
    }
    ///拒绝会议邀请
    func rejectMeeting(meetingId: String, completedBlock: @escaping (_ returnMessage:String?) -> Void) {
        ooMeetingAPI.request(.meetingItemRejectById(meetingId)) { result in
            let myResult = OOResult<BaseModelClass<OOCommonIdModel>>(result)
            if myResult.isResultSuccess() {
                completedBlock(nil)
            } else {
                completedBlock(myResult.error?.errorDescription)
            }
        }
    }
    ///取消会议
    func deleteMeeting(meetingId: String, completedBlock: @escaping (_ returnMessage:String?) -> Void) {
        ooMeetingAPI.request(.meetingItemDelete(meetingId)) { result in
            let myResult = OOResult<BaseModelClass<OOCommonIdModel>>(result)
            if myResult.isResultSuccess() {
                completedBlock(nil)
            } else {
                completedBlock(myResult.error?.errorDescription)
            }
        }
    }
    
    /// 下载附件到本地 返回本地url 可以前端打开
    func downloadMeetingFile(file: OOMeetingAttachmentList, completedBlock: @escaping (_ error: String?, _ url: URL?) -> Void) {
        self.ooMeetingAPI.request(.meetingAttachmentDownload(file)) { result in
            switch result {
            case .success(_):
                completedBlock(nil, self.meetingFilePath(file: file))
            case .failure(let err):
                completedBlock(err.errorDescription, nil)
            }
        }
    }
    
    private func meetingFilePath(file: OOMeetingAttachmentList) -> URL {
        let fileName = "\(file.name ?? "untitle").\(file.extension ?? "png")"
        return O2.meetingFileLocalFolder().appendingPathComponent(fileName)
    }
    
    //表单模型
    func getFormModels() -> [OOFormBaseModel] {
        let titleModel = OOFormBaseModel(titleName: "会议主题", key: "subject", componentType: .textItem, itemStatus: .edit)
        let dateModel = OOFormBaseModel(titleName: "会议日期", key: "date", componentType: .dateItem, itemStatus: .edit)
        let dateIntervalModel = OOFormDateIntervalModel(titleName: "会议时间", key: "dateInterval", componentType: .dateIntervalItem, itemStatus: .edit)
        let segueModel = OOFormSegueItemModel(titleName: "会议室", key: "room", componentType: .segueItem, itemStatus: .edit)
        segueModel.segueIdentifier = "OOMeetingMeetingRoomManageController"
        return [titleModel,dateModel,dateIntervalModel,segueModel]
    }
    
    func getFormModelsUpdate(meeting: OOMeetingInfo) -> [OOFormBaseModel] {
        let titleModel = OOFormBaseModel(titleName: "会议主题", key: "subject", componentType: .textItem, itemStatus: .edit)
        titleModel.callbackValue = meeting.subject
        let dateModel = OOFormBaseModel(titleName: "会议日期", key: "date", componentType: .dateItem, itemStatus: .edit)
        if let startTime = meeting.startTime {
            dateModel.callbackValue =  Date.date(startTime, formatter: "yyyy-MM-dd HH:mm:ss")
        }
        let dateIntervalModel = OOFormDateIntervalModel(titleName: "会议时间", key: "dateInterval", componentType: .dateIntervalItem, itemStatus: .edit)
        if let startTime = meeting.startTime {
            dateIntervalModel.value1 =  Date.date(startTime, formatter: "yyyy-MM-dd HH:mm:ss")
        }
        if let endTime = meeting.completedTime {
            dateIntervalModel.value2 =  Date.date(endTime, formatter: "yyyy-MM-dd HH:mm:ss")
        }
        
        let segueModel = OOFormSegueItemModel(titleName: "会议室", key: "room", componentType: .segueItem, itemStatus: .edit)
        segueModel.segueIdentifier = "OOMeetingMeetingRoomManageController"
        segueModel.callbackValue = meeting.woRoom
        return [titleModel,dateModel,dateIntervalModel,segueModel]
    }
}
// MARK:- 选择的人员列表
extension OOMeetingCreateViewModel{
    
    func addSelectPerson(_ p:OOPersonModel){
        self.selectedPersons.append(p)
    }
    
    func removeSelectPerson(_ p:OOPersonModel){
        if let i = self.selectedPersons.firstIndex(of: p) {
             self.selectedPersons.remove(at:i)
        }
    }
    
    func refreshData(){
        guard let block = self.selectedContactCallBlock else {
            return
        }
        block(nil)
    }
    
    func collectionViewNumberOfSections() -> Int {
        return 1
    }
    
    func collectionViewNumberOfRowsInSection(_ section: Int) -> Int {
        return selectedPersons.count + 1
    }
    
    func collectionViewNodeForIndexPath(_ indexPath:IndexPath) -> OOPersonModel? {
        if indexPath.row < selectedPersons.count {
            return selectedPersons[indexPath.row]
        }else{
            return nil
        }
    }
}

// MARK:- 人员列表
extension OOMeetingCreateViewModel {
    func tableViewNumberOfSections() -> Int {
        return 1
    }
    
    func tableViewNumberOfRowsInSection(_ section: Int) -> Int {
        return persons.count
    }
    
    func tableViewNodeForIndexPath(_ indexPath:IndexPath) -> OOPersonModel? {
        return persons[indexPath.row]
    }
}
