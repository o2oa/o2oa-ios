//
//  WaterMarkTableViewCell.swift
//  O2Platform
//
//  Created by FancyLou on 2022/3/30.
//  Copyright © 2022 zoneland. All rights reserved.
//

import UIKit

class WaterMarkTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    var myLabel: UILabel? = nil
    
    
    func setText(text: String) {
        self.backgroundColor = .clear
        if self.myLabel == nil {
            self.myLabel = UILabel(frame: CGRect(x: 0, y: 0, width: SCREEN_HEIGHT*3, height: CGFloat(WaterMarkView.lineHeight)))
            self.contentView.addSubview(self.myLabel!)
            self.myLabel?.textColor = .black
            self.myLabel?.font = UIFont(name: "PingFangSC-Regular", size: 18.0)
            self.myLabel?.alpha = 0.2
            self.myLabel?.backgroundColor = .clear
        }
        self.myLabel?.text = text
    }
}
