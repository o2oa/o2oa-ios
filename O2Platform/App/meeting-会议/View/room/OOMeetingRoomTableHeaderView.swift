//
//  OOMeetingRoomTableHeaderView.swift
//  o2app
//
//  Created by 刘振兴 on 2018/1/18.
//  Copyright © 2018年 zone. All rights reserved.
//

import UIKit


protocol OOMeetingRoomTableHeaderViewDelegate {
    //选择了指定的日期
    func setTheDate(_ startDate:String,_ endDate:String)
}

class OOMeetingRoomTableHeaderView: UIView {
    
    var delegate:OOMeetingRoomTableHeaderViewDelegate?
    
    @IBOutlet weak var selectedDateLabel: UILabel!
    
    @IBOutlet weak var theDateField: UITextField!
    
    @IBOutlet weak var theTimeField: UITextField!
    
    
    
    var startDate:String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        return formatter.string(from: currentDate)
    }
    
    var completedDate:String {
//        let endDate = Calendar.current.dateComponents([.hour,.minute], from: currentTime)
//        var dateComp = DateComponents()
//
//        dateComp.hour = endDate.hour
//        dateComp.minute = endDate.minute
        
//        let eDate = Calendar.current.date(byAdding: dateComp, to: currentDate)
        var eDate = currentDate
        
        eDate = eDate.add(component: .hour, value: currentTime.hour)
        eDate = eDate.add(component: .minute, value: currentTime.minute)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        return formatter.string(from: eDate)
        
    }
    
    var setDelegate:OOMeetingRoomTableHeaderViewDelegate?
    
    private var currentDate = Date()
    
    private var currentTime = Date()
    
    private let formatter = DateFormatter()
    
    private let dateFormat = "yyyy-MM-dd HH:mm"
    
    private let timeFormat = "HH时mm分"
    
    
    
    override func awakeFromNib() {
        formatter.dateFormat = dateFormat
        theDateField.text = formatter.string(from: currentDate)
        formatter.dateFormat = timeFormat
        currentTime = Calendar.current.date(bySettingHour: 1, minute: 0, second: 0, of: currentTime)!
        theTimeField.text = formatter.string(from: currentTime)
        theDateField.delegate = self
        theTimeField.delegate = self
    }
    
    //默认是当前时间 1个小时 这个函数是设置新的时间的
    func setChooseDate(startTime: Date, endTime:Date) {
        self.currentDate = startTime
        formatter.dateFormat = dateFormat
        theDateField.text = formatter.string(from: self.currentDate)
        self.currentTime = endTime
        var gap = endTime.hour - startTime.hour
        if gap < 0 {
            gap = 1
        }
        formatter.dateFormat = timeFormat
        currentTime = Calendar.current.date(bySettingHour: gap, minute: 0, second: 0, of: currentTime)!
        theTimeField.text = formatter.string(from: currentTime)
    }
    
    func callbackDelegate(){
        guard  let block = setDelegate else {
            return
        }
        block.setTheDate(startDate, completedDate)
    }
    
    
    ///日期时间选择
    func datePicker(textField: UITextField) {
        let picker = QDatePicker{ (date: String) in
            print(date)
            textField.text = date
            self.callbackDelegate()
        }
        picker.themeColor = O2ThemeManager.color(for: "Base.base_color")!
        picker.datePickerStyle = .YMDHM
        picker.pickerStyle = .datePicker
        picker.showDatePicker(defaultDate: currentDate)
    }
    
    ///持续时间选择
    func timePicker(textField: UITextField) {
        let picker = QDatePicker{ (date: String) in
            let time = date.split(" ")[1]
            let dArray = time.split(":")
            textField.text = "\(dArray[0])时\(dArray[1])分"
            self.callbackDelegate()
        }
        picker.themeColor = O2ThemeManager.color(for: "Base.base_color")!
        picker.datePickerStyle = .HM
        picker.pickerStyle = .datePicker
        picker.showDatePicker(defaultDate: currentTime)
    }
}


extension OOMeetingRoomTableHeaderView:UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField == theDateField {
            self.datePicker(textField: textField)
            return false
        }else if textField == theTimeField {
            self.timePicker(textField: textField)
            return false
        }
        return true
    }
}
