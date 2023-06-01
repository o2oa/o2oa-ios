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
    
    private var config: AttendanceV2Config? = nil
    
        
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
        self.loadConfig()
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
            self.startCheck(appeal: item)
        } else if !item.jobId.isEmpty {
            DDLogInfo("查看流程")
            self.loadWorkWithJob(job: item.jobId)
        }
    }
    
    private func loadConfig() {
        self.viewModel.v2Config().then { config in
            self.config = config
        }.catch { error in
            DDLogError("\(error.localizedDescription)")
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
     
    
    /// 检查是否能够申诉
    private func startCheck(appeal: AttendanceV2AppealInfo) {
        if self.config != nil  && self.config?.appealEnable == true && !self.config!.processId.isEmpty {
            
            self.showDefaultConfirm(title: "提示", message: "确定要发起申诉流程？") { action in
                self.viewModel.appealCheckCanStartProcess(id: appeal.id).then { result in
                    if result.value == true {
                        let processData = AttendanceV2AppealInfoToProcessData()
                        processData.appealId = appeal.id
                        processData.record = appeal.record
                        self.loadIdentityWithProcess(processId: self.config!.processId, processData: processData)
                    } else {
                        self.showError(title: "当前无法申诉！")
                    }
                }.catch { error in
                    if error is OOAppError, let msg = (error as? OOAppError)?.errorDescription {
                        self.showError(title: "\(msg)")
                    } else {
                        self.showError(title: "当前无法申诉！")
                    }
                }
            }
        }
    }
    /// 当前流程 当前用户的可启动的身份列表
    private func loadIdentityWithProcess(processId: String, processData: AttendanceV2AppealInfoToProcessData)  {
        self.showLoading()
        self.viewModel.loadAppealProcessAvailableIdentity(processId: processId).then { identities in
            self.hideLoading()
            if identities.count == 1 {
                self.startProcess(processId: processId, identity: identities[0].distinguishedName!, processData: processData)
            } else {
                var actions: [UIAlertAction] = []
                identities.forEach({ (identity) in
                    let action = UIAlertAction(title: "\(identity.name!)(\(identity.unitName!))", style: .default, handler: { (a) in
                        self.startProcess(processId: processId, identity: identity.distinguishedName!, processData: processData)
                    })
                    actions.append(action)
                })
                self.showSheetAction(title: "提示", message: "请选择启动流程的身份", actions: actions)
            }
        }.catch { error in
            DDLogError("\(error.localizedDescription)")
            if error is OOAppError, let msg = (error as? OOAppError)?.errorDescription {
                self.showError(title: "\(msg)")
            } else {
                self.showError(title: "请求身份出错！")
            }
        }
    }
    /// 启动流程
    private func startProcess(processId: String, identity: String, processData: AttendanceV2AppealInfoToProcessData) {
        self.showLoading()
        self.viewModel.startProcess(processId: processId, identity: identity, processData: processData).then { (res) in
            self.updateAppealStatus(appealId: processData.appealId, jobId: res.job ?? "")
            if let taskList = res.taskList, taskList.count > 0 {
                self.hideLoading()
                self.openWork(task:  taskList[0].copyToTodoTask() )
            } else {
                self.showSuccess(title: "启动流程成功！")
            }
            self.tableView.mj_header.beginRefreshing()
            }.catch { (error) in
                self.showError(title: "启动流程出错！")
        }
    }
    
    private func updateAppealStatus(appealId: String, jobId: String) {
        self.viewModel.appealStartProcess(id: appealId, jobId: jobId).then { value in
            DDLogInfo("更新状态完成，\(value.value ?? false)")
            self.tableView.mj_header.beginRefreshing()
        }.catch { error in
            DDLogError("\(error.localizedDescription)")
            self.tableView.mj_header.beginRefreshing()
        }
    }
    /// 根据job获取工作列表
    private func loadWorkWithJob(job: String) {
        self.viewModel.loadWorkByJob(jobId: job).then { workData in
            var workList: [WorkData] = []
            if !workData.workList.isEmpty {
                for work in workData.workList {
                    work.completed = false
                    workList.append(work)
                }
            }
            if !workData.workCompletedList.isEmpty {
                for workCompleted in workData.workCompletedList {
                    workCompleted.completed = true
                    workList.append(workCompleted)
                }
            }
            if !workList.isEmpty {
                if workList.count > 1 {
                    var actions: [UIAlertAction] = []
                    for work in workList {
                        let action = UIAlertAction(title: "\(work.title ?? "")【\(work.processName ?? "")】\(work.completed == true ? "已完成": "")", style: .default, handler: { (a) in
                            let task = TodoTask.init(JSON: [:])
                            if work.completed == true {
                                task?.work = work.id
                            } else {
                                task?.workCompleted = work.id
                            }
                            self.openWork(task: task)
                        })
                        actions.append(action)
                    }
                    self.showSheetAction(title: "提示", message: "请选择需要打开的工作", actions: actions)
                } else {
                    let task = TodoTask.init(JSON: [:])
                    if workList[0].completed == true {
                        task?.work = workList[0].id
                    } else {
                        task?.workCompleted = workList[0].id
                    }
                    self.openWork(task: task)
                }
            } else {
                self.showError(title: "没有找到工作！")
            }
        }.catch { err in
            DDLogError("\(err.localizedDescription)")
            self.showError(title: "没有找到工作！")
        }
    }
    
    /// 打开工作
    private func openWork(task: TodoTask?) {
        if task != nil {
            DispatchQueue.main.async {
                let taskStoryboard = UIStoryboard(name: "task", bundle: Bundle.main)
                let todoTaskDetailVC = taskStoryboard.instantiateViewController(withIdentifier: "todoTaskDetailVC") as! TodoTaskDetailViewController
                todoTaskDetailVC.todoTask = task
                todoTaskDetailVC.backFlag = 3
                self.pushVC(todoTaskDetailVC)
            }
        }
    }
    
    
}
