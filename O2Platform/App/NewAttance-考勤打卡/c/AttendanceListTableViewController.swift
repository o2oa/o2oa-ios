//
//  AttendanceListTableViewController.swift
//  O2Platform
//
//  Created by FancyLou on 2022/9/16.
//  Copyright © 2022 zoneland. All rights reserved.
//

import UIKit
import CocoaLumberjack

class AttendanceListTableViewController: UITableViewController {
    
    
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
    
    private var list: [AttendanceDetailInfoJson] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "考勤明细列表"
        self.tableView.register(UINib(nibName: "AttendanceDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "AttendanceDetailTableViewCell")
        self.tableView.tableFooterView = UIView()
        self.view.addSubview(self.emptyView)
        self.emptyView.isHidden = true
        self.loadListData()
    }
    
    
    
    private func loadListData() {
        let filter = AttendanceDetailQueryFilterJson()
        viewModel.attendancedetailList(filter: filter, completedBlock: {(result) in
            switch result {
            case .ok(let res):
                if let resultList = res as? [AttendanceDetailInfoJson] {
                    self.list = resultList
                }
                if (self.list.count > 0) {
                    self.emptyView.isHidden = true
                } else {
                    self.emptyView.isHidden = false
                }
                self.tableView.reloadData()
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

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list.count
    }
    

    /* */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "AttendanceDetailTableViewCell", for: indexPath) as? AttendanceDetailTableViewCell {
            let detail = self.list[indexPath.row]
            cell.setDetail(detail: detail)
            return cell
        }
        return UITableViewCell()
    }
   
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
}
