//
//  ContactCompanyDeptController.swift
//  O2Platform
//
//  Created by 刘振兴 on 16/7/14.
//  Copyright © 2016年 zoneland. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import AlamofireObjectMapper
import SwiftyJSON
import ObjectMapper

import CocoaLumberjack

class ContactCompanyDeptController: UITableViewController {
    
    
    var superCompany:Company? {
        didSet{
            let url = AppDelegate.o2Collect.generateURLWithAppContextKey(ContactContext.contactsContextKey, query: ContactContext.subCompanyByNameQuery, parameter: ["##name##":(superCompany?.name)! as AnyObject])
            myCompanyURL = url
        }
    }
    
    var compContacts:[CellViewModel] = []
    
    var myCompanyURL:String?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = superCompany?.name
        self.tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(loadCompData(_:)))
        self.tableView.separatorStyle = .none
        self.loadCompData(nil)
        
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.compContacts.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "compContactCell", for: indexPath)  as! ContactItemCell
        cell.cellViewModel = self.compContacts[(indexPath as NSIndexPath).row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewModel = self.compContacts[(indexPath as NSIndexPath).row]
        switch viewModel.dataType {
            case .company(let c):
                self.superCompany = c as? Company
                self.loadCompData(nil)
            case .depart(let d):
                self.performSegue(withIdentifier: "sDeptPersonSegue", sender:d)
            default:
                DDLogDebug(viewModel.name!)
        }
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
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sDeptPersonSegue" {
            let destVC = segue.destination as! ContactDeptPersonController
            destVC.superOrgUnit = sender as? OrgUnit
        }
    }
    
    
    @objc func loadCompData(_ obj:AnyObject?){
        self.showLoading()
        AF.request(self.myCompanyURL!).responseJSON {
            response in
            //debugPrint(response)
            switch response.result {
            case .success(let val):
                self.compContacts.removeAll()
                let compnayList = JSON(val)["data"]["companyList"]
                let companys = Mapper<Company>().mapArray(JSONString:compnayList.description)
                for comp in companys!{
                    let vm = CellViewModel(name: comp.name,sourceObject: comp)
                    self.compContacts.append(vm)
                }
                let departmentList = JSON(val)["data"]["departmentList"]
                let departmets = Mapper<Department>().mapArray(JSONString:departmentList.description)
                for dept in departmets!{
                    let vm = CellViewModel(name: dept.name,sourceObject: dept)
                    self.compContacts.append(vm)
                }
//                self.showSuccess(title: "加载完成")
            case .failure(let err):
                DDLogError(err.localizedDescription)
                self.showError(title: L10n.errorWithMsg(err.localizedDescription))
            }
            if self.tableView.mj_header.isRefreshing() {
                self.tableView.mj_header.endRefreshing()
            }
            self.tableView.reloadData()
        }}

}
