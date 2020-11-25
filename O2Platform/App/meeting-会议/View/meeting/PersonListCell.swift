//
//  PersonListCell.swift
//  O2Platform
//
//  Created by FancyLou on 2020/11/18.
//  Copyright © 2020 zoneland. All rights reserved.
//

import UIKit
import Eureka

protocol PersonListCellDelegate {
    func clickAccept(_ completedBlock: @escaping () -> Void)
    func clickReject(_ completedBlock: @escaping () -> Void)
}

class PersonListCell: Cell<OOMeetingInfo>, CellType {

    @IBOutlet weak var cellTitle: UILabel!
    
    @IBOutlet weak var personsView: UICollectionView!
    @IBOutlet weak var acceptBtn: UIButton!
    @IBOutlet weak var rejectBtn: UIButton!
    
    
    var viewModel:OOMeetingCreateViewModel?
    var delegate: PersonListCellDelegate?
    
    private var persons: [OOPersonModel] = []
    
    override func setup() {
        super.setup()
        self.personsView.dataSource = self
        self.personsView.delegate = self
        self.personsView.register(UINib.init(nibName: "OOMeetingPersonCell", bundle: nil), forCellWithReuseIdentifier: "OOMeetingPersonCell")
    }
    
    override func update() {
        super.update()
        textLabel?.text = nil //去掉默认标题
        self.cellTitle.text =  row.title ?? ""
        if #available(iOS 13.0, *) {
            self.cellTitle.textColor = row.isDisabled ? .tertiaryLabel : .label
        } else {
            self.cellTitle.textColor = row.isDisabled ? .gray : .black
        }
        self.persons.removeAll()
        if let meeting = row.value {
            //邀请人员
            if let invitePersonList = meeting.invitePersonList {
                for person in invitePersonList {
                    let p = OOPersonModel()
                    p.name = person.split("@").first
                    p.distinguishedName = person
                    self.persons.append(p)
                }
            }
            //是否显示确认按钮
            if meeting.myWaitAccept == true {
                self.acceptBtn.isHidden = false
                self.rejectBtn.isHidden = false
            }
        }
        
        self.personsView.reloadData()
    }
    
    //接受邀请
    @IBAction func acceptAction(_ sender: UIButton) {
        self.delegate?.clickAccept({
            self.acceptBtn.isHidden = true
            self.rejectBtn.isHidden = true
        })
    }
    //拒绝要求
    @IBAction func rejectAction(_ sender: UIButton) {
        self.delegate?.clickReject({
            self.acceptBtn.isHidden = true
            self.rejectBtn.isHidden = true
        })
    }
    
}
extension PersonListCell: UICollectionViewDataSource,UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.persons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OOMeetingPersonCell", for: indexPath) as? OOMeetingPersonCell {
            let person = self.persons[indexPath.row]
            cell.viewModel = self.viewModel
            cell.setupModel(p: person, ishiddenDelBtn: true)
            return cell
        }else {
            return UICollectionViewCell()
        }
    }
    
    
}

extension PersonListCell: UICollectionViewDelegateFlowLayout {
   
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 75)
    }
}


final class PersonListRow: Row<PersonListCell>, RowType {
    required init(tag: String?) {
        super.init(tag: tag)
         cellProvider = CellProvider<PersonListCell>(nibName: "PersonListCell")
    }
}
