//
//  EmpowerItemTableViewCell.swift
//  O2Platform
//
//  Created by FancyLou on 2023/5/17.
//  Copyright © 2023 zoneland. All rights reserved.
//

import UIKit

class EmpowerItemTableViewCell: UITableViewCell {

    @IBOutlet weak var personLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var typeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupData(item: EmpowerData, type: EmpowerTypeEnum) {
        var person = ""
        switch type {
        case EmpowerTypeEnum.empowerList:
            person = item.toPerson?.split("@").first ?? ""
            break
        case EmpowerTypeEnum.empowerListTo:
            person = item.fromPerson?.split("@").first ?? ""
            break
        }
        self.personLabel.text = person
        self.timeLabel.text = "\(item.startTime ?? "") - \(item.completedTime ?? "")"
        var typeString = ""
        switch item.type {
        case "application":
            typeString = "应用【\(item.applicationName ?? "")】"
            break
        case "process":
            typeString = "流程【\(item.processName ?? "")】"
            break
        default:
            typeString = "全部"
            break
        }
        self.typeLabel.text = typeString
        
    }

}
