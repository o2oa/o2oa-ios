//
//  ContactHomeViewController.swift
//  O2Platform
//
//  Created by 刘振兴 on 16/7/12.
//  Copyright © 2016年 zoneland. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import AlamofireObjectMapper

import ObjectMapper

import CocoaLumberjack


class ContactHomeViewController: UITableViewController {

    var contacts:[Int:[CellViewModel]] = [0:[],1:[],2:[]]
    let group = DispatchGroup()
    
    var myDepartmentURL:String? {
        let acc = O2AuthSDK.shared.myInfo()!
        let url = AppDelegate.o2Collect.generateURLWithAppContextKey(ContactContext.contactsContextKeyV2, query: ContactContext.personInfoByNameQuery, parameter: ["##name##":acc.unique! as AnyObject])
        return url
    }
    
    var myCompanyURL:String? {
        let url = AppDelegate.o2Collect.generateURLWithAppContextKey(ContactContext.contactsContextKeyV2, query: ContactContext.topUnitQuery, parameter:nil)
        return url
    }
    
    //当前用户信息 用来查询身份的
    var myPersonURL:String? {
        let url = AppDelegate.o2Collect.generateURLWithAppContextKey(PersonContext.personContextKey, query: PersonContext.personInfoQuery, parameter: nil)
        return url
    }
    //根据身份查询顶级组织
    var topUnitByIdentityURL: String? {
        let url = AppDelegate.o2Collect.generateURLWithAppContextKey(ContactContext.contactsContextKey, query: ContactContext.topLevelUnitByIdentity, parameter: nil)
        return url
    }
    
    let searchUrl = AppDelegate.o2Collect.generateURLWithAppContextKey(ContactContext.contactsContextKeyV2, query: ContactContext.personSearchByKeyQueryV2, parameter: nil)
    
    var searchController : UISearchController? = nil
    
    var searchResult : [CellViewModel] = []
    
    var searchFilter : String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(ContactHomeViewController.loadMyData(_:)))
        DDLogDebug("通讯录权限判断")
        if !OrganizationPermissionManager.shared.isCurrentPersonCannotQueryAll() && !OrganizationPermissionManager.shared.isCurrentPersonCannotQueryOuter() {
            DDLogDebug("不能查询其他")
            self.initSearch()
        }
        
        self.definesPresentationContext = true
        self.tableView.separatorStyle = .none
        
        self.loadMyData(nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    private func initSearch(){
        
        searchController = UISearchController(searchResultsController: nil)
        searchController?.delegate = self
        searchController?.searchBar.delegate = self
        searchController?.searchResultsUpdater = self
        
        searchController?.dimsBackgroundDuringPresentation = false
        searchController?.hidesNavigationBarDuringPresentation = false
        
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).title = L10n.cancel
        let attrs =  [NSAttributedString.Key.font: UIFont.init(name: "PingFangTC-Light", size: 14) ?? UIFont.systemFont(ofSize: 14),
         NSAttributedString.Key.foregroundColor: O2ThemeManager.color(for: "Base.base_color") ?? UIColor.red]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(attrs, for: .normal)
        
        searchController?.searchBar.searchBarStyle = UISearchBar.Style.minimal
        searchController?.searchBar.sizeToFit()
        searchController?.searchBar.placeholder = L10n.Contacts.searchPlaceholder
        
        self.tableView.tableHeaderView = searchController?.searchBar
    }
    
    private func isSearchRealActive() -> Bool {
        return self.searchController?.isActive == true && self.searchFilter != ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if section == 0 {
//            return self.searchController.searchBar
//        }else{
//            return nil
//        }
//    }
//    
//    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if section == 0 {
//            return 48
//        }else{
//            return 18
//        }
//    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.isSearchRealActive() ? 1 : (contacts.count)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.isSearchRealActive() ? self.searchResult.count : (contacts[section]?.count)!
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellName = isSearchRealActive() ? "contactPersonCell" : "contactItemCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellName, for: indexPath) as! ContactItemCell
        if isSearchRealActive() {
            cell.cellViewModel = self.searchResult[indexPath.row]
        } else {
            let cellMod = self.contacts[indexPath.section]![indexPath.row]
            if !cellMod.openFlag {
                cell.accessoryType = UITableViewCell.AccessoryType.none
            }else {
                cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
            }
            cell.cellViewModel = cellMod
        }
        
        return cell
    }
    
    /// Cell 圆角背景计算
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //圆率
        let cornerRadius:CGFloat = 10.0
        //大小
        let bounds:CGRect  = cell.bounds
        //行数
        let numberOfRows = tableView.numberOfRows(inSection: indexPath.section)
        //绘制曲线
        var bezierPath: UIBezierPath? = nil
        if (indexPath.row == 0 && numberOfRows == 1) {
            //一个为一组时,四个角都为圆角
            bezierPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        } else if (indexPath.row == 0) {
            //为组的第一行时,左上、右上角为圆角
            bezierPath = UIBezierPath(roundedRect: bounds, byRoundingCorners:  [.topLeft, .topRight], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        } else if (indexPath.row == numberOfRows - 1) {
            //为组的最后一行,左下、右下角为圆角
            bezierPath = UIBezierPath(roundedRect: bounds, byRoundingCorners:  [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        } else {
            //中间的都为矩形
            bezierPath = UIBezierPath(rect: bounds)
        }
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
    
    /*override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "我的部门"
        case 1:
            return "我的公司"
        case 2:
            return "常用联系人"
        default:
            return ""
        }
    }*/
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.tableView.deselectRow(at: indexPath, animated: false)

        let cellViewModel = isSearchRealActive() ? self.searchResult[indexPath.row] : self.contacts[indexPath.section]![indexPath.row]
        
        switch cellViewModel.dataType {
        case .company(let c):
            self.performSegue(withIdentifier: "showDepartPersonSegue", sender: c)
        case .depart(let d):
            if cellViewModel.openFlag {
                self.performSegue(withIdentifier: "showDepartPersonSegue", sender: d)
            }
        case .group(let g):
            self.performSegue(withIdentifier: "showPersonGroupSegue", sender: g)
        case .identity(let i):
            self.performSegue(withIdentifier: "showPersonInfoSegueV2", sender: i)
        case .person(let p):
            self.performSegue(withIdentifier: "showPersonInfoSegueV2", sender: p)
        case .title(_):
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showCompanyDepartSegue" {
            let destVC = segue.destination as! ContactCompanyDeptController
            destVC.superCompany = sender as? Company
        }else if segue.identifier == "showDepartPersonSegue" {
            let destVC = segue.destination as! ContactDeptPersonController
            destVC.superOrgUnit = sender as? OrgUnit
        }else if segue.identifier == "showPersonGroupSegue" {
            let destVC = segue.destination as! ContactGroupPersonController
            destVC.superGroup = sender as? Group
        }else if segue.identifier == "showPersonInfoSegueV2" {
            let destVC = segue.destination as! ContactPersonInfoV2ViewController
            destVC.person = sender as? PersonV2
        }
        
    }
    
    func rightItemAction(_ sender:UIBarButtonItem){
        //DDLogDebug("rightItemAction haved click")
        self.performSegue(withIdentifier: "showContactSearchSegue", sender: nil)
        
    }
    
    func search(by filter: String) {
        let sf = SearchFilter(key: filter)
        AF.request(self.searchUrl!,method: .put, parameters: sf.toJSON(), encoding: JSONEncoding.default).responseJSON {
            response in
            switch response.result {
            case .success(let val):
                DDLogDebug(JSON(val).description)
                let value = JSON(val)
                if value["type"] == "success" {
                    if sf.key! == self.searchFilter {
                        self.searchResult.removeAll()
                        if let persons = Mapper<PersonV2>().mapArray(JSONString:value["data"].description) {
                            for person in persons{
                                let vm = CellViewModel(name: person.name,sourceObject: person)
                                self.searchResult.append(vm)
                            }
                        }
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                
                }else{
                    DDLogError("error message =\(value["message"])")
                }
            case .failure(let err):
                DDLogError(err.localizedDescription)
            }
        }
    }
    
    @objc func loadMyData(_ sender:AnyObject?){
        let urls = [0:myDepartmentURL,1:myCompanyURL]
//        var count = 0
        //增加常用联系人
        self.contacts[2]?.removeAll()
        let collectTitle = HeadTitle(name: L10n.Contacts.topContacts, icon: O2ThemeManager.string(for: "Icon.icon_linkman")!)
        let collectVMT = CellViewModel(name: collectTitle.name, sourceObject: collectTitle)
        self.contacts[2]?.append(collectVMT)
        let collectPersons = DBManager.shared.queryContactData((O2AuthSDK.shared.myInfo()?.id)!)
        collectPersons.forEach { (p) in
            let vm = CellViewModel(name: p.name!, sourceObject: p)
            self.contacts[2]?.append(vm)
        }
       
        for (order,url) in urls {
            if order == 0 {
                if OrganizationPermissionManager.shared.isCurrentPersonCannotQueryAll() {
                   continue
                }
                self.showLoading()
                DDLogDebug("查询了我的部门数据")
                AF.request(url!, method: .get, parameters: nil, encoding:URLEncoding.default, headers: ["X-ORDER":String(order)]).validate().responseJSON {
                    response in
                    switch response.result {
                    case .success(let val):
                        let objects = JSON(val)["data"]
                        print(objects.description)
                        self.contacts[order]?.removeAll()
                        let tile = HeadTitle(name: L10n.Contacts.myDepartment, icon: O2ThemeManager.string(for: "Icon.icon_company")!)
                        let vmt = CellViewModel(name: tile.name, sourceObject: tile)
                        self.contacts[order]?.append(vmt)
                        if let person = Mapper<PersonV2>().map(JSONString:objects.description) {
                            if let identities = person.woIdentityList {
                                for identity in identities {
                                    if let unit = identity.woUnit {
                                        unit.subDirectIdentityCount = 1
                                        let vm = CellViewModel(name: unit.name,sourceObject: unit as AnyObject)
                                        self.contacts[order]?.append(vm)
                                    }
                                }
                            }
                        }
                    case .failure(let err):
                        DDLogError(err.localizedDescription)
                    }
                    
                    self.hideLoading()
                    if self.tableView.mj_header.isRefreshing() == true {
                        self.tableView.mj_header.endRefreshing()
                    }
                    self.tableView.reloadData()
                    
                }
            } else if order == 1 {
                if OrganizationPermissionManager.shared.isCurrentPersonCannotQueryAll() || OrganizationPermissionManager.shared.isCurrentPersonCannotQueryOuter() {
                   continue
                }
                DDLogDebug("查询了公司组织架构")
                AF.request(myPersonURL!, method: .get, parameters: nil, encoding:URLEncoding.default, headers: ["X-ORDER":String(order)]).validate().responseJSON {
                    response in
                    switch response.result {
                    case .success(let val):
                        let objects = JSON(val)["data"]
                        print(objects.description)
                        var identitys:[IdentityV2] = []
                        if let person = Mapper<PersonV2>().map(JSONString:objects.description) {
                            if let identities = person.woIdentityList, identities.count > 0 {
                                identitys = identities
                            }
                        }
                        if !identitys.isEmpty {
                            self.loadAllTopUnitByIdentity(order: order, identitys: identitys)
                        }else {
                            self.hideLoading()
                            if self.tableView.mj_header.isRefreshing() == true {
                                self.tableView.mj_header.endRefreshing()
                            }
                            self.tableView.reloadData()
                        }
                    case .failure(let err):
                        DDLogError(err.localizedDescription)
                        self.hideLoading()
                        if self.tableView.mj_header.isRefreshing() == true {
                            self.tableView.mj_header.endRefreshing()
                        }
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    private func loadAllTopUnitByIdentity(order: Int, identitys: [IdentityV2]) {
        self.contacts[order]?.removeAll()
        for identity in identitys {
            self.group.enter()
            // 异步处理请求
            DispatchQueue.main.async(group: self.group, execute: DispatchWorkItem(block: {
                AF.request(self.topUnitByIdentityURL!, method: .post, parameters: ["identity": identity.distinguishedName as AnyObject, "level": 1 as AnyObject], encoding: JSONEncoding.default, headers: nil).responseJSON(completionHandler: { (res) in
                    switch res.result {
                    case .success(let val):
                        let objects = JSON(val)["data"]
                        if let unit = Mapper<OrgUnit>().map(JSONString:objects.description) {
                            unit.subDirectUnitCount = 1 //这个接口查询出来的组织没有下级组织的数量，假设是有下级组织的
                            if (self.contacts[order]?.isEmpty == true) { // 第一次 添加头部
                                let tile = HeadTitle(name: L10n.Contacts.orgStructre, icon: O2ThemeManager.string(for: "Icon.icon_bumen")!)
                                let vmt = CellViewModel(name: tile.name, sourceObject: tile)
                                self.contacts[order]?.append(vmt)
                            }
                            // 顶级组织
                            let vm = CellViewModel(name: unit.name,sourceObject: unit)
                            self.contacts[order]?.append(vm)
                        }
                        self.group.leave()
                        break
                    case .failure(let err):
                        DDLogError(err.localizedDescription)
                        self.group.leave()
                        break
                    }
                    
                })
            }))
        }
        
        self.group.notify(queue: DispatchQueue.main) {
            // 处理结果
            self.hideLoading()
            if self.tableView.mj_header.isRefreshing() == true {
                self.tableView.mj_header.endRefreshing()
            }
            self.tableView.reloadData()
        }
    }
    
}

extension ContactHomeViewController:UISearchControllerDelegate{
    func willPresentSearchController(_ searchController: UISearchController) {
        NSLog("willPresentSearchController")
//        searchController.searchBar.searchBarStyle = UISearchBar.Style.default
//        self.tableView.mj_header.isHidden = true
        
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        NSLog("didPresentSearchController")
//        UIView.animate(withDuration: 0.1, animations:{
//            ()-> Void in
//            self.tableView.contentInset = UIEdgeInsets(top: 25, left: 0, bottom: 0, right: 0)
//        })
        
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        NSLog("willDismissSearchController")
//        searchController.searchBar.searchBarStyle = UISearchBar.Style.minimal
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        NSLog("didDismissSearchController")
//        UIView.animate(withDuration: 0.15, animations:{
//            ()-> Void in
//            self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        },completion:{(finished:Bool) -> Void in
//            self.tableView.mj_header.isHidden = false
//        })
        
        
    }
    
    func presentSearchController(_ searchController: UISearchController) {
        NSLog("presentSearchController")
    }
    
    
}

extension ContactHomeViewController:UISearchBarDelegate{
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchFilter = ""
        self.searchResult.removeAll()
        self.tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        NSLog("selectedScopeButtonIndexDidChange")
        //self.loadSearchData(searchBar.text, scopeIndex: selectedScope)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        NSLog("searchBarTextDidBeginEditing")
    }
    
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        print("searchBarSearchButtonClicked")
//    }
    
    
    
}

extension ContactHomeViewController:UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        //let searchBar = searchController.searchBar
        //self.loadSearchData(searchBar.text, scopeIndex: searchBar.selectedScopeButtonIndex)
        if var filter = searchController.searchBar.text {
            filter = filter.trimmingCharacters(in: .whitespaces)
            self.searchFilter = filter
            if filter != "" {
                self.search(by: filter)
            }else{
                print("no filter to search")
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
}
