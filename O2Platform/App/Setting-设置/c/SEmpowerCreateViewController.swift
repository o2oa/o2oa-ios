//
//  SEmpowerCreateViewController.swift
//  O2Platform
//
//  Created by FancyLou on 2023/5/17.
//  Copyright © 2023 zoneland. All rights reserved.
//

import UIKit
import CocoaLumberjack


class SEmpowerCreateViewController: UIViewController {

    @IBOutlet weak var identityBaseView: UIView!
    
    @IBOutlet weak var identityBaseViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var toPersonLabel: UILabel!
    
    @IBOutlet weak var toPersonView: UIStackView!
    
    @IBOutlet weak var startTimeView: UIStackView!
    
    @IBOutlet weak var startTimeLabel: UILabel!
    
    @IBOutlet weak var completeTimeView: UIStackView!
    
    @IBOutlet weak var completeTimeLabel: UILabel!
    
    @IBOutlet weak var applicationView: UIStackView!
    
    @IBOutlet weak var applicationNameLabel: UILabel!
    @IBOutlet weak var processView: UIStackView!
    
    @IBOutlet weak var processNameLabel: UILabel!
    
    @IBOutlet weak var typeSegmentedControl: UISegmentedControl!
    
    
    private let viewModel: O2PersonalViewModel = {
        return O2PersonalViewModel()
    }()

    var identitys: [O2IdentityInfo] = []
    var identityViews: [IdentitySelectView] = []
    
    // form data
    var fIdentity: O2IdentityInfo? = nil
    var toPerson: String? = nil // 身份 dn
    var startTime: String = ""
    var completeTime: String = ""
    var type: String = "all" // all application process
    var application: O2Application? = nil
    var process: O2ApplicationProcess? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "新建外出授权"
        //右边按钮
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "提交", style: .plain, target: self, action: #selector(self.postForm))
        self.loadCurrentIdentities()
        self.typeSegmentedControl.addTarget(self, action: #selector(typeSegmentPicker), for: .valueChanged)
        self.typeSegmentedControl.tintColor = O2ThemeManager.color(for: "Base.base_color")!
        self.startTimeView.addTapGesture { tap in
            self.chooseStartTime()
        }
        self.completeTimeView.addTapGesture { tap in
            self.chooseCompleteTime()
        }
        self.toPersonView.addTapGesture { tap in
            self.chooseToPerson()
        }
        self.processView.addTapGesture { tap in
            self.chooseProcess()
        }
        self.applicationView.addTapGesture { tap in
            self.chooseApplication()
        }
        
    }
    
    @objc private func typeSegmentPicker(sender: UISegmentedControl?) {
        DDLogDebug("切换了类型，\(sender?.selectedSegmentIndex ?? -1)")
        switch sender?.selectedSegmentIndex {
        case 1:
            self.processView.isHidden = true
            self.applicationView.isHidden = false
            self.type = "application"
            break
        case 2:
            self.processView.isHidden = false
            self.applicationView.isHidden = true
            self.type = "process"
            break
        default:
            self.processView.isHidden = true
            self.applicationView.isHidden = true
            self.type = "all"
            break
        }
    }
    
    ///
    /// 查询当前用户的身份列表
    /// 
    private func loadCurrentIdentities() {
        self.showLoading()
        self.viewModel.newMyInfo().then { person in
            self.reciveIdentity(person: person)
        }.catch { err in
            self.showError(title: "\(err.localizedDescription), 个人信息载入出错!")
        }
    }
    
    
    private func reciveIdentity(person: O2PersonInfo) {
        self.hideLoading()
        self.identitys = person.woIdentityList ?? []
        self.identityBaseViewHeight.constant = (self.identitys.count * 94 + 20).toCGFloat
        self.setupIdentityUI()
    }
    
    /// 身份选择的 UI 创建
    private func setupIdentityUI() {
        self.identityViews = []
        self.identityBaseView.removeSubviews()
        
        var i = 0
        self.identitys.forEach { (identity) in
            self.initIdentityView(id: identity, top: (i.toCGFloat * 94 + 20))
            i += 1
        }
        self.identityViews.first?.selectedIdentity()
        self.fIdentity = self.identityViews.first?.o2Id
    }

    private func initIdentityView(id: O2IdentityInfo, top: CGFloat) {
        let view = Bundle.main.loadNibNamed("IdentitySelectView", owner: self, options: nil)?.first as! IdentitySelectView
        view.frame = CGRect(x: 0, y: 0, width: self.identityBaseView.bounds.width, height: 94)
        view.setUpO2Id(identity: id)
        self.identityViews.append(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        self.identityBaseView.addSubview(view)

        let topC = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: view.superview!, attribute: .top, multiplier: 1, constant: top)
        let leftC = NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: view.superview!, attribute: .leading, multiplier: 1, constant: 0)
        let rightC = NSLayoutConstraint(item: view.superview!, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([topC, leftC, rightC])
        
        view.addTapGesture { (tap) in
            let id = view.o2Id?.distinguishedName
            self.identityViews.forEach { (i) in
                if i.o2Id?.distinguishedName == id {
                    self.fIdentity = i.o2Id
                    i.selectedIdentity()
                } else {
                    i.deSelectedIdentity()
                }
            }
        }
    }
    
    ///
    /// 选择委托人
    ///
    private func chooseToPerson() {
        if let v = ContactPickerViewController.providePickerVC(
            pickerModes: [ContactPickerType.identity],
            multiple: false,
            pickedDelegate: { (result: O2BizContactPickerResult) in
                if let ids = result.identities, ids.count > 0, let dn = ids[0].distinguishedName {
                    self.toPersonLabel.text = ids[0].name
                    self.toPerson = dn
                }
            }
        ) {
            self.show(v, sender: nil)
        }
    }
    
    ///
    /// 选择授权开始时间
    ///
    private func chooseStartTime() {
        let picker = QDatePicker{ (date: String) in
            DDLogDebug("选择开始时间 \(date)")
            self.startTime = date
            self.startTimeLabel.text = date
        }
        picker.themeColor = O2ThemeManager.color(for: "Base.base_color")!
        picker.datePickerStyle = .YMDHM
        picker.pickerStyle = .datePicker
        picker.showDatePicker(defaultDate: Date())
    }
    
    ///
    /// 选择授权结束时间
    private func chooseCompleteTime() {
        let picker = QDatePicker{ (date: String) in
            DDLogDebug("选择结束时间 \(date)")
            self.completeTime = date
            self.completeTimeLabel.text = date
        }
        picker.themeColor = O2ThemeManager.color(for: "Base.base_color")!
        picker.datePickerStyle = .YMDHM
        picker.pickerStyle = .datePicker
        picker.showDatePicker(defaultDate: Date())
    }
    ///
    /// 选择流程应用
    ///
    private func chooseApplication() {
        let storyBoard = UIStoryboard(name: "task", bundle: nil)
        guard let chooseVc =  storyBoard.instantiateViewController(withIdentifier: "processApplicationChooseVC") as? ZoneMenuViewController else {
            DDLogError("没有获取到选择器!")
            return
        }
        chooseVc.callback = { app, process in
            if let app = app {
                self.application = app
                self.applicationNameLabel.text = app.name
            }
        }
        chooseVc.chooseMode = .application
        self.show(chooseVc, sender: nil)
    }
    
    ///
    /// 选择流程
    /// 
    private func chooseProcess() {
        let storyBoard = UIStoryboard(name: "task", bundle: nil)
        guard let chooseVc =  storyBoard.instantiateViewController(withIdentifier: "processApplicationChooseVC") as? ZoneMenuViewController else {
            DDLogError("没有获取到选择器!")
            return
        }
        chooseVc.callback = { app, process in
            if let process = process {
                self.process = process
                self.processNameLabel.text = process.name
            }
        }
        chooseVc.chooseMode = .process
        self.show(chooseVc, sender: nil)
    }
    
    @objc private func postForm() {
        
        guard let fromPerson = self.fIdentity?.distinguishedName else {
            self.showError(title: "请选择当前人员身份！")
            return
        }
        guard let toPerson = self.toPerson else {
            self.showError(title: "请选择委托人！")
            return
        }
        if self.startTime.isEmpty {
            self.showError(title: "请选择开始时间！")
            return
        }
        if self.completeTime.isEmpty {
            self.showError(title: "请选择结束时间！")
            return
        }
        if self.completeTime <= self.startTime {
            self.showError(title: "结束时间不能小于开始时间！")
            return
        }
        DDLogDebug("fromPerson \(fromPerson) toPerson \(toPerson) startTime \(self.startTime) completeTime \(self.completeTime)")
        let form = EmpowerData()
        form.fromIdentity = fromPerson
        form.toIdentity = toPerson
        form.startTime = self.startTime+":00"
        form.completedTime = self.completeTime+":00"
        
        if self.type == "application" {
            guard let app = self.application else {
                self.showError(title: "请选择应用！")
                return
            }
            form.application = app.id
            form.applicationName = app.name
            form.applicationAlias = app.alias
        }
        if self.type == "process" {
            guard let process = self.process else {
                self.showError(title: "请选择流程！")
                return
            }
            form.process = process.id
            form.processName = process.name
            form.processAlias = process.alias
            form.edition = process.edition
        }
    
        DDLogDebug("type \(self.type)")
        form.type = self.type
        form.enable = true
        self.showLoading()
        self.viewModel.empowerCreate(body: form).then { result in
            self.hideLoading()
            self.closeself()
        }.catch { error in
            self.showError(title: "错误：\(error)")
        }
    }
    
    private func closeself() {
        DispatchQueue.main.async {
            self.popVC()
        }
    }

}
