//
//  SettingHomeCell.swift
//  O2Platform
//
//  Created by 刘振兴 on 16/7/6.
//  Copyright © 2016年 zoneland. All rights reserved.
//

import UIKit

class SettingHomeCell: UITableViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var bottomLineView: UIView!
//    
//    var cellModel:SettingHomeCellModel?{
//        didSet {
//            //设置
//            self.iconImageView.image = UIImage(named: (cellModel?.iconName)!)
//            self.titleLabel.text = cellModel?.title
//            
//            if let text = cellModel?.status {
//                self.statusLabel.text = text
//            }else{
//                self.statusLabel.text = ""
//            }
//        }
//    }
    
    override var frame: CGRect {
        didSet {
            var newFrame = frame
            newFrame.origin.x += 10
            newFrame.size.width -= 20
            super.frame = newFrame
        }
    }
    
    func setModel(model: SettingHomeCellModel, isShowBottom: Bool)  {
        //设置
        self.iconImageView.image = UIImage(named: (model.iconName)!)
        self.titleLabel.text = model.title
        if let text = model.status {
            self.statusLabel.text = text
        }else{
            self.statusLabel.text = ""
        }
        if isShowBottom {
            self.bottomLineView.isHidden = false
        } else {
            self.bottomLineView.isHidden = true
        }
    }
    
//    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    

}
