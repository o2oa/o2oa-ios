//
//  MindMapNodeData.swift
//  O2Platform
//
//  Created by FancyLou on 2021/12/17.
//  Copyright © 2021 zoneland. All rights reserved.
//

import HandyJSON


// 图片Size对象
class MindNodeImageSize: NSObject, DataModel  {
    var width: Int?
    var height: Int?
    required override init(){}
}

// 节点数据对象
class MindNodeData: NSObject, DataModel {
    @objc var id: String?
    var created: Int?
    @objc var text: String?
    @objc var hyperlink: String?
    @objc var hyperlinkTitle: String?
    @objc var image: String?
    @objc var imageTitle: String?
    var imageSize: MindNodeImageSize?
    @objc var imageId: String?
    @objc var color: String?
    @objc var background: String?
    var progress: Int?
    var priority: Int?
    
    required override init(){}
    
    func isRoot()-> Bool {
        if let id = id, id == "root" {
            return true
        }
        return false
    }
}

// 节点对象
class MindNode: NSObject, DataModel  {
    var data: MindNodeData?
    var children: [MindNode]?
    
    required override init(){}
}

// 根节点
class MindRootNode: NSObject, DataModel {
    var root: MindNode?
    @objc var template: String?
    @objc var theme: String?
    @objc var version: String?
    
    required override init(){}
}
