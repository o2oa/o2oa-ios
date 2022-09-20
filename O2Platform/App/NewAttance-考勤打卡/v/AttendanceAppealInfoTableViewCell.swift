//
//  AttendanceAppealInfoTableViewCell.swift
//  O2Platform
//
//  Created by FancyLou on 2022/9/19.
//  Copyright © 2022 zoneland. All rights reserved.
//

import UIKit

class AttendanceAppealInfoTableViewCell: UITableViewCell {

    
    @IBOutlet weak var personLabel: UILabel!
    
    @IBOutlet weak var reasonLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var descLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setInfo(info: AppealInfoJson) {
        var address = info.address ?? ""
        var desc = info.appealDescription ?? ""
        
        if !address.isEmpty {
            address = "地点：\(address)"
            if !desc.isEmpty {
                desc = " , 事由：\(desc)"
            }
        } else {
            address = ""
            desc = "事由：\(desc)"
        }
        
        var reason = info.appealReason ?? ""
        if let hType = info.selfHolidayType, hType != "" {
            reason = "\(reason) (\(hType)"
        }
        var person = info.empName ?? ""
        person = person.contains("@") ? person.split("@")[0] : person
        self.personLabel.text = person
        self.timeLabel.text = info.recordDateString ?? ""
        self.reasonLabel.text = reason
        self.descLabel.text = address + desc

    }
    
}
