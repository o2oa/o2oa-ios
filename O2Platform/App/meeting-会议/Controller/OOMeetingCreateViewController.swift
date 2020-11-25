//
//  OOMeetingCreateViewController.swift
//  o2app
//
//  Created by 刘振兴 on 2018/1/26.
//  Copyright © 2018年 zone. All rights reserved.
//

import UIKit
import CocoaLumberjack

private let headerIdentifier = "OOMeetingPersonSelectHeaderView"
private let footerIdentifier = "OOMeetingPersonFooterView"
private let personCellIdentifier = "OOMeetingPersonCell"
private let personActionCellIdentifier = "OOMeetingPersonActionCell"

class OOMeetingCreateViewController: UIViewController {
    
    @IBOutlet weak var ooFormView: OOMeetingCreateFormView!
    
    @IBOutlet weak var ooPersonCollectionView: UICollectionView!
    
    private lazy var  viewModel:OOMeetingCreateViewModel = {
       return OOMeetingCreateViewModel()
    }()
    
    @IBOutlet weak var topLayouConstraint: NSLayoutConstraint!
    
    
    
    var meetingInfo: OOMeetingInfo? //修改需要传入会议对象
    
    var fromDetail: Bool = false //是否从OOMeetingDetailViewController来的，如果是，就删除它
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 返回按钮重新定义
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_fanhui"), style: .plain, target: self, action: #selector(closeSelf))
        self.navigationItem.leftItemsSupplementBackButton = true
        
        ooFormView.delegate = self
        ooPersonCollectionView.dataSource = self
        ooPersonCollectionView.delegate = self
        ooPersonCollectionView.register(UINib.init(nibName: "OOMeetingPersonCell", bundle: nil), forCellWithReuseIdentifier: personCellIdentifier)
        ooPersonCollectionView.register(UINib.init(nibName: "OMeetingPersonActionCell", bundle: nil), forCellWithReuseIdentifier: personActionCellIdentifier)
        ooPersonCollectionView.register(UINib.init(nibName: "OOMeetingPersonSelectHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        ooPersonCollectionView.register(UINib.init(nibName: "OOMeetingPersonFooterView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: footerIdentifier)
        
        if let meeting = meetingInfo { //修改会议申请
            title = "修改会议申请"
            self.navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "保存", style: .plain, target: self, action: #selector(updateMeetingAction)),
                                                      UIBarButtonItem(title: "取消会议", style: .plain, target: self, action: #selector(deleteMeeting))]
            ooFormView.ooFormsModels = viewModel.getFormModelsUpdate(meeting: meeting)
            //会议人员
            if let persons = meeting.invitePersonList, persons.count > 0 {
                var selectPersons: [OOPersonModel] = []
                for person in persons {
                    let pModel = OOPersonModel()
                    pModel.distinguishedName = person
                    pModel.name = person.split("@").first ?? ""
                    selectPersons.append(pModel)
                }
                viewModel.selectedPersons = selectPersons
            }
        } else { //申请会议
            title = "申请会议"
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "创建", style: .plain, target: self, action: #selector(createMeetingAction(_:)))
            ooFormView.ooFormsModels = viewModel.getFormModels()
        }
        
    }
    
    // 申请会议
    @objc func createMeetingAction(_ sender:Any){
        let mBack = ooFormView.getFormDataFormBean()
        guard let mForm = mBack.0 else {
            self.showError(title: mBack.1 ?? "表单未填写完全！")
            return
        }
        guard self.viewModel.selectedPersons.count > 0 else {
            self.showError(title: "请选择参会人员！")
            return
        }
        self.viewModel.selectedPersons.forEach { (p) in
            mForm.invitePersonList.append(p.distinguishedName!)
        }
        let mBean = OOMeetingFormBean(meetingForm: mForm)
        if mBean.checkFormValues() {
            viewModel.createMeetingAction(mBean, completedBlock: { (resultMessage) in
                if let message = resultMessage {
                    self.showError(title: message)
                }else{
                    self.closeSelf()
                }
            })
        }
    }
    
    //会议申请 修改
    @objc func updateMeetingAction() {
        
        let mBack = ooFormView.getFormDataFormBean()
        guard let mForm = mBack.0 else {
            self.showError(title: mBack.1 ?? "表单未填写完全！")
            return
        }
        guard self.viewModel.selectedPersons.count > 0 else {
            self.showError(title: "请选择参会人员！")
            return
        }
        self.viewModel.selectedPersons.forEach { (p) in
            mForm.invitePersonList.append(p.distinguishedName!)
        }
        self.meetingInfo?.subject = mForm.subject
        self.meetingInfo?.room = mForm.room
        self.meetingInfo?.invitePersonList = mForm.invitePersonList
        self.meetingInfo?.startTime = "\(mForm.meetingDate.toString("yyyy-MM-dd")) \(mForm.startTime.toString("HH:mm:ss"))"
        self.meetingInfo?.completedTime = "\(mForm.meetingDate.toString("yyyy-MM-dd")) \(mForm.completedTime.toString("HH:mm:ss"))"
        self.viewModel.updateMeetingAction(meeting: self.meetingInfo!, completedBlock: { resultMessage in
            if let message = resultMessage {
                self.showError(title: message)
            }else{
                self.closeSelf()
            }
        })
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPersonSelectedSegue" {
            let navVC = segue.destination as! ZLNavigationController
            let destVC = navVC.topViewController as! OOMeetingSelectedPersonController
            destVC.viewModel = self.viewModel
            destVC.delegate = self
            destVC.currentMode = 2
            destVC.title = "选择人员"
        }else if segue.identifier == "showPickerRoom" {
            if let dest = segue.destination as? OOMeetingMeetingRoomManageController {
                dest.currentMode = 1 //单选
                dest.delegate = self
                if let mForm = sender as? OOMeetingForm {
                    let start = "\(mForm.meetingDate.toString("yyyy-MM-dd")) \(mForm.startTime.toString("HH:mm:ss"))"
                    let end = "\(mForm.meetingDate.toString("yyyy-MM-dd")) \(mForm.completedTime.toString("HH:mm:ss"))"
                    let startTime = Date.date(start, formatter: "yyyy-MM-dd HH:mm:ss") ?? Date()
                    let endTime = Date.date(end, formatter: "yyyy-MM-dd HH:mm:ss") ?? Date()
                    dest.startDate = startTime
                    dest.endDate = endTime
                }
            }
        }
    }
    
    
    
}
extension OOMeetingCreateViewController:UICollectionViewDataSource,UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.collectionViewNumberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.collectionViewNumberOfRowsInSection(section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell:UICollectionViewCell?
        if let model = viewModel.collectionViewNodeForIndexPath(indexPath) {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: personCellIdentifier, for: indexPath)
            let uCell = cell as! (OOMeetingPersonCell & Configurable)
            uCell.viewModel = self.viewModel
            uCell.config(withItem: model)
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: personActionCellIdentifier, for: indexPath)
            let uCell = cell as! OOMeetingPersonActionCell
            uCell.delegate = self
        }
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var reusableView:UICollectionReusableView = UICollectionReusableView(frame: .zero)
        if kind == UICollectionView.elementKindSectionHeader {
            reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath)
            let headerView = reusableView as! OOMeetingPersonSelectHeaderView
            headerView.personCount = viewModel.collectionViewNumberOfRowsInSection(indexPath.section) - 1
        }else if kind == UICollectionView.elementKindSectionFooter {
            reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: footerIdentifier, for: indexPath)
        }
        return reusableView
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        DDLogDebug("click item")
        if let model = viewModel.collectionViewNodeForIndexPath(indexPath) {
            self.viewModel.removeSelectPerson(model)
            self.ooPersonCollectionView.reloadData()
        }
    }
    
    
}

extension OOMeetingCreateViewController:UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: kScreenW, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: kScreenW, height: 30)
    }
}

extension OOMeetingCreateViewController:OOMeetingPersonActionCellDelegate{
    
    func addPersonActionClick(_ sender: UIButton) {
        //已经选择的人员
        var alreadyChoosePersons: [String] = []
        if !self.viewModel.selectedPersons.isEmpty {
            self.viewModel.selectedPersons.forEach { (model) in
                if let dn = model.distinguishedName {
                    alreadyChoosePersons.append(dn)
                }
            }
        }
        if let v = ContactPickerViewController.providePickerVC(
            pickerModes: [ContactPickerType.person],
            multiple: true,
            initUserPickedArray: alreadyChoosePersons,
            pickedDelegate: { (result: O2BizContactPickerResult) in
                if let users = result.users {
                    var persons :[OOPersonModel] = []
                    users.forEach({ (item) in
                        let pm = OOPersonModel()
                        pm.id = item.id
                        pm.name = item.name
                        pm.genderType = item.genderType
                        pm.distinguishedName = item.distinguishedName
                        persons.append(pm)
                    })
                    if !persons.isEmpty {
                        self.viewModel.selectedPersons = persons
                        self.ooPersonCollectionView.reloadData()
                    }
                }
                
        }) {
            self.navigationController?.pushViewController(v, animated: true)
        }
    }
}


// MARK:- Common Back Result
extension OOMeetingCreateViewController:OOCommonBackResultDelegate {
    func backResult(_ vcIdentifiter: String, _ result: Any?) {
        //返回的值
        
        if vcIdentifiter == "OOMeetingMeetingRoomManageController" {
            if let rooms = result as? [OOMeetingRoomInfo] {
                if !rooms.isEmpty {
                    self.ooFormView.setSelectedRoom(rooms.first!)
                }
            }
        }else if vcIdentifiter == "showPersonSelectedSegue" {
            if let persons = result as? [OOPersonModel] {
                if !persons.isEmpty{
                    self.viewModel.selectedPersons = persons
                    self.ooPersonCollectionView.reloadData()
                }
            }
        }
    }
}


// MARK:- OOMeetingCreateFormViewDelegate
extension OOMeetingCreateViewController:OOMeetingCreateFormViewDelegate{
    // MARK:- 人员选择
    func performPersonSelected() {
        
    }
    
    // MARK:- 会议室选择
    func performRoomSelected() {
        let mBack = ooFormView.getFormDataForChooseRoom()
        guard let mForm = mBack.0 else {
            self.showError(title: mBack.1 ?? "请先选择会议日期和时间！")
            return
        }
        self.performSegue(withIdentifier: "showPickerRoom", sender: mForm)
    }
}


