//
//  CloudFilePreviewController.swift
//  O2Platform
//
//  Created by FancyLou on 2019/11/8.
//  Copyright © 2019 zoneland. All rights reserved.
//

import UIKit
import CocoaLumberjack
import QuickLook


//文件预览
class CloudFilePreviewController: QLPreviewController {

    var currentFileURLS:[NSURL] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.dataSource = self
        if let url = self.currentFileURLS[0].path {
            if url.lowercased().hasSuffix(".png") || url.lowercased().hasSuffix(".jpg") || url.lowercased().hasSuffix(".jpeg") {
                self.loadImageDownloadBtn()
            }
        }
    }
    
    
    
    private func loadImageDownloadBtn() {
        let downImageBtn = UIImageView(frame: CGRect(x: SCREEN_WIDTH - 48 - 12 , y: SCREEN_HEIGHT - 48 - 10, width: 48, height: 48))
        downImageBtn.image = UIImage(named: "icon_download")
        self.view.addSubview(downImageBtn)
        downImageBtn.isHidden = false
        downImageBtn.addTapGesture { tap in
            self.saveImageToAlbum()
        }
    }
    
    private func saveImageToAlbum() {
        DDLogDebug("保存图片到相册！")
        if let url = self.currentFileURLS[0].path {
            DDLogDebug("path: \(url)")
            UIImageWriteToSavedPhotosAlbum(UIImage(contentsOfFile: url)!, self, #selector(self.saveImage(image:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    @objc func saveImage(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafeRawPointer) {
        if let e = error {
            DDLogError(e.localizedDescription)
            self.showError(title: "保存图片失败！")
        } else {
            self.showSuccess(title: "保存图片到相册成功！")
        }
    }

}

extension CloudFilePreviewController: QLPreviewControllerDelegate,QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return self.currentFileURLS.count
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return self.currentFileURLS[index]
    }
    
    
}
