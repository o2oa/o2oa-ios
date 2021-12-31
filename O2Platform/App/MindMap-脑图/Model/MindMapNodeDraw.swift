//
//  MindMapNodeDraw.swift
//  O2Platform
//
//  Created by FancyLou on 2021/12/17.
//  Copyright © 2021 zoneland. All rights reserved.
//

import UIKit

// 绘画使用 每个节点对应的绘画对象， 用于计算节点大小、位置等信息
struct MindNodeSize {
    // 数据对象
    var data: MindNodeData?
    // 节点方块大小位置
    var nodeBoxRect: CGRect
    var nodeBoxBgColor: UIColor = .blue
    var nodeSelected: Bool = false // 是否选中
    
    // 图片
    var imageRect: CGRect?
    
    // 文字
    var textRect: CGRect?
    var textColor: UIColor = .white
    // 进度
    var progressRect: CGRect?
    // 等级
    var priorityRect: CGRect?
    // 超链接
    var hyperlinkRect: CGRect?
    
    // 层级
    var level: Int = 0
    
    // 子元素占据的大小
    var childrenSize: CGSize = CGSize(width: 0, height: 0)
    // 子元素
    var children:[MindNodeSize] = []
    // 包含自身和子元素整个区域的大小
    var allSize: CGSize = CGSize(width: 0, height: 0)
    
    
}

// 绘画使用的 线条对象
struct MindNodeLine {
    var start:CGPoint
    var end:CGPoint
}

