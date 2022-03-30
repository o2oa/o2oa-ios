//
//  WaterMarkView.swift
//  O2Platform
//
//  Created by FancyLou on 2022/3/30.
//  Copyright © 2022 zoneland. All rights reserved.
//

import UIKit
import CocoaLumberjack

///
/// 水印
///  这个view 是一个很大的正方形，目前是SCREEN_HEIGHT的3倍宽高
///   里面放一个tableview 把水印文字放入到tableview中
///    最后把这个水印的整个view放到页面上，并且旋转角度 并裁减超出部分
///使用：   let waterView = WaterMarkView.addWaterMarkView(waterMarkText: "你的姓名")
///        self.view.addSubview(waterView)
///        self.view.layer.masksToBounds = true // 裁剪 因为水印是一个很大的view

class WaterMarkView: UIView {
    
    
    
    
//    private var waterMarkView: WaterMarkView?
//
//    open func addWaterMark(view: UIView, waterMarkText: String) {
//
//        if waterMarkView == nil {
//            waterMarkView = WaterMarkView()
//            waterMarkView?.frame = view.bounds
//            if let wlayer = waterMarkView?.layer {
//                view.layer.addSublayer(wlayer)
//            }
//            waterMarkView?.isUserInteractionEnabled = false
//        }
//    }
//
//    // 添加文本水印
//    private func watemarkWithText(waterMarkText: String) -> UIImage? {
//        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0)]
//        let size = waterMarkText.getSize(with: 14.0)
//        UIGraphicsBeginImageContextWithOptions(size, false, 0)
//        waterMarkText.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height), withAttributes: attributes)
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return image
//    }
    
    
    private var tableView: UITableView? = nil
    private var waterMarkText: String = ""
    private var dataSource: [String] = []
    
    public static let lineHeight:Int = 48 // 行高
    let cellIdentifier = "WaterMarkTableViewCell"
    
    
    static func addWaterMarkView(waterMarkText: String) -> WaterMarkView {
        let watermarkView = WaterMarkView(frame: CGRect(x: -SCREEN_HEIGHT, y: -SCREEN_HEIGHT, width: SCREEN_HEIGHT*3, height: SCREEN_HEIGHT*3), waterMarkText: waterMarkText)
        watermarkView.transform = CGAffineTransform(rotationAngle: -Double.pi*0.25)
        watermarkView.isUserInteractionEnabled = false
        return watermarkView
    }
    
    
    init(frame: CGRect, waterMarkText: String) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.waterMarkText = waterMarkText
        self.setupUI()
    }
    

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.tableView?.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
    }
    
    private func setupUI() {
        if self.tableView == nil {
            self.tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height), style: .grouped)
            self.addSubview(self.tableView!)
            self.tableView?.estimatedRowHeight = 0
            self.tableView?.estimatedSectionHeaderHeight = 0
            self.tableView?.estimatedSectionFooterHeight = 0
            self.tableView?.showsVerticalScrollIndicator = false
            self.tableView?.separatorStyle = .none
            self.tableView?.backgroundColor = .clear
            self.tableView?.isUserInteractionEnabled = false
        }
        self.tableView?.register(WaterMarkTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        self.loadDataSource()
        DDLogDebug("setup ui .......\(self.tableView == nil)")
    }
    
    
    private func loadDataSource() {
        
        for i in 0...Int(Int(Float(SCREEN_HEIGHT))*3/WaterMarkView.lineHeight) {
            var str = ""
            for _ in 0...50 {
                str += "        \(self.waterMarkText)"
            }
            if (i % 2 == 0) {
                self.dataSource.append(str)
            } else {
                self.dataSource.append("        \(str)")
            }
        }
        self.tableView?.reloadData()
    }
}


extension WaterMarkView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        DDLogDebug("cell...........")
        if let c = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? WaterMarkTableViewCell {
            c.setText(text: self.dataSource[indexPath.row])
            c.selectionStyle = .none
            c.isUserInteractionEnabled = false
            return c
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(WaterMarkView.lineHeight)
    }
    
    
    
}
