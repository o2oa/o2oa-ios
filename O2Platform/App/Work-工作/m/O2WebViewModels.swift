//
//  O2WebViewModels.swift
//  O2Platform
//
//  Created by FancyLou on 2019/4/18.
//  Copyright © 2019 zoneland. All rights reserved.
//

import HandyJSON


class O2WebViewUploadImage: HandyJSON {
    var mwfId: String!
    var callback: String!
    var fileId: String!
    var referencetype: String!
    var reference: String!
    var scale: Int!
    
    required init() {}
}


class O2WebViewBaseMessage<T : HandyJSON>: HandyJSON {
    var callback: String!
    var type: String!
    var data:T?
    
    required init() {}
}


class O2NotificationMessage<T : HandyJSON>: HandyJSON {
    var callback: String!
    /**
     alert
     confirm
     prompt
     vibrate
     toast
     actionSheet
     showLoading
     hideLoading
    **/
    var type: String!
    var data:T?
    
    required init() {}
}

class O2NotificationAlertMessage: HandyJSON {
    var message: String!
    var title: String!
    var buttonName: String!
    
    required init() {}
}
class O2NotificationConfirm: HandyJSON {
    var message: String!
    var title: String!
    var buttonLabels: [String]!
    
    required init() {}
}
class O2NotificationActionSheet: HandyJSON {
    var title: String!
    var cancelButton: String!
    var otherButtons: [String]!
    
    required init() {}
}
class O2NotificationToast: HandyJSON {
    var duration: Int!
    var message: String!
    
    required init() {}
}
class O2NotificationLoading: HandyJSON {
    var text: String!
    
    required init() {}
}

class O2UtilPicker: HandyJSON {
    var value: String!
    var startDate: String!
    var endDate: String!
    
    required init() {}
}

class O2UtilNavigation: HandyJSON {
    var title: String!
    required init() {}
}
//地图展现位置
struct O2UtilOpenMap: HandyJSON {
    var address: String?
    var addressDetail: String?
    var latitude: Double?
    var longitude: Double?
}

struct O2UtilPhoneInfo: HandyJSON {
    var screenWidth: String?
    var screenHeight: String?
    var brand:String?
    var model: String?
    var version: String?
    var netInfo: String?
    var operatorType: String?
}
// 扫码返回结果
struct O2UtilScanResult: HandyJSON {
    var text: String?
}
//身份选择传入参数对象
struct O2BizIdentityPickerMessage: HandyJSON {
    var topList: [String]?
    var multiple: Bool?
    var maxNumber: Int?
    var pickedIdentities: [String]?
    var duty: [String]?
}
//组织选择传入参数对象
struct O2BizUnitPickerMessage: HandyJSON {
    var topList: [String]?
    var multiple: Bool?
    var maxNumber: Int?
    var pickedDepartments: [String]?
    var orgType: String?
}
//群组选择传入参数对象
struct O2BizGroupPickerMessage: HandyJSON {
    var multiple: Bool?
    var maxNumber: Int?
    var pickedGroups: [String]?
}
//人员选择传入参数对象
struct O2BizPersonPickerMessage: HandyJSON {
    var multiple: Bool?
    var maxNumber: Int?
    var pickedUsers: [String]?
}
//复合选择传入参数对象
struct O2BizComplexPickerMessage: HandyJSON {
    var topList: [String]?
    var pickMode: [String]?
    var multiple: Bool?
    var maxNumber: Int?
    var pickedDepartments: [String]?
    var pickedIdentities: [String]?
    var pickedGroups: [String]?
    var pickedUsers: [String]?
    var duty: [String]?
    var orgType: String?
}

struct O2BizComplexPickerResults: HandyJSON {
    var results: [String]?
}
struct O2BizContactPickerResult: HandyJSON {
    var departments: [O2UnitPickerItem]?
    var identities: [O2IdentityPickerItem]?
    var groups: [O2GroupPickerItem]?
    var users: [O2PersonPickerItem]?
}

struct O2DeviceLocationResult: HandyJSON {
    var latitude: Double?
    var longitude: Double?
    var address: String?
}


struct O2BizPreviewDocMessage: HandyJSON {
    var url: String? // 文件下载地址
    var fileName: String? // 文件名称
}


struct O2UtilNavigationOpenOtherApp: HandyJSON {
    var schema: String? // 打开app schema url
}


struct O2UtilNavigationOpenWindow: HandyJSON {
    var url: String? // 新窗口打开网页
}


struct O2UtilNavigationOpenInnerApp: HandyJSON {
    var appKey: String? // 如果是portal，则需要传入  portalFlag：门户标识
    var portalFlag: String? // 门户标识
    var portalTitle: String? // 门户标题
    var portalPage: String? // 门户页面 id
}

