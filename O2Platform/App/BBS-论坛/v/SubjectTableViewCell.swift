//
//  SubjectTableViewCell.swift
//  O2Platform
//
//  Created by 刘振兴 on 2016/11/4.
//  Copyright © 2016年 zoneland. All rights reserved.
//

import UIKit
import SDWebImage
import Alamofire
import ObjectMapper
import CocoaLumberjack

class SubjectTableViewCell: UITableViewCell {
     
    
    @IBOutlet weak var topSubjectImageView: UIImageView!
    
    @IBOutlet weak var subjectTitleLabel: UILabel!

    @IBOutlet weak var subjectNameLabel: UILabel!
    
    @IBOutlet weak var subjectPubDateLabel: UILabel!
    
    @IBOutlet weak var subjectViewNumberLabel: UILabel!
    
    @IBOutlet weak var subjectReplyNumberLabel: UILabel!
    
    var bbsSubjectData:BBSSubjectData? {
        didSet {
            self.topSubjectImageView.isHidden = !(bbsSubjectData?.isTopSubject)!
            let type = "[\(bbsSubjectData?.type ?? "")]"
            let allTitle =  "\(type) \(bbsSubjectData?.title ?? "")"
            let mas = NSMutableAttributedString(string: allTitle)
            mas.addAttributes([NSAttributedString.Key.foregroundColor:UIColor.hexInt(0x999999)], range: NSRange(location: 0, length: type.length))
            self.subjectTitleLabel.attributedText = mas
            self.subjectNameLabel.text = (bbsSubjectData?.creatorName?.contains("@"))! ? bbsSubjectData?.creatorName?.split("@")[0] : bbsSubjectData?.creatorName
            self.subjectViewNumberLabel.text = bbsSubjectData?.viewTotal?.toString
            self.subjectReplyNumberLabel.text = bbsSubjectData?.replyTotal?.toString
            if let time = bbsSubjectData?.latestReplyTime, let date = Date.date(time) {
                self.subjectPubDateLabel.text = date.friendlyTime()
            } else {
                self.subjectPubDateLabel.text = ""
            }
            
            
            //let urlString = AppDelegate.o2Collect.generateURLWithAppContextKey(ContactContext.contactsContextKey, query: ContactContext.personIconByNameQuery, parameter: ["##name##":bbsSubjectData?.creatorName as AnyObject])
            //let url = URL(string: urlString!)
            
            //self.subjectPersonIconImageView.af_setImage(withURL: url!)
//            let urlstr = AppDelegate.o2Collect.generateURLWithAppContextKey(ContactContext.contactsContextKeyV2, query: ContactContext.personIconByNameQueryV2, parameter: ["##name##":bbsSubjectData?.creatorName as AnyObject], generateTime: false)
//            let url = URL(string: urlstr!)
//            self.subjectPersonIconImageView.hnk_setImageFromURL(url!)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
