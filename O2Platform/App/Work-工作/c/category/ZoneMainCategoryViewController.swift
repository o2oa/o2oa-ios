//
//  ZoneMainCategoryViewController.swift
//  ZoneBarManager
//
//  Created by 刘振兴 on 2017/3/16.
//  Copyright © 2017年 zone. All rights reserved.
//

import UIKit

class ZoneMainCategoryViewController: UITableViewController {
    
    public static let SELECT_MSG_NAME = Notification.Name("CATEGORY_SELECT_OBJ")
    
//    public var apps:[O2Application] = [] {
//        didSet {
//            self.tableView.reloadData()
//            if apps.count > 0 {
//                let indexPath = IndexPath(row: 0, section: 0)
//                self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
//                let sAPP = apps[0]
//                self.postMessage(sAPP)
//            }
//        }
//    }
    private var selectedIndex: IndexPath?
    // 改成分类显示
    public var appList: [O2AppByCategory] = [] {
        didSet {
            self.tableView.reloadData()
            if (appList.count > 1) {
                let indexPath = IndexPath(row: 1, section: 0)
                self.selectedIndex  = indexPath
                self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
                if let sAPP =  appList[1].app {
                    self.postMessage(sAPP)
                }
            }
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return appList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ZoneMainCategoryTableViewCell", for: indexPath) as! ZoneMainCategoryTableViewCell
        if let currentAPP = appList[indexPath.row].app {
            cell.appNameLabel.text = currentAPP.name
            if let icon = currentAPP.icon {
                let imageData = Data(base64Encoded: icon, options: .ignoreUnknownCharacters)
                cell.appIconImageView.image = UIImage(data: imageData!)
            }
            cell.appIconImageView.isHidden = false
            cell.appNameLabel.isHidden = false
            cell.categoryNameLabel.isHidden = true
        } else {
            cell.appIconImageView.isHidden = true
            cell.appNameLabel.isHidden = true
            cell.categoryNameLabel.isHidden = false
            cell.categoryNameLabel.text =  appList[indexPath.row].category
        }
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let sAPP = self.appList[indexPath.row].app {
            self.selectedIndex  = indexPath
            self.postMessage(sAPP)
        } else {
            self.tableView.deselectRow(at: indexPath, animated: false)
            self.tableView.selectRow(at: self.selectedIndex, animated: true, scrollPosition: .top)
        }
    }
    
    private func postMessage(_ currenApp: O2Application){
        NotificationCenter.default.post(name: ZoneMainCategoryViewController.SELECT_MSG_NAME, object: currenApp)
    }
    
    
    
    

}
