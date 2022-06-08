//
//  CloudFileMoveFolderV3Controller.swift
//  O2Platform
//
//  Created by FancyLou on 2022/6/7.
//  Copyright © 2022 zoneland. All rights reserved.
//

import UIKit
import CocoaLumberjack



typealias PickedFolderV3Callback = (_ folder: OOFolderV3) -> Void ///< 定义确认回调


class CloudFileMoveFolderV3Controller: UIViewController {
    
    
    // 打开企业网盘内部文件夹选择器
    static func chooseFolderV3VC(_ callback: @escaping PickedFolderV3Callback, zoneId:String, zoneName:String) -> CloudFileMoveFolderV3Controller? {
        let storyBoard = UIStoryboard(name: "CloudFile", bundle: nil)
        let destVC = storyBoard.instantiateViewController(withIdentifier: "cloudFileMoveV3Picker") as? CloudFileMoveFolderV3Controller
        destVC?.callback = callback
        let first = OOFolderV3()
        first.id = zoneId
        first.name = zoneName
        destVC?.breadcrumbList = [first]
        return destVC
    }
    

    @IBOutlet weak var breadcrumbView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    
    
    var callback: PickedFolderV3Callback?
    
    //面包屑 列表 可以传入顶级组织的OOFolder
    var breadcrumbList: [OOFolderV3] = []
    
    private lazy var cFileVM: CloudFileViewModel = {
        return CloudFileViewModel()
    }()
    
    //table 数据
    private var dataList: [OOFolderV3] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        //初始化tableView
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(UINib.init(nibName: "CloudFileMoveFolderCell", bundle: nil), forCellReuseIdentifier: "CloudFileMoveFolderCell")
        self.loadListData()
    }
     
    // MARK: - 后台数据服务
    
    private func loadListData() {
        self.refreshBreadcrumbBar()
        self.showLoading()
        //清空数据
        self.dataList = []
        
        let id = self.breadcrumbList[self.breadcrumbList.count-1].id ?? ""
        self.cFileVM.folderListV3(folderId: id)
            .then { (result)  in
                self.dataList = result
                self.hideLoading()
                self.tableView.reloadData()
            }.catch { (error) in
                DDLogError(error.localizedDescription)
                self.hideLoading()
        }
    }
    
    private func refreshBreadcrumbBar() {
        self.breadcrumbView.removeSubviews()
        var oX = CGFloat(4.0)
        let arrowW = CGFloat(24)
        let arrowH = CGFloat(32)
        breadcrumbList.forEachEnumerated { (index, bar) in
            let name = bar.name ?? ""
            var textColor:UIColor
            if self.breadcrumbList.count == (index+1) {
                textColor = UIColor(hex:"#666666")
            }else {
                textColor = base_color
            }
            let firstSize = name.getSize(with: 15)
            let oY = (self.breadcrumbView.bounds.height - firstSize.height) / 2
            let firstLabel = UILabel(frame: CGRect(x: CGFloat(oX), y: oY, width: firstSize.width, height: firstSize.height))
            firstLabel.textAlignment = .left
            let textAttributes = [NSAttributedString.Key.foregroundColor: textColor,NSAttributedString.Key.font:UIFont(name:"PingFangSC-Regular",size:15)!]
            firstLabel.attributedText = NSMutableAttributedString(string: name, attributes: textAttributes)
            firstLabel.sizeToFit()
            self.breadcrumbView.addSubview(firstLabel)
            oX += firstSize.width
            if self.breadcrumbList.count != (index+1) {
                let arrowY = (self.breadcrumbView.bounds.height - arrowH) / 2
                let arrowImage = UIImageView(frame: CGRect(x: CGFloat(oX), y: arrowY, width: arrowW, height: arrowH))
                arrowImage.image = UIImage(named: "arrow_r")
                arrowImage.contentMode = .scaleAspectFit
                self.breadcrumbView.addSubview(arrowImage)
                oX += arrowW
            }
            firstLabel.addTapGesture(action: { (rec) in
                DDLogDebug("点击了 \(index)")
                if self.breadcrumbList.count != (index+1) {
                    var newList:[OOFolderV3] = []
                    for i in 0...index {
                        newList.append(self.breadcrumbList[i])
                    }
                    self.breadcrumbList = newList
                    self.loadListData()
                }
            })
        }
        var size = self.breadcrumbView.contentSize
        size.width = oX
        self.breadcrumbView.showsHorizontalScrollIndicator = true
        self.breadcrumbView.contentSize = size
        self.breadcrumbView.bounces = true
    }

}


// MARK: - TableView delegate
extension CloudFileMoveFolderV3Controller: UITableViewDelegate, UITableViewDataSource  {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataList.count
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: CGRect.zero)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let folder = self.dataList[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CloudFileMoveFolderCell", for: indexPath) as? CloudFileMoveFolderCell {
            cell.delegatev3 = self
            cell.setDataV3(folder: folder)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //点击处理
        let folder = self.dataList[indexPath.row]
        self.breadcrumbList.append(folder)
        self.loadListData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension CloudFileMoveFolderV3Controller: CloudFileMoveV3ChooseDelegate {
    func choose(folder: OOFolderV3) {
        self.callback?(folder)
        self.popVC()
    }
}
