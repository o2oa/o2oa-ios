//
//  OOFormDateIntervalItemView.swift
//  o2app
//
//  Created by 刘振兴 on 2018/1/26.
//  Copyright © 2018年 zone. All rights reserved.
//

import UIKit


class OOFormDateIntervalItemView: OOFormBaseView,OOFormConfigEnable {
    
    @IBOutlet weak var showValueLabel: UILabel!
    
    @IBOutlet weak var titleNameLabel: UILabel!
    
    @IBOutlet weak var value1TextField: UITextField!
    
    @IBOutlet weak var value2TextField: UITextField!
    
    override func awakeFromNib() {
        showValueLabel.isHidden = true
        value1TextField.delegate = self
        value2TextField.delegate = self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    

    func configItem(_ model: OOFormBaseModel) {
        self.model = model
        titleNameLabel.text = self.model?.titleName
        if self.model?.itemStatus! == .read {
            showValueLabel.isHidden = false
            showValueLabel.text = (self.model?.callbackValue ?? "") as? String
            value1TextField.isHidden = true
            value2TextField.isHidden = true
        }else{
            showValueLabel.isHidden = true
            //showValueLabel.text = (self.model?.callbackValue ?? "") as? String
            value1TextField.isHidden = false
            value2TextField.isHidden = false
            let uModel = self.model as? OOFormDateIntervalModel
            if let m = uModel {
                if let s = m.value1, let startTime = s as? Date {
                    self.value1TextField.text =  startTime.toString("HH时mm分")
                }
                if let e = m.value2, let endTime = e as? Date {
                    self.value2TextField.text =  endTime.toString("HH时mm分")
                }
            }
        }
    }
    
}

extension OOFormDateIntervalItemView:UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        UIApplication.shared.keyWindow?.endEditing(true)
        var date = Date()
        let uModel = self.model as? OOFormDateIntervalModel
        if self.value1TextField == textField {
            date = uModel?.value1 as? Date ?? Date()
        }else if self.value2TextField == textField {
            date = uModel?.value2 as? Date ?? Date()
        }
        self.showDatePicker(pickerStyle: .hourMinuteSecond, callBackResult: { (theDate) in
            let time = theDate.toString("HH时mm分")
            let uModel = self.model as? OOFormDateIntervalModel
            if self.value1TextField == textField {
                uModel?.value1 = theDate
                self.value1TextField.text = time
            }else if self.value2TextField == textField {
                uModel?.value2 = theDate
                self.value2TextField.text = time
            }
        }, defaultDate: date)

        return false
    }
}

