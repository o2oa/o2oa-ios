//
//  IMProcessCardView.swift
//  O2Platform
//
//  Created by FancyLou on 2022/3/16.
//  Copyright © 2022 zoneland. All rights reserved.
//

import UIKit

class IMProcessCardView: UIView {

    
    static let IMProcessCardView_width: CGFloat = 200
    static let IMProcessCardView_height: CGFloat = 110
    
    
    @IBOutlet weak var processNameLabel: UILabel!
    @IBOutlet weak var workTitleLabel: UILabel!
    
    @IBOutlet weak var appIconImage: UIImageView!
    
    @IBOutlet weak var appNameLabel: UILabel!
    
    
    
    override func awakeFromNib() { }
    
    func setCardInfo(info: IMMessageBodyInfo) {
        self.processNameLabel.text = "【\(info.processName ?? "")】"
        self.workTitleLabel.text  = "\(info.title ?? "无标题")"
        if let appId = info.application {
            ImageUtil.shared.getProcessApplicationIcon(id: appId)
                .then { (image)  in
                    self.appIconImage?.image = image
            }.catch { (err) in
                self.appIconImage?.image = UIImage(named: "todo_8")
            }
        }
        self.appNameLabel.text = "\(info.applicationName ?? "")"
        
    }
}
