//
//  OOFormBaseView.swift
//  o2app
//
//  Created by 刘振兴 on 2018/1/26.
//  Copyright © 2018年 zone. All rights reserved.
//

import UIKit


protocol OOFormBaseUpdateViewProtocol {
    func updateViewModel(_ item:Any)
}

class OOFormBaseView: UIView,OOFormBaseUpdateViewProtocol {
   
    
    var model:OOFormBaseModel?
    
    private var theDate = Date()
    
    private let format = "yyyy年MM月dd日"
    
    func updateViewModel(_ item: Any) {
        
    }
    
    func showDatePicker(pickerStyle: DateStyle, callBackResult:((_ result:Date) -> Void)?, defaultDate: Date = Date())  {
        
        let datePicker = DatePickerView.datePicker(style: pickerStyle, scrollToDate: defaultDate) { date in
            guard let date = date else { return }
            if let cr = callBackResult {
                cr(date)
            }
        }
        datePicker.show()
    }
    
}
