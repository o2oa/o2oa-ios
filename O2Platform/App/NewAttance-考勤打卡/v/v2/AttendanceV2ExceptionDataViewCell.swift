//
//  AttendanceV2ExceptionDataViewCell.swift
//  O2Platform
//
//  Created by FancyLou on 2023/4/19.
//  Copyright © 2023 zoneland. All rights reserved.
//

import UIKit

class AttendanceV2ExceptionDataViewCell: UITableViewCell {

 
    
    @IBOutlet weak var recordResultBtn: UIButton!
    
    @IBOutlet weak var appealStatusLabel: UILabel!
    
    @IBOutlet weak var recordDateLabel: UILabel!
    
    @IBOutlet weak var processBtn: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(appeal: AttendanceV2AppealInfo) {
        let time = appeal.recordDate
        var duty =   ""
        if(appeal.record?.checkInType == "OnDuty") {
            duty = "上班打卡"
        } else{
            duty = "下班打卡"
        }
        let showText = "\(time) (\(duty))"
        var result = appeal.record?.resultText() ?? ""
        if (appeal.record?.fieldWork == true) {
            result = "外勤打卡"
        }
        self.recordResultBtn.setTitle(result, for: .normal)
        self.recordResultBtn.setTitleColor(UIColor.white, for: .normal)
        self.recordResultBtn.backgroundColor = appeal.record?.resultTextColor()
        
        self.recordDateLabel.text = showText
        self.appealStatusLabel.text = appeal.statsText()
        self.processBtn.isHidden = true
        if appeal.status == 0 {
            self.processBtn.setTitle("处理 >", for: .normal)
            self.processBtn.setTitleColor(base_color, for: .normal)
            self.processBtn.isHidden = false
        } else if !appeal.jobId.isEmpty {
            self.processBtn.setTitle("查看流程 >", for: .normal)
            self.processBtn.setTitleColor(base_color, for: .normal)
            self.processBtn.isHidden = false
        }
    }
    
}
