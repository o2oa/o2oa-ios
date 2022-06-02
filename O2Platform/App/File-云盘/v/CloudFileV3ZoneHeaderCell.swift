//
//  CloudFileV3ZoneHeaderCell.swift
//  O2Platform
//
//  Created by FancyLou on 2022/5/30.
//  Copyright © 2022 zoneland. All rights reserved.
//

import UIKit

class CloudFileV3ZoneHeaderCell: UITableViewCell {

    
    @IBOutlet weak var headerTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override var frame: CGRect {
        didSet {
            var newFrame = frame
            newFrame.origin.x += 10
            newFrame.size.width -= 20
            super.frame = newFrame
        }
    }
    
    func setHeader(header: CloudFileV3CellViewModel) {
        self.headerTitleLabel.text = header.name ?? "unknow"
    }
}
