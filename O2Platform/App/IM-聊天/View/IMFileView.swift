//
//  IMFileView.swift
//  O2Platform
//
//  Created by FancyLou on 2020/12/15.
//  Copyright © 2020 zoneland. All rights reserved.
//

import UIKit

class IMFileView: UIView {

    
    static let IMFileView_width: CGFloat = 175
    static let IMFileView_height: CGFloat = 75
    
    
    override func awakeFromNib() { }
    
    @IBOutlet weak var fileIcon: UIImageView!
    @IBOutlet weak var fileNameLabel: UILabel!
    
    func setFile(name: String, fileExt: String?) {
        self.fileNameLabel.text = name
//        self.setFileTypeImage(ext: fileExt)
        self.fileIcon.image = UIImage(named: O2.fileExtension2Icon(fileExt))
    }
    

//    private func setFileTypeImage(ext: String?) {
//        if let type = ext {
//            switch type {
//            case "jpg", "png", "jepg", "gif":
//                self.fileIcon.image = UIImage(named: "icon_img")
//                break
//            case "html":
//                self.fileIcon.image = UIImage(named: "icon_html")
//                break
//            case "xls", "xlsx":
//                self.fileIcon.image = UIImage(named: "icon_excel")
//                break
//            case "doc", "docx":
//                self.fileIcon.image = UIImage(named: "icon_word")
//                break
//            case "ppt", "pptx":
//                self.fileIcon.image = UIImage(named: "icon_ppt")
//                break
//            case "pdf":
//                self.fileIcon.image = UIImage(named: "icon_pdf")
//                break
//            case "mp4":
//                self.fileIcon.image = UIImage(named: "icon_mp4")
//                break
//            case "mp3":
//                self.fileIcon.image = UIImage(named: "icon_mp3")
//                break
//            case "zip", "rar", "7z":
//                self.fileIcon.image = UIImage(named: "icon_zip")
//                break
//            default :
//                self.fileIcon.image = UIImage(named: "icon_file_more")
//                break
//            }
//        }else {
//            self.fileIcon.image = UIImage(named: "icon_file_more")
//        }
//    }
}
