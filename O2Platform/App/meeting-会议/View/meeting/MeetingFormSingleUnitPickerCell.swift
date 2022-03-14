//
//  MeetingFormSingleUnitPickerCell.swift
//  O2Platform
//
//  Created by FancyLou on 2022/3/14.
//  Copyright © 2022 zoneland. All rights reserved.
//

import UIKit
import Eureka

class MeetingFormSingleUnitPickerCell: Cell<String>, CellType {

    @IBOutlet weak var unitLabel: UILabel!
     
    override func setup() {
        super.setup()
        selectionStyle = .none
    }
    
    override func update() {
        super.update()
        if let v = row.value {
           var name = ""
           if v.contains("@") {
                name  = v.split("@")[0]
           }else {
                name = v
           }
            self.unitLabel.text = name
        }
    }
    override func didSelect() {
        // 点击事件
        self.pickerUnit()
    }
 
    private func setCellValue(person: String) {
        self.row.value = person
        var name = ""
        if person.contains("@") {
             name  = person.split("@")[0]
        }else {
             name = person
        }
         self.unitLabel.text = name
    }
    
    private func pickerUnit() {
        if let v = ContactPickerViewController.providePickerVC(
            pickerModes: [ContactPickerType.unit],
            multiple: false,
            pickedDelegate: { (result: O2BizContactPickerResult) in
                if let depts = result.departments {
                    if !depts.isEmpty {
                        self.setCellValue(person: depts[0].distinguishedName ?? "")
                    }
                }
                
        }) {
            self.formViewController()?.navigationController?.pushViewController(v, animated: true)
        }
    }
    
}




final class MeetingFormSingleUnitPickerRow: Row<MeetingFormSingleUnitPickerCell>, RowType {
    required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<MeetingFormSingleUnitPickerCell>(nibName: "MeetingFormSingleUnitPickerCell")
    }
}
