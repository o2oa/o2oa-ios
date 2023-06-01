//
//  O2SearchController.swift
//  O2Platform
//
//  Created by FancyLou on 2021/5/21.
//  Copyright © 2021 zoneland. All rights reserved.
//

import UIKit
import CocoaLumberjack

class O2SearchController: UIViewController {
    
    private lazy var viewmodel: O2SearchViewModel = {
        return O2SearchViewModel()
    }()
    
    /// 查询结果 ListView
    fileprivate lazy var tableview: UITableView = {
        var tableview = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: self.view.height - TAB_BAR_HEIGHT))
        tableview.delegate = self
        tableview.dataSource = self
        tableview.backgroundColor = UIColor(hex: "#F5F5F5")
        tableview.register(UINib(nibName: "O2SearchResultCell", bundle: nil), forCellReuseIdentifier: "O2SearchResultCell")
        tableview.separatorStyle = .none
        return tableview
    }()
    
    /// 空数据的View
    fileprivate lazy var emptyView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: self.view.height - TAB_BAR_HEIGHT))
        view.backgroundColor = UIColor(hex: "#F5F5F5")
        let wuImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 260, height: 163.5))
        wuImage.image = UIImage(named: "pic_wu")
        view.addSubview(wuImage)
        wuImage.snp.makeConstraints { (maker) in
            maker.center.equalToSuperview()
        }
        
        let tips = UILabel()
        tips.text = L10n.Search.searchNoResult
        tips.textColor = UIColor(hex: "#B3B3B3")
        tips.sizeToFit()
        view.addSubview(tips)
        tips.snp.makeConstraints { (maker) in
            maker.top.equalTo(wuImage.snp.bottom).offset(20)
            maker.centerX.equalToSuperview()
        }
        return view
    }()
    
    /// 历史查询关键字
    fileprivate lazy var historyView: O2SearchHistoryView = {
        let view = O2SearchHistoryView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: self.view.height - TAB_BAR_HEIGHT))
        return view
    }()
    
    // 搜索框
    private var searchBar: UISearchBar?
    private var searchKey: String = ""
    private var resultList: [O2SearchV2Entry] = []
    private var page = 1
    private var totalPage = 1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = L10n.Search.search
        self.view.backgroundColor = UIColor(hex: "#F5F5F5")
        view.addSubview(tableview)
        //分页刷新功能
        self.tableview.mj_header = MJRefreshNormalHeader(refreshingBlock: {
           self.search()
        })
        
        self.tableview.mj_footer = MJRefreshAutoFooter(refreshingBlock: {
            self.morePage()
        })
        view.addSubview(emptyView)
        emptyView.isHidden = true
        view.addSubview(historyView)
        historyView.delegate = self
        self.searchBarInit()
        // 获取焦点
        self.searchBar?.becomeFirstResponder()
    }
     
    /// 初始化 搜索框
    private func searchBarInit() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 250, height: 28))
        view.backgroundColor = self.navigationController?.navigationBar.tintColor
        view.layer.cornerRadius = 14
        view.layer.masksToBounds = true
        self.searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 250, height: 28))
        self.searchBar?.placeholder = L10n.Search.placeholder
        self.searchBar?.layer.cornerRadius = 14
        self.searchBar?.layer.masksToBounds = true
        self.searchBar?.backgroundColor = .white
        self.searchBar?.delegate = self
        self.searchBar?.setImage(O2ThemeManager.image(for: "Icon.icon_sousuo"), for: .search, state: .normal)
        view.addSubview(self.searchBar!)
        self.navigationItem.titleView = view
    }
    
    
    /// 查询数据
    private func search() {
        DDLogDebug("search key \(self.searchKey)")
        self.page = 1
        if self.searchKey != "" {
            self.showLoading()
            self.viewmodel.searchV2(key: self.searchKey, page: self.page).then { result in
                if let result = result {
                    self.resultList = result.documentList
                    if result.count > O2.defaultPageSize {
                        let m = result.count % O2.defaultPageSize
                        if m > 0 {
                            self.totalPage = (result.count / O2.defaultPageSize) + 1
                        } else {
                            self.totalPage = (result.count / O2.defaultPageSize)
                        }
                    } else {
                        self.totalPage = 1
                    }
                    self.refreshUI()
                }
            }.always {
                self.hideLoading()
            }.catch { err in
                DDLogError(err.localizedDescription)
                self.showError(title: L10n.errorWithMsg(err.localizedDescription))
            }
//            self.viewmodel.search(key: self.searchKey).then { (page) in
//                self.resultList = page.list
//                self.page = 1
//                self.totalPage = page.totalPage
//                self.refreshUI()
//            }.always {
//                self.hideLoading()
//            }.catch { (err) in
//                DDLogError(err.localizedDescription)
//                self.showError(title: L10n.errorWithMsg(err.localizedDescription))
//            }
        } else {
            self.resultList = []
            self.refreshUI()
        }
    }
    
    private func morePage() {
        DDLogDebug("morePage page \(self.page) total \(self.totalPage)")
        if self.page < self.totalPage {
            self.showLoading()
            self.page += 1
            self.viewmodel.searchV2(key: self.searchKey, page: self.page).then { result in
                if let result = result {
                    result.documentList.forEach { entry in
                        self.resultList.append(entry)
                    }
                    if result.count > O2.defaultPageSize {
                        let m = result.count % O2.defaultPageSize
                        if m > 0 {
                            self.totalPage = (result.count / O2.defaultPageSize) + 1
                        } else {
                            self.totalPage = (result.count / O2.defaultPageSize)
                        }
                    } else {
                        self.totalPage = 1
                    }
                    self.refreshUI()
                }
            }.always {
                self.hideLoading()
            }.catch { (err) in
                DDLogError(err.localizedDescription)
                self.showError(title: L10n.errorWithMsg(err.localizedDescription))
            }
        }
    }
    
    // 刷新页面
    private func refreshUI() {
        DDLogDebug("refreshUI page \(self.page) total \(self.totalPage)")
        self.tableview.reloadData()
        if self.resultList.count > 0 {
            self.emptyView.isHidden = true
            self.tableview.isHidden = false
        } else {
            self.tableview.isHidden = true
            self.emptyView.isHidden = false
        }
    }
    
    
    /// 打开文档
    private func openCmsPage(id: String, title: String) {
        let bbsStoryboard = UIStoryboard(name: "information", bundle: Bundle.main)
        let destVC = bbsStoryboard.instantiateViewController(withIdentifier: "CMSSubjectDetailVC") as! CMSItemDetailViewController
        destVC.documentId = id
        destVC.title = title
        destVC.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(destVC, animated: false)
    }
    /// 根据job获取工作列表
    private func loadWorkWithJob(job: String) {
        self.viewmodel.loadWorkByJob(jobId: job).then { workData in
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
                todoTaskDetailVC.modalPresentationStyle = .fullScreen
                self.pushVC(todoTaskDetailVC)
            }
        }
    }
    /// 打开工作
    private func openWorkPage(work: String, title: String) {
        if work.isEmpty {
            DDLogError("没有传入work id")
            self.showError(title: "参数不正确！")
            return
        }
        let storyBoard = UIStoryboard(name: "task", bundle: nil)
        let destVC = storyBoard.instantiateViewController(withIdentifier: "todoTaskDetailVC") as! TodoTaskDetailViewController
        let json = """
        {"work":"\(work)", "workCompleted":"", "title":"\(title)"}
        """
        let todo = TodoTask(JSONString: json)
        destVC.todoTask = todo
        destVC.backFlag = 3 //隐藏就行
        self.show(destVC, sender: nil)
    }
    
}

extension O2SearchController: UISearchBarDelegate {
    /// 点击输入法搜索按钮
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let key = searchBar.text
        DDLogDebug("搜索关键字： \(key ?? "无")")
        if key != nil && key != "" {
            self.historyView.addSearchHistory(key: key!)
        }
        self.historyView.isHidden = true // 隐藏搜索历史
        searchBar.endEditing(true)
        self.searchKey = key ?? ""
        self.search()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count == 0 { // 清空了
            self.resultList = []
            self.searchKey = ""
            self.page = 1
            self.totalPage = 1
            self.tableview.reloadData()
            self.historyView.isHidden = false
            self.tableview.isHidden = true
        }
    }
}

extension O2SearchController: O2SearchHistoryDelegate {
    /// 点击搜索历史
    func clickToSearchTag(tag: String) {
        DDLogDebug("查询tag： \(tag)")
        self.historyView.isHidden = true // 隐藏搜索历史
        self.searchBar?.text = tag
        self.searchBar?.endEditing(true)
        self.searchKey = tag
        self.search()
    }
}

extension O2SearchController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.resultList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableview.dequeueReusableCell(withIdentifier: "O2SearchResultCell") as? O2SearchResultCell {
            cell.setDataV2(data: self.resultList[indexPath.row], currentKey: self.searchKey)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableview.deselectRow(at: indexPath, animated: false)
        let entry = self.resultList[indexPath.row]
        if entry.category == "cms" {
            self.openCmsPage(id: entry.id, title: entry.title)
        } else {
            self.loadWorkWithJob(job: entry.id)
//            self.openWorkPage(work: entry.id, title: entry.title )
        }
    }
    
    
    
    /// Cell 圆角背景计算
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //圆率
        let cornerRadius:CGFloat = 10.0
        //大小
        let bounds:CGRect  = cell.bounds
        //绘制曲线
//        var bezierPath: UIBezierPath? = nil
        //一个为一组时,四个角都为圆角
        let bezierPath: UIBezierPath? = UIBezierPath(roundedRect: bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        //cell的背景色透明
        cell.backgroundColor = .clear
        //新建一个图层
        let layer = CAShapeLayer()
        //图层边框路径
        layer.path = bezierPath?.cgPath
        //图层填充色,也就是cell的底色
        layer.fillColor = UIColor.white.cgColor
        //图层边框线条颜色
        /*
         如果self.tableView.style = UITableViewStyleGrouped时,每一组的首尾都会有一根分割线,目前我还没找到去掉每组首尾分割线,保留cell分割线的办法。
         所以这里取巧,用带颜色的图层边框替代分割线。
         这里为了美观,最好设为和tableView的底色一致。
         设为透明,好像不起作用。
         */
        layer.strokeColor = UIColor.white.cgColor
        //将图层添加到cell的图层中,并插到最底层
        cell.layer.insertSublayer(layer, at: 0)
        
    }
    
}
