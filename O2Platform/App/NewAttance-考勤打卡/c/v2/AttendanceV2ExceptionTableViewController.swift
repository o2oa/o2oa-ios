//
//  AttendanceV2ExceptionTableViewController.swift
//  O2Platform
//
//  Created by FancyLou on 2023/4/19.
//  Copyright © 2023 zoneland. All rights reserved.
//

import UIKit
import CocoaLumberjack

class AttendanceV2ExceptionTableViewController: UITableViewController {
    
    private lazy var viewModel: OOAttandanceViewModel = {
        return OOAttandanceViewModel()
    }()
    
    private var list:[AttendanceV2AppealInfo] = []
    private var page = 1 //
    private var isLoading = false
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "考勤异常数据"
        self.tableView.register(UINib(nibName: "AttendanceV2ExceptionDataViewCell", bundle: nil), forCellReuseIdentifier: "AttendanceV2ExceptionDataViewCell")
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            if self.isLoading {
                return
            }
            DDLogDebug("下拉刷新？？？")
            self.page = 1
            self.loadData()
        })
        self.tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {
            if self.isLoading {
                return
            }
            DDLogDebug("上拉加载。。。。。。。。。。。。")
            self.page += 1
            self.loadData()
        })
    }
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.mj_header.beginRefreshing()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "AttendanceV2ExceptionDataViewCell", for: indexPath) as? AttendanceV2ExceptionDataViewCell {
            cell.setData(appeal: self.list[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: false)
        let item = self.list[indexPath.row]
        if item.status == 0 {
            DDLogInfo("发起流程")
        } else if !item.jobId.isEmpty {
            DDLogInfo("查看流程")
        }
    }
    
    
    private func loadData() {
        if self.isLoading { // 正在查询
            return
        }
        self.isLoading = true
        if self.page == 1 {
            self.list = []
        }
        self.viewModel.appealListByPage(page: self.page).then { resultList in
            for item in resultList {
                self.list.append(item)
            }
            self.endRefresh(resultList: resultList)
        }.catch { error in
            self.showError(title: "\(error.localizedDescription)")
            self.endRefresh(resultList: [])
        }
    }
    
    private func endRefresh(resultList: [AttendanceV2AppealInfo]) {
        if resultList.count < O2.defaultPageSize {
            self.tableView.mj_footer.endRefreshingWithNoMoreData()
        }else{
            self.tableView.mj_footer.endRefreshing()
        }
        self.tableView.mj_header.endRefreshing()
        self.tableView.reloadData()
        self.isLoading = false
    }
     
    
}
