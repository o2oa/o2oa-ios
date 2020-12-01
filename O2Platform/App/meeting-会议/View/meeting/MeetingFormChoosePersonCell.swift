//
//  MeetingFormChoosePersonCell.swift
//  O2Platform
//
//  Created by FancyLou on 2020/11/25.
//  Copyright © 2020 zoneland. All rights reserved.
//

import UIKit
import Eureka

class MeetingFormChoosePersonCell: Cell<[OOPersonModel]>, CellType {
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var personsView: UICollectionView!
    
    
    private var persons: [OOPersonModel] = []
    
    var viewModel:OOMeetingCreateViewModel?
    var isUpdate = false // 更新会议只能增加不能删除
    
    override func setup() {
        super.setup()
        selectionStyle = .none
        self.personsView.dataSource = self
        self.personsView.delegate = self
        self.personsView.register(UINib.init(nibName: "OOMeetingPersonCell", bundle: nil), forCellWithReuseIdentifier: "OOMeetingPersonCell")
        self.personsView.register(UINib.init(nibName: "OMeetingPersonActionCell", bundle: nil), forCellWithReuseIdentifier: "OOMeetingPersonActionCell")
        
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
        if let list = row.value {
            self.persons = list
        }
        self.personsView.reloadData()
        
    }
    
    //会更新数据？
    func resetValue(persons: [OOPersonModel]) {
        self.row.value = persons
        self.row.updateCell()
        print("reset Value........")
    }
}

extension MeetingFormChoosePersonCell: UICollectionViewDataSource,UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.persons.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell:UICollectionViewCell?
        if indexPath.row == 0 {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OOMeetingPersonActionCell", for: indexPath)
            let uCell = cell as! OOMeetingPersonActionCell
            uCell.delegate = self
        }else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OOMeetingPersonCell", for: indexPath) as! OOMeetingPersonCell
            let uCell = cell as! (OOMeetingPersonCell & Configurable)
            let person = self.persons[indexPath.row - 1]
            uCell.viewModel = self.viewModel
            uCell.setupModel(p: person, ishiddenDelBtn: isUpdate)
             
        }
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row != 0 && !isUpdate {
            self.persons.remove(at: indexPath.row - 1)
            self.resetValue(persons: self.persons)
        }
    }
    
}


extension MeetingFormChoosePersonCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 75)
    }
}

extension MeetingFormChoosePersonCell: OOMeetingPersonActionCellDelegate {
    func addPersonActionClick(_ sender: UIButton) {
        //已经选择的人员
        var alreadyChoosePersons: [String] = []
        if !self.persons.isEmpty && !self.isUpdate {
            self.persons.forEach { (model) in
                if let dn = model.distinguishedName {
                    alreadyChoosePersons.append(dn)
                }
            }
        }
        if let v = ContactPickerViewController.providePickerVC(
            pickerModes: [ContactPickerType.person],
            multiple: true,
            initUserPickedArray: alreadyChoosePersons,
            pickedDelegate: { (result: O2BizContactPickerResult) in
                if let users = result.users {
                    var persons :[OOPersonModel] = []
                    users.forEach({ (item) in
                        let pm = OOPersonModel()
                        pm.id = item.id
                        pm.name = item.name
                        pm.genderType = item.genderType
                        pm.distinguishedName = item.distinguishedName
                        persons.append(pm)
                    })
                    if !persons.isEmpty {
                        if !self.persons.isEmpty && self.isUpdate {
                            self.persons.forEach { (model) in
                                persons.append(model)
                            }
                        }
                        self.resetValue(persons: persons)
                    }
                }
                
        }) {
            self.formViewController()?.navigationController?.pushViewController(v, animated: true)
        }
    }
}

final class MeetingFormChoosePersonCellRow: Row<MeetingFormChoosePersonCell>, RowType {
    required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<MeetingFormChoosePersonCell>(nibName: "MeetingFormChoosePersonCell")
    }
}
