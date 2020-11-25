//
//  MeetingFormRoomPickerCell.swift
//  O2Platform
//
//  Created by FancyLou on 2020/11/25.
//  Copyright © 2020 zoneland. All rights reserved.
//

import UIKit
import Eureka

class MeetingFormRoomPickerCell: Cell<OOMeetingRoomInfo>, CellType {
    
    @IBOutlet weak var roomLabel: UILabel!
    
    override func setup() {
        super.setup()
    }
    
    override func update() {
        super.update()
        if let value = self.row.value {
            self.roomLabel.text = value.name
        }
    }
    
    
}


final class MeetingFormRoomPickerCellRow: Row<MeetingFormRoomPickerCell>, RowType {
    
    required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<MeetingFormRoomPickerCell>(nibName: "MeetingFormRoomPickerCell")
    }
    
    var onPresent: (() -> Void)?
    
    override func customDidSelect() {
        super.customDidSelect()
        onPresent?()
    }
}
