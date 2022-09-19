//
//  AttendanceDetailTableViewCell.swift
//  O2Platform
//
//  Created by FancyLou on 2022/9/16.
//  Copyright © 2022 zoneland. All rights reserved.
//

import UIKit

class AttendanceDetailTableViewCell: UITableViewCell {

    
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dayTypeLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusImage: UIImageView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setDetail(detail: AttendanceDetailInfoJson) {
        self.statusImage.isHidden = true
        
        var appealStatus = ""
        let s = detail.appealStatus ?? 0
        let isGetSelfHolidays = detail.isGetSelfHolidays ?? false
        let isAbsent = detail.isAbsent ?? false
        let isLate = detail.isLate ?? false
        let isAbnormalDuty = detail.isAbnormalDuty ?? false
        let isLackOfTime = detail.isLackOfTime ?? false
        
        switch(s) {
        case 0:
            if (!isGetSelfHolidays && (isAbsent || isLate || isAbnormalDuty || isLackOfTime)) {
                self.statusImage.isHidden = false
            }
            break
        case 9:
            appealStatus = "申诉通过"
            break
        case 1:
            appealStatus = "申诉中"
            break
        case -1:
            appealStatus = "申诉未通过"
            break
        default:
            appealStatus = ""
            break
        }
        
        var off_on_time = ""
        if let ondutyTime = detail.onDutyTime, let offDutyTime = detail.offDutyTime {
            off_on_time = "\(ondutyTime) - \(offDutyTime)"
        } else if let ondutyTime = detail.onDutyTime {
            off_on_time = "\(ondutyTime)"
        } else if let offDutyTime = detail.offDutyTime {
            off_on_time = "\(offDutyTime)"
        }
        var desc = "工作日"
        if detail.isHoliday == true {
            desc = "节假日"
        } else if detail.isWeekend == true {
            desc = "周末"
        } else if detail.isWorkday == true {
            desc = "调休工作日"
        }
         
        var status = "正常"
        if detail.isGetSelfHolidays == true {
            status = "请假"
        } else if detail.isLate == true {
            status = "迟到"
        } else if detail.isAbsent == true {
            status = "缺勤"
        } else if detail.isAbnormalDuty == true {
            status = "异常打卡"
        } else if detail.isLackOfTime == true {
            status = "工时不足"
        }
        if !appealStatus.isEmpty {
            if let process = detail.appealProcessor, !process.isEmpty {
                if (process.contains("@")) {
                    let p = process.split("@")[0]
                    status += " (\(appealStatus), 审核人：\(p))"
                } else {
                    status += " (\(appealStatus), 审核人：\(process))"
                }
            } else {
                status += " (\(appealStatus))"
            }
        }
        self.dayLabel.text = detail.recordDateString ?? ""
        self.timeLabel.text = off_on_time
        self.dayTypeLabel.text = desc
        self.statusLabel.text = status
         
    }
    
}
