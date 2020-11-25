//
//  OOMeetingFormViewController.swift
//  O2Platform
//
//  Created by FancyLou on 2020/11/20.
//  Copyright © 2020 zoneland. All rights reserved.
//

import UIKit
import Eureka

class OOMeetingFormViewController: FormViewController {

    private lazy var  viewModel:OOMeetingCreateViewModel = {
       return OOMeetingCreateViewModel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "表单"
        self.loadForm()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPickRoom" {
            if let vc = segue.destination as? OOMeetingMeetingRoomManageController {
                vc.currentMode = 1 //单选
                vc.delegate = self
                //todo 传入时间间隔
            }
        }
    }
    
    private func loadForm() {
        form +++ Section()
            <<< TextRow() { row in
                row.title = "会议标题"
                row.placeholder = "请输入标题"
                row.placeholder = ""
            }.onChange({ (row) in
                let subject = row.value
                
            })
            <<< MeetingFormDatePickerRow() { row in
                row.title = "会议日期"
            }.onChange({ (row) in
                if let date = row.value {
                    print(date.toString("yyyy-MM-dd"))
                }
            })
            <<< MeetingFormTimeDuringRow() { row in
                row.title = "会议时间"
            }.onChange({ (row) in
                if let date = row.value {
                    print(date.startTime.toString("HH时mm分"))
                    print(date.endTime.toString("HH时mm分"))
                }
            })
            <<< MeetingFormRoomPickerCellRow("room") { row in
                row.title = "会议室"
                row.onPresent = {
                    self.performSegue(withIdentifier: "showPickRoom", sender: nil)
                }
            }.onChange({ (row) in
                print(row.value?.name)
            })
            <<< MeetingFormChoosePersonCellRow() { row in
                row.title = "参会人员"
                row.cell.viewModel = self.viewModel
            }.onChange({ row in
                print(row.value?.count)
            })
             
    }
    

     
}

extension OOMeetingFormViewController: OOCommonBackResultDelegate {
    func backResult(_ vcIdentifiter: String, _ result: Any?) {
        if vcIdentifiter == "OOMeetingMeetingRoomManageController" {
            if let rooms = result as? [OOMeetingRoomInfo] {
                if !rooms.isEmpty {
                    if let roomRow = form.rowBy(tag: "room") as? MeetingFormRoomPickerCellRow {
                        roomRow.value = rooms.first
                    }
                }
            }
        }
    }
    
    
}
