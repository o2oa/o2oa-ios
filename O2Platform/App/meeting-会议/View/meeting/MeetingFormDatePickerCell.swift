//
//  MeetingFormDatePickerCell.swift
//  O2Platform
//
//  Created by FancyLou on 2020/11/25.
//  Copyright © 2020 zoneland. All rights reserved.
//

import UIKit
import Eureka

class MeetingFormDatePickerCell: Cell<Date>, CellType  {
  
    @IBOutlet weak var dateLabel: UILabel!
    
 
    
    override func setup() {
        super.setup()
        selectionStyle = .none
    }
    
    override func update() {
        super.update()
        var defaultDate = Date()
        if let v = row.value {
            defaultDate = v
        }
        self.dateLabel.text = defaultDate.toString("yyyy-MM-dd")
    }
    
    override func didSelect() {
        // 点击事件
        var defaultDate = Date()
        if let v = row.value {
            defaultDate = v
        }
        self.showDatePicker(pickerStyle: .yearMonthDay, callBackResult: { (result) in
            self.row.value = result
            self.dateLabel.text = result.toString("yyyy-MM-dd")
        }, defaultDate: defaultDate)
    }
    
    
    private func showDatePicker(pickerStyle: DateStyle, callBackResult:((_ result:Date) -> Void)?, defaultDate: Date = Date())  {
        let datePicker = DatePickerView.datePicker(style: pickerStyle, scrollToDate: defaultDate) { date in
            guard let date = date else { return }
            if let cr = callBackResult {
                cr(date)
            }
        }
        datePicker.show()
    }
}


final class MeetingFormDatePickerRow: Row<MeetingFormDatePickerCell>, RowType {
    required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<MeetingFormDatePickerCell>(nibName: "MeetingFormDatePickerCell")
    }
}
