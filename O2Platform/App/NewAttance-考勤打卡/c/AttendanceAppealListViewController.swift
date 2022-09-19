//
//  AttendanceAppealListViewController.swift
//  O2Platform
//
//  Created by FancyLou on 2022/9/19.
//  Copyright © 2022 zoneland. All rights reserved.
//

import UIKit
import CocoaLumberjack

class AttendanceAppealListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var bttomToolBar: UIStackView!
    
    @IBOutlet weak var DisagreeBtn: UIButton!
    
    @IBOutlet weak var AgreeBtn: UIButton!
    
    
    private lazy var viewModel: OOAttandanceViewModel = {
        return OOAttandanceViewModel()
    }()
    
    /// 空数据的View
    fileprivate lazy var emptyView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - TAB_BAR_HEIGHT))
        view.backgroundColor = UIColor(hex: "#F5F5F5")
        let wuImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 260, height: 163.5))
        wuImage.image = UIImage(named: "pic_wu")
        view.addSubview(wuImage)
        wuImage.snp.makeConstraints { (maker) in
            maker.center.equalToSuperview()
        }
        
        let tips = UILabel()
        tips.text = "没有数据"
        tips.textColor = UIColor(hex: "#B3B3B3")
        tips.sizeToFit()
        view.addSubview(tips)
        tips.snp.makeConstraints { (maker) in
            maker.top.equalTo(wuImage.snp.bottom).offset(20)
            maker.centerX.equalToSuperview()
        }
        return view
    }()
        
    private var list:[AppealInfoJson] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "申诉审批"
        self.tableView.allowsMultipleSelection = true
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(UINib(nibName: "AttendanceAppealInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "AttendanceAppealInfoTableViewCell")
        self.tableView.tableFooterView = UIView()
        self.view.addSubview(self.emptyView)
        self.emptyView.isHidden = true
        loadListData()
    }

    @IBAction func DisagreeClickAction(_ sender: UIButton) {
        if let count = self.tableView.indexPathsForSelectedRows?.count, count > 0 {
            self.approvel(selected: self.tableView.indexPathsForSelectedRows!, isAgree: false)
        } else {
            self.showError(title: "请先选择需要审批的数据！")
        }
    }
    
    @IBAction func AgreeClickAction(_ sender: UIButton) {
        if let count = self.tableView.indexPathsForSelectedRows?.count, count > 0 {
            self.approvel(selected: self.tableView.indexPathsForSelectedRows!, isAgree: true)
        } else {
            self.showError(title: "请先选择需要审批的数据！")
        }
    }
     
    // 审批
    private func approvel(selected: [IndexPath], isAgree: Bool) {
        let form = AppealApprovalFormJson()
        let ids = selected.map { indexPath -> String in
            let info = self.list[indexPath.row]
            return info.id ?? ""
        }
        form.ids = ids
        form.status = isAgree ? "1" : "-1"
        
        viewModel.attendanceappealInfoApprovel(form: form) { result in
            switch result {
            case .ok(_):
                self.loadListData()
                break
            case .fail(let errorMessage):
                DDLogError(errorMessage)
                self.showError(title: "审批失败！")
                break
            default:
                break
            }
        }
        
    }
    
    
    private func loadListData() {
        let filter = AppealApprovalQueryFilterJson()
        filter.status = "0"//未处理的
        filter.processPerson1 =  O2AuthSDK.shared.myInfo()?.distinguishedName
        filter.yearString = Date().formatterDate(formatter: "yyyy")
        
        viewModel.attendanceAppealInfoList(lastId: O2.O2_First_ID, filter: filter, completedBlock: {(result) in
            switch result {
            case .ok(let res):
                if let resultList = res as? [AppealInfoJson] {
                    self.list = resultList
                }
                self.tableView.reloadData()
                if (self.list.count > 0) {
                    self.emptyView.isHidden = true
                    self.bttomToolBar.isHidden = false
                } else {
                    self.emptyView.isHidden = false
                    self.bttomToolBar.isHidden = true
                }
                break
            case .fail(let errorMessage):
                DDLogError(errorMessage)
                self.showError(title: "获取数据失败！")
                break
            default:
                break
            }
        })
    }
}

extension AttendanceAppealListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "AttendanceAppealInfoTableViewCell", for: indexPath) as? AttendanceAppealInfoTableViewCell {
            // 标记对勾的颜色
            cell.tintColor = UIColor.green
            //判断是否选中,如果 tableView有 select 的 row ,就把 cell 标记checkmark
            if let _ = tableView.indexPathsForSelectedRows?.firstIndex(of: indexPath){
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            let info = self.list[indexPath.row]
            cell.setInfo(info: info)
            return cell
        }
        return UITableViewCell()
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .none
    }
    
    
}
