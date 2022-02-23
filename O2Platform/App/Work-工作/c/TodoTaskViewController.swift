//
//  TodoTaskViewController.swift
//  O2Platform
//
//  Created by 刘振兴 on 16/8/1.
//  Copyright © 2016年 zoneland. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import AlamofireObjectMapper

import ObjectMapper

import CocoaLumberjack


struct TaskURLGenenater {
    var url:String
    var pageModel:CommonPageModel
    
    func pagingURL() -> String {
        var tUrl = self.url
        tUrl = AppDelegate.o2Collect.setRequestParameter(tUrl, requestParameter:self.pageModel.toDictionary() as [String : AnyObject]?)!
        return tUrl.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
    }
}

class TodoTaskViewController: UITableViewController {
    
    var segmentedControl:SegmentedControl!
    
//    var currentTaskURLGenenater:TaskURLGenenater!
    
    var models:[TodoCellModel<TodoTaskData>] = []
    
//    var filterModels:[TodoCellModel<TodoTaskData>] = []
    
    var emptyTexts:[String] = ["没有要处理的待办","没有要处理的待阅","没有已办数据","没有已阅数据"]
    
//    var urls:[Int:TaskURLGenenater] {
//        let todoTaskURL = AppDelegate.o2Collect.generateURLWithAppContextKey(TaskContext.taskContextKey, query: TaskContext.todoTaskListQuery, parameter: nil,coverted: false)
//
//        let todoedTaskURL = AppDelegate.o2Collect.generateURLWithAppContextKey(TaskedContext.taskedContextKey, query: TaskedContext.taskedListByPageSizeQuery, parameter: nil,coverted: false)
//
//        let readTaskURL = AppDelegate.o2Collect.generateURLWithAppContextKey(ReadContext.readContextKey, query: ReadContext.readListByPageSizeQuery, parameter: nil,coverted: false)
//
//        let readedTaskURL = AppDelegate.o2Collect.generateURLWithAppContextKey(ReadedContext.readedContextKey, query: ReadedContext.readedListByPageSizeQuery, parameter: nil,coverted: false)
//
//        return [0: TaskURLGenenater(url: todoTaskURL!,pageModel: CommonPageModel()),2: TaskURLGenenater(url: todoedTaskURL!,pageModel: CommonPageModel()),1 : TaskURLGenenater(url: readTaskURL!,pageModel: CommonPageModel()),3: TaskURLGenenater(url: readedTaskURL!,pageModel: CommonPageModel())]
//    }
//
//
//    //添加搜索功能
//    var fileterUrls:[Int:TaskURLGenenater] {
//        let todoTaskURL = AppDelegate.o2Collect.generateURLWithAppContextKey(TaskContext.taskContextKey, query: TaskContext.todoTaskListFilterQuery, parameter: nil,coverted: false)
//
//        let todoedTaskURL = AppDelegate.o2Collect.generateURLWithAppContextKey(TaskedContext.taskedContextKey, query: TaskedContext.taskedListByPageSizeFilterQuery, parameter: nil,coverted: false)
//
//        let readTaskURL = AppDelegate.o2Collect.generateURLWithAppContextKey(ReadContext.readContextKey, query: ReadContext.readListByPageSizeFilterQuery, parameter: nil,coverted: false)
//
//        let readedTaskURL = AppDelegate.o2Collect.generateURLWithAppContextKey(ReadedContext.readedContextKey, query: ReadedContext.readedListByPageSizeFilterQuery, parameter: nil,coverted: false)
//
//        return [0: TaskURLGenenater(url: todoTaskURL!,pageModel: CommonPageModel()),2: TaskURLGenenater(url: todoedTaskURL!,pageModel: CommonPageModel()),1 : TaskURLGenenater(url: readTaskURL!,pageModel: CommonPageModel()),3: TaskURLGenenater(url: readedTaskURL!,pageModel: CommonPageModel())]
//    }
    
    //搜索文本
    var searchText = ""

    //搜索控件
    var searchController:UISearchController = UISearchController(searchResultsController: nil)
    
    //分页查询 最后一条数据的id
    var lastId = O2.O2_First_ID
    
    var isRefresh = false
    
    private lazy var viewModel: WorkViewModel = {
        return WorkViewModel()
    }()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = ""
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initSegmentedControl()
        //添加搜索功能
        self.searchController.searchResultsUpdater = self
        self.searchController.delegate = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).title = "取消"
        let attrs =  [NSAttributedString.Key.font: UIFont.init(name: "PingFangTC-Light", size: 14) ?? UIFont.systemFont(ofSize: 14),
         NSAttributedString.Key.foregroundColor: O2ThemeManager.color(for: "Base.base_color") ?? UIColor.red]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(attrs, for: .normal)
        self.searchController.searchBar.searchBarStyle = UISearchBar.Style.minimal
        self.searchController.searchBar.sizeToFit()
        //设置搜索框是否显示
        self.setSearchBarIsShow()
        
        //分页刷新功能
        self.tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {
           self.headerLoadData()
        })
        
        self.tableView.mj_footer = MJRefreshAutoFooter(refreshingBlock: {
            self.footerLoadData()
        })
        self.headerLoadData()
    }
    
    //隐藏搜索框
    func setSearchBarIsShow(){
        let taskIndex = AppConfigSettings.shared.taskIndex
        if taskIndex ==  2 {
            self.tableView.tableHeaderView = self.searchController.searchBar
        }else{
            if self.searchController.isActive {
                self.searchController.isActive = false
            }
            self.tableView.tableHeaderView = nil
        }
    }
    
    /// 刷新数据
    func headerLoadData(){
        DDLogDebug("加载数据。。。。。。。。。")
        let taskIndex = AppConfigSettings.shared.taskIndex
        self.isRefresh = true
        self.lastId = O2.O2_First_ID
        self.loadDataList(taskIndex: taskIndex)
    }
    
    /// 加载数据
    func footerLoadData(){
        DDLogDebug("获取更多数据。。。。。。。。。。。。。。")
        let taskIndex = AppConfigSettings.shared.taskIndex
        self.loadDataList(taskIndex: taskIndex)
    }
    
    
    private func loadDataList(taskIndex: Int) {
        let tv = self.tableView as! ZLBaseTableView
        tv.emptyTitle = self.emptyTexts[taskIndex]
        switch taskIndex {
        case 0:
            self.viewModel.taskListNext(lastId: self.lastId).then { (list) in
                if self.isRefresh {
                    self.models.removeAll()
                }
                if (list.count > 0) {
                    self.lastId = list[list.count-1].sourceObj?.id ?? O2.O2_First_ID
                    for item in list {
                        self.models.append(item)
                    }
                }
                self.isRefresh = false
                self.tableView.reloadData()
            }.always {
                if tv.mj_header.isRefreshing(){
                    tv.mj_header.endRefreshing()
                }
            }.catch { (err) in
                DispatchQueue.main.async {
                    DDLogError(err.localizedDescription)
                    self.showError(title: "查询失败！")
                }
            }
            break
        case 1:
            self.viewModel.readListNext(lastId: self.lastId).then { (list) in
                if self.isRefresh {
                    self.models.removeAll()
                }
                if (list.count > 0) {
                    self.lastId = list[list.count-1].sourceObj?.id ?? O2.O2_First_ID
                    for item in list {
                        self.models.append(item)
                    }
                }
                self.isRefresh = false
                self.tableView.reloadData()
            }.always {
                if tv.mj_header.isRefreshing(){
                    tv.mj_header.endRefreshing()
                }
            }.catch { (err) in
                DispatchQueue.main.async {
                    DDLogError(err.localizedDescription)
                    self.showError(title: "查询失败！")
                }
            }
            break
        case 2:
            self.viewModel.taskcompletedListNext(lastId: self.lastId, key: self.searchText).then { (list) in
                if self.isRefresh {
                    self.models.removeAll()
                }
                if (list.count > 0) {
                    self.lastId = list[list.count-1].sourceObj?.id ?? O2.O2_First_ID
                    for item in list {
                        self.models.append(item)
                    }
                }
                self.isRefresh = false
                self.tableView.reloadData()
            }.always {
                if tv.mj_header.isRefreshing(){
                    tv.mj_header.endRefreshing()
                }
            }.catch { (err) in
                DispatchQueue.main.async {
                    DDLogError(err.localizedDescription)
                    self.showError(title: "查询失败！")
                }
            }
            break
        case 3:
            self.viewModel.readcompletedListNext(lastId: self.lastId).then { (list) in
                if self.isRefresh {
                    self.models.removeAll()
                }
                if (list.count > 0) {
                    self.lastId = list[list.count-1].sourceObj?.id ?? O2.O2_First_ID
                    for item in list {
                        self.models.append(item)
                    }
                }
                self.isRefresh = false
                self.tableView.reloadData()
            }.always {
                if tv.mj_header.isRefreshing(){
                    tv.mj_header.endRefreshing()
                }
            }.catch { (err) in
                DispatchQueue.main.async {
                    DDLogError(err.localizedDescription)
                    self.showError(title: "查询失败！")
                }
            }
            break
        default:
            break
        }
    }
    
    
    //初始化控件
    func initSegmentedControl(){
        let titleStrings = ["待办", "待阅", "已办", "已阅"]
        let titles: [NSAttributedString] = {
            let attributes = [NSAttributedString.Key.font: UIFont(name: "PingFangSC-Regular", size: 17.0)!
                , NSAttributedString.Key.foregroundColor: UIColor.white]
            var titles = [NSAttributedString]()
            for titleString in titleStrings {
                let title = NSAttributedString(string: titleString, attributes: attributes)
                titles.append(title)
            }
            return titles
        }()
        let selectedTitles: [NSAttributedString] = {
            let attributes = [NSAttributedString.Key.font: UIFont(name: "PingFangSC-Regular", size: 17.0)!, NSAttributedString.Key.foregroundColor: UIColor.darkGray]
            var selectedTitles = [NSAttributedString]()
            for titleString in titleStrings {
                let selectedTitle = NSAttributedString(string: titleString, attributes: attributes)
                selectedTitles.append(selectedTitle)
            }
            return selectedTitles
        }()
        segmentedControl = SegmentedControl.initWithTitles(titles, selectedTitles: selectedTitles)
        segmentedControl.delegate = self
        segmentedControl.backgroundColor = UIColor.clear
        segmentedControl.selectionBoxColor = UIColor.white
        segmentedControl.selectionBoxStyle = .default
        segmentedControl.selectionBoxCornerRadius = 15
        segmentedControl.frame.size = CGSize(width: 70 * titles.count, height: 30)
        segmentedControl.isLongPressEnabled = true
        segmentedControl.isUnselectedSegmentsLongPressEnabled = true
        segmentedControl.longPressMinimumPressDuration = 1
        navigationItem.titleView = segmentedControl
        segmentedControl.setSelected(at: AppConfigSettings.shared.taskIndex, animated: true)

    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.models.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoTaskTableViewCell", for: indexPath) as! TodoTaskTableViewCell
        let model = self.models[safe: indexPath.row]
        if model == nil {
            return UITableViewCell()
        }
        cell.setData(cellModel: model!)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let todoTask:TodoTaskData? = self.models[indexPath.row].sourceObj
        
        //根据不同的类型跳转显示
        switch self.segmentedControl.selectedIndex {
        case 0:
            self.performSegue(withIdentifier: "showTodoDetailSegue", sender: todoTask)
        case 1:
            self.performSegue(withIdentifier: "showTodoDetailSegue", sender: todoTask)
        case 2:
            self.performSegue(withIdentifier: "showTodoedDetailSegue", sender: todoTask)
        case 3:
            self.performSegue(withIdentifier: "showTodoDetailSegue", sender: todoTask)
        default:
            DDLogDebug("no click")
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    //prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTodoDetailSegue" {
            let destVC = segue.destination as! TodoTaskDetailViewController
            destVC.todoData = sender as? TodoTaskData
            destVC.backFlag = 2 //返回标志
        }else if segue.identifier == "showTodoedDetailSegue" {
            let destVC = segue.destination as! TodoedTaskViewController
            destVC.todoTask = sender as? TodoTaskData
        }else if segue.identifier == "toSignature" {
            DDLogDebug("签名去了。。。。。。。。。")
        }
    }
    
    //backWindtodoTask
    @IBAction func unWindForTodoTask(_ segue:UIStoryboardSegue){
        DDLogDebug(segue.identifier!)
        self.tableView.mj_header.beginRefreshing()
    }
    
}

//searcher update
extension TodoTaskViewController:UISearchResultsUpdating,UISearchControllerDelegate{
    func willPresentSearchController(_ searchController: UISearchController) {
        DDLogDebug("willPresentSearchController 1, searchController.isActive = \(searchController.isActive)")
        self.models.removeAll()
        self.tableView.reloadData()
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        DDLogDebug(" didPresentSearchController 2, searchController.isActive = \(searchController.isActive)")
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
         DDLogDebug(" didPresentSearchController 3, searchController.isActive = \(searchController.isActive)")
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
         DDLogDebug(" didDismissSearchController 4, searchController.isActive = \(searchController.isActive)")
        //self.tableView.mj_header.beginRefreshing()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        DDLogDebug("updateSearchResults........")
        if let sText = searchController.searchBar.text {
            self.searchText = sText
            self.headerLoadData()
        }else {
            DDLogDebug("search text is nil ..................")
        }
        
    }
}

extension TodoTaskViewController:SegmentedControlDelegate{
    func segmentedControl(_ segmentedControl: SegmentedControl, didSelectIndex selectedIndex: Int) {
        DDLogDebug("click \(selectedIndex)")
        AppConfigSettings.shared.taskIndex = selectedIndex
        self.setSearchBarIsShow()
        self.headerLoadData()
        //self.tableView.mj_header.beginRefreshing()
    }
    
    func segmentedControl(_ segmentedControl: SegmentedControl, didLongPressIndex longPressIndex: Int) {
        
    }
}
