//
//  MeetingFormAttachmentItemCell.swift
//  O2Platform
//
//  Created by FancyLou on 2020/11/30.
//  Copyright © 2020 zoneland. All rights reserved.
//

import UIKit

class MeetingFormAttachmentItemCell: UITableViewCell {

    @IBOutlet weak var attachmentIcon: UIImageView!
    @IBOutlet weak var attachmentName: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func flushData(atta: OOMeetingAttachmentList, editMode: Bool) {
        if editMode {
            self.deleteBtn.isHidden = false
        } else {
            self.deleteBtn.isHidden = true
        }
        self.setFileTypeImage(ext: atta.extension)
        self.attachmentName.text = atta.name
    }
    
    
    private func setFileTypeImage(ext: String?) {
        if let type = ext {
            switch type {
            case "jpg", "png", "jepg", "gif":
                self.attachmentIcon.image = UIImage(named: "icon_img")
                break
            case "html":
                self.attachmentIcon.image = UIImage(named: "icon_html")
                break
            case "xls", "xlsx":
                self.attachmentIcon.image = UIImage(named: "icon_excel")
                break
            case "doc", "docx":
                self.attachmentIcon.image = UIImage(named: "icon_word")
                break
            case "ppt", "pptx":
                self.attachmentIcon.image = UIImage(named: "icon_ppt")
                break
            case "pdf":
                self.attachmentIcon.image = UIImage(named: "icon_pdf")
                break
            case "mp4":
                self.attachmentIcon.image = UIImage(named: "icon_mp4")
                break
            case "mp3":
                self.attachmentIcon.image = UIImage(named: "icon_mp3")
                break
            case "zip", "rar", "7z":
                self.attachmentIcon.image = UIImage(named: "icon_zip")
                break
            default :
                self.attachmentIcon.image = UIImage(named: "icon_moren")
                break
            }
        }else {
            self.attachmentIcon.image = UIImage(named: "icon_moren")
        }
    }
    
}
