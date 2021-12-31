//
//  O2CustomViewProtocol.swift
//  O2Platform
//
//  Created by FancyLou on 2021/12/30.
//  Copyright © 2021 zoneland. All rights reserved.
//

import UIKit


protocol O2CustomViewProtocol {
    
    var contentView: UIView! { get }
    
    func commonInit(for customViewName: String)
}

extension O2CustomViewProtocol where Self: UIView {
    func commonInit(for customViewName: String) {
        Bundle.main.loadNibNamed(customViewName, owner: self, options: nil)
        addSubview(contentView)
        contentView.backgroundColor = .clear
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}
