//
//  MeetingFormTimeDuringCell.swift
//  O2Platform
//
//  Created by FancyLou on 2020/11/25.
//  Copyright © 2020 zoneland. All rights reserved.
//

import UIKit
import Eureka


class DuringTime: NSObject {
    var startTime: Date = Date()
    var endTime = Date().add(component: .hour, value: 1)
}


class MeetingFormTimeDuringCell: Cell<DuringTime>, CellType {
 
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLable: UILabel!
    
    override func setup() {
        super.setup()
        selectionStyle = .none
        //点击选择开始时间
        self.startTimeLabel.addTapGesture { (tap) in
            var start = Date()
            if let vS = self.row.value?.startTime {
                start = vS
            }
            self.showDatePicker(pickerStyle: .hourMinuteSecond, callBackResult: { (result) in
                let newValue = DuringTime()
                newValue.startTime = result
                if let v = self.row.value {
                    newValue.endTime = v.endTime
                }
                self.row.value = newValue
                self.startTimeLabel.text = result.toString("HH时mm分")
            }, defaultDate: start)
        }
        //点击选择结束时间
        self.endTimeLable.addTapGesture { (tap) in
            var end = Date()
            if let eS = self.row.value?.endTime {
                end = eS
            }
            self.showDatePicker(pickerStyle: .hourMinuteSecond, callBackResult: { (result) in
                let newValue = DuringTime()
                newValue.endTime = result
                if let v = self.row.value {
                    newValue.startTime = v.startTime
                }
                self.row.value = newValue
                self.endTimeLable.text = result.toString("HH时mm分")
            }, defaultDate: end)
        }
    }
    
    override func update() {
        super.update()
        //数据变化显示到界面
        if let value = self.row.value {
            self.startTimeLabel.text = value.startTime .toString("HH时mm分")
            self.endTimeLable.text = value.endTime.toString("HH时mm分")
        }
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


final class MeetingFormTimeDuringRow: Row<MeetingFormTimeDuringCell>, RowType {
    required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<MeetingFormTimeDuringCell>(nibName: "MeetingFormTimeDuringCell")
    }
}
