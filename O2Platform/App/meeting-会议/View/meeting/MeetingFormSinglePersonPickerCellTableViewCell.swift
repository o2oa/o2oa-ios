//
//  MeetingFormSinglePersonPickerCellTableViewCell.swift
//  O2Platform
//
//  Created by FancyLou on 2022/3/14.
//  Copyright © 2022 zoneland. All rights reserved.
//

import UIKit
import Eureka

class MeetingFormSinglePersonPickerCellTableViewCell: Cell<String>, CellType {

    @IBOutlet weak var personLabel: UILabel!
    
    
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
            self.personLabel.text = name
        }
    }
    override func didSelect() {
        // 点击事件
        self.pickerPerson()
    }
 
    private func setCellValue(person: String) {
        self.row.value = person
        var name = ""
        if person.contains("@") {
             name  = person.split("@")[0]
        }else {
             name = person
        }
         self.personLabel.text = name
    }
    
    private func pickerPerson() {
        if let v = ContactPickerViewController.providePickerVC(
            pickerModes: [ContactPickerType.person],
            multiple: false,
            pickedDelegate: { (result: O2BizContactPickerResult) in
                if let users = result.users {
                    if !users.isEmpty {
                        self.setCellValue(person: users[0].distinguishedName ?? "")
                    }
                }
                
        }) {
            self.formViewController()?.navigationController?.pushViewController(v, animated: true)
        }
    }
    
}


final class MeetingFormSinglePersonPickerRow: Row<MeetingFormSinglePersonPickerCellTableViewCell>, RowType {
    required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<MeetingFormSinglePersonPickerCellTableViewCell>(nibName: "MeetingFormSinglePersonPickerCellTableViewCell")
    }
}
