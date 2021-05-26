//
//  O2SearchHistoryCell.swift
//  O2Platform
//
//  Created by FancyLou on 2021/5/24.
//  Copyright © 2021 zoneland. All rights reserved.
//

import UIKit

class O2SearchHistoryCell: UICollectionViewCell {
    
    var title: UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI() {
        self.title = UILabel()
        self.title!.backgroundColor = UIColor(hex: "#E6E6E6")
        self.title!.font = UIFont.systemFont(ofSize: 16)
        self.title!.layer.cornerRadius = 14.0
        self.title!.layer.masksToBounds = true
        self.title!.textAlignment = .center
        self.title!.textColor = UIColor(hex: "#333333")
        self.title!.text = ""
        self.contentView.addSubview(self.title!)
    }
    
    func setTitle(title: String)  {
        print(title)
        self.title?.text = title
        self.title?.frame = CGRect(x: 0, y: 10, width: title.getSize(with: 16.0).width + 20, height: 28)
    }
}
