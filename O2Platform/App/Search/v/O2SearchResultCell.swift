//
//  O2SearchResultCell.swift
//  O2Platform
//
//  Created by FancyLou on 2021/5/25.
//  Copyright © 2021 zoneland. All rights reserved.
//

import UIKit

class O2SearchResultCell: UITableViewCell {

    @IBOutlet weak var appLabel: UILabel! // 应用名称
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var createDayLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var typeNameLabel: UILabel! // 栏目 还是 流程
    @IBOutlet weak var typeValueLabel: UILabel! // 栏目名称 流程名称
    @IBOutlet weak var deptNameLabel: UILabel!
    @IBOutlet weak var personLabel: UILabel!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // 边距
    override var frame: CGRect {
        didSet {
            var newFrame = frame
            newFrame.origin.x += 10
            newFrame.size.width -= 20
            newFrame.origin.y += 10
            newFrame.size.height -= 20
            super.frame = newFrame
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setDataV2(data: O2SearchV2Entry, currentKey: String) {
        let title = data.title
        if  !title.isBlank {
            let titleAS = NSMutableAttributedString(string: title)
            let keyRange = NSString(string: title).range(of: currentKey)
            titleAS.addAttribute(.foregroundColor, value: UIColor.red, range: keyRange)
            self.titleLabel.attributedText = titleAS
        } else {
            self.titleLabel.text = "无标题"
        }
        let summaryAS = NSMutableAttributedString(string: data.summary)
        let summaryRange = NSString(string: data.summary).range(of: currentKey)
        summaryAS.addAttribute(.foregroundColor, value: UIColor.red, range: summaryRange)
        self.summaryLabel.attributedText = summaryAS
        self.createDayLabel.text = data.updateTime.length > 10 ? data.updateTime.subString(from: 0, to: 10) : data.updateTime
        self.deptNameLabel.text = data.creatorUnit.contains("@") ? data.creatorUnit.split("@")[0] : data.creatorUnit
        self.personLabel.text = data.creatorPerson.contains("@") ? data.creatorPerson.split("@")[0] : data.creatorPerson
    }
    
//    func setData(data: O2SearchEntry, currentKey: String) {
//        if data.type == "cms" {
//            self.appLabel.text = data.appName
//            self.typeNameLabel.text = L10n.Search.cmsCategory
//            self.typeValueLabel.text = data.categoryName
//        } else {
//            self.appLabel.text = data.applicationName
//            self.typeNameLabel.text = L10n.Search.processName
//            self.typeValueLabel.text = data.processName
//        }
//        if let title = data.title, !title.isBlank {
//            let titleAS = NSMutableAttributedString(string: title)
//            let keyRange = NSString(string: title).range(of: currentKey)
//            titleAS.addAttribute(.foregroundColor, value: UIColor.red, range: keyRange)
//            self.titleLabel.attributedText = titleAS
//        } else {
//            self.titleLabel.text = "无标题"
//        }
//        let summaryAS = NSMutableAttributedString(string: data.summary ?? "")
//        let summaryRange = NSString(string: data.summary ?? "").range(of: currentKey)
//        summaryAS.addAttribute(.foregroundColor, value: UIColor.red, range: summaryRange)
//        self.summaryLabel.attributedText = summaryAS
//        self.createDayLabel.text = data.updateTime?.length ?? 0 > 10 ? data.updateTime?.subString(from: 0, to: 10) : data.updateTime
//        if data.creatorUnit != nil {
//            self.deptNameLabel.text = data.creatorUnit!.contains("@") ? data.creatorUnit!.split("@")[0] : data.creatorUnit
//        } else {
//            self.deptNameLabel.text = ""
//        }
//        if data.creatorPerson != nil {
//            self.personLabel.text = data.creatorPerson!.contains("@") ? data.creatorPerson!.split("@")[0] : data.creatorPerson
//        } else {
//            self.personLabel.text = ""
//        }
//        
//    }
    
}
