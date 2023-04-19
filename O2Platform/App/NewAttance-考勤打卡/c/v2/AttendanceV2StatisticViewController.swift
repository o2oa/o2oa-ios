//
//  AttendanceV2StatisticViewController.swift
//  O2Platform
//
//  Created by FancyLou on 2023/4/18.
//  Copyright © 2023 zoneland. All rights reserved.
//

import UIKit
import CocoaLumberjack

class AttendanceV2StatisticViewController: UIViewController {

    
    @IBOutlet weak var yearLabel: UILabel!
    
    @IBOutlet weak var monthLabel: UILabel!
    
    @IBOutlet weak var averageWorkTimeLabel: UILabel!
    
    @IBOutlet weak var attendanceDaysLabel: UILabel!
    
    @IBOutlet weak var restDaysLabel: UILabel!
    
    @IBOutlet weak var leaveDaysLabel: UILabel!
    
    @IBOutlet weak var absenteeismDaysLabel: UILabel!
    
    @IBOutlet weak var lateTimesLabel: UILabel!
    
    @IBOutlet weak var leaveEarlierTimesLabel: UILabel!
    
    @IBOutlet weak var absenceTimesLabel: UILabel!
    
    @IBOutlet weak var fieldWorkTimesLabel: UILabel!
    
    private lazy var viewModel: OOAttandanceViewModel = {
        return OOAttandanceViewModel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "关闭", style: .plain, target: self, action: #selector(closeParent))
        
        let currentDate = Date()
        self.monthLabel.text = "\(currentDate.month)月"
        self.yearLabel.text = "\(currentDate.year)"
        self.loadStatisticData()
    }
 
    @objc private func closeParent() {
        // 上级是OONewAttanceController
        self.navigationController?.parent?.navigationController?.popViewController(animated: true)
    }

    @IBAction func gotoExceptionDataList(_ sender: UIButton) {
        let appealVc = AttendanceV2ExceptionTableViewController()
        self.pushVC(appealVc)
    }
    
    
    private func loadStatisticData() {
        self.viewModel.myStatistic().then { statistic in
            self.averageWorkTimeLabel.text = statistic.averageWorkTimeDuration
            self.attendanceDaysLabel.text = "\(statistic.attendance)"
            self.restDaysLabel.text = "\(statistic.rest)"
            self.leaveDaysLabel.text = "\(statistic.leaveDays)"
            self.absenteeismDaysLabel.text = "\(statistic.absenteeismDays)"
            self.lateTimesLabel.text = "\(statistic.lateTimes)"
            self.leaveEarlierTimesLabel.text = "\(statistic.leaveEarlierTimes)"
            self.absenceTimesLabel.text = "\(statistic.absenceTimes)"
            self.fieldWorkTimesLabel.text = "\(statistic.fieldWorkTimes)"
            
        }.catch { error in
            DDLogError("\(error.localizedDescription)")
        }
    }
    
}
