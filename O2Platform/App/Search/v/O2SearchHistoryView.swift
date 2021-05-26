//
//  O2SearchHistoryView.swift
//  O2Platform
//
//  Created by FancyLou on 2021/5/24.
//  Copyright © 2021 zoneland. All rights reserved.
//

import UIKit
import CocoaLumberjack

protocol O2SearchHistoryDelegate {
    func clickToSearchTag(tag: String)
}

class O2SearchHistoryView: UIView {
    
    var delegate: O2SearchHistoryDelegate?
    var tagsListView: UICollectionView?
    var deleteView: UIView?
    
    var historyList: [String] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.deleteView = UIView(frame: CGRect(x: 0, y: 10, width: self.width, height: 30))
        self.addSubview(self.deleteView!)
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        self.tagsListView = UICollectionView(frame: CGRect(x: 15, y: 50, width: self.width - 30, height: 250), collectionViewLayout: layout)
        self.tagsListView?.delegate = self
        self.tagsListView?.dataSource = self
        self.tagsListView?.backgroundColor = .clear
        self.tagsListView?.register(O2SearchHistoryCell.self, forCellWithReuseIdentifier: "O2SearchHistoryCell")
        self.addSubview(self.tagsListView!)
        
        
        let delIcon = UIImageView(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
        delIcon.image = UIImage(named: "icon_delete_sign")
        let delLabel = UILabel(frame: .zero)
        let text = L10n.Search.deleteAllSearchHistory
        let fontSize: CGFloat = 12.0
        let textSize = text.getSize(with: fontSize)
        delLabel.text = text
        delLabel.font = delLabel.font.withSize(fontSize)
        delLabel.textColor = UIColor(hex: "#999999")
        
        let deleteContentWidth = textSize.width + 22 + 10 // 文字宽度 图片宽度22 间隔10
        let firstleft = (width - deleteContentWidth)  / 2
        let secondLeft = firstleft + 22 + 10
        
        self.deleteView?.addSubview(delIcon)
        delIcon.snp.makeConstraints { (maker) in
            maker.left.equalTo(self.deleteView!.snp.left).offset(firstleft)
            maker.top.equalTo(self.deleteView!.snp.top)
        }
        self.deleteView?.addSubview(delLabel)
        delLabel.snp.makeConstraints { (maker) in
            maker.left.equalTo(self.deleteView!.snp.left).offset(secondLeft)
            maker.centerY.equalTo(delIcon.snp.centerY)
//            maker.top.equalTo(self.deleteView!.snp.top)
        }
        // 点击
        self.deleteView?.addTapGesture(action: { (tap) in
            DDLogDebug("tap gesture")
            self.clickDeleteAllHistory()
        })
        
        self.historyList = O2UserDefaults.shared.searchHistory
        self.tagsListView?.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc private func clickDeleteAllHistory() {
        DDLogDebug("点击了全部删除")
        self.historyList = []
        O2UserDefaults.shared.searchHistory = []
        self.tagsListView?.reloadData()
    }
    
    func addSearchHistory(key: String) {
        let history = O2UserDefaults.shared.searchHistory
        var new: [String] = []
        if !history.contains(key) {
            new.append(key)
        }
        history.forEach { (s) in
            new.append(s)
        }
        O2UserDefaults.shared.searchHistory = new
        self.historyList = new
        self.tagsListView?.reloadData()
    }
    
    
}

extension O2SearchHistoryView: UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.historyList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = self.historyList[indexPath.row].getSize(with: 16.0)
        return CGSize(width: size.width + 20, height: 28)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "O2SearchHistoryCell", for: indexPath) as? O2SearchHistoryCell {
            cell.setTitle(title: self.historyList[indexPath.row])
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tag = self.historyList[indexPath.row]
        DDLogDebug("点击了 \(tag)")
        if self.delegate != nil {
            self.delegate?.clickToSearchTag(tag: tag)
        }
    }
    
}


class O2SearchHistoryLayout: UICollectionViewFlowLayout {
    override init() {
        super.init()
        itemSize = CGSize(width: 100, height: 30)
        scrollDirection = .vertical
        minimumLineSpacing = 8
        minimumInteritemSpacing = 8
        sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
