//
//  CloudFileV3ZoneCell.swift
//  O2Platform
//
//  Created by FancyLou on 2022/5/30.
//  Copyright © 2022 zoneland. All rights reserved.
//

import UIKit

protocol CloudFileV3ZoneCellMoreDelegate {
    func clickMore(data: CloudFileV3CellViewModel)
}

class CloudFileV3ZoneCell: UITableViewCell {

    @IBOutlet weak var zoneIconImageView: UIImageView!
    
    @IBOutlet weak var zoneNameLabel: UILabel!
    
    @IBOutlet weak var moreBtnView: UIView!
    
    var delegate: CloudFileV3ZoneCellMoreDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
 
    }
    
    override var frame: CGRect {
        didSet {
            var newFrame = frame
            newFrame.origin.x += 10
            newFrame.size.width -= 20
            super.frame = newFrame
        }
    }
    
    func setData(data: CloudFileV3CellViewModel) {
        switch(data.dataType) {
        case .favorite(let fav):
            self.zoneNameLabel.text = fav.name
            self.zoneIconImageView.image = UIImage(named: "cloud_file_favorite")
            break
        case .zone(let zone):
            self.zoneNameLabel.text = zone.name
            self.zoneIconImageView.image = UIImage(named: "cloud_file_zone")
            break
        default:
            self.zoneNameLabel.text = ""
            break
        }
        if let delegate = delegate {
            self.moreBtnView.addTapGesture { tap in
                delegate.clickMore(data: data)
            }
            self.moreBtnView.isHidden = false
        } else {
            self.moreBtnView.isHidden = true
        }
    }
}
