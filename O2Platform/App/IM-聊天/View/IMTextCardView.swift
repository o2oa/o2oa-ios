//
//  IMTextCardView.swift
//  O2Platform
//
//  Created by FancyLou on 2023/5/5.
//  Copyright © 2023 zoneland. All rights reserved.
//

import UIKit

class IMTextCardView: UIView {
    
    static let IMTextCardView_width: CGFloat = 200
    static let IMTextCardView_height: CGFloat = 110
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var descLabel: UILabel!
    
    override func awakeFromNib() { }
    
    
    func setupTextCard(title: String, desc: String) {
        self.titleLabel.text = title
        self.descLabel.text = desc
    }
    
}
