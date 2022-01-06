//
//  O2MindMapCanvasView.swift
//  O2Platform
//
//  Created by FancyLou on 2021/12/17.
//  Copyright © 2021 zoneland. All rights reserved.
//

import UIKit
import CocoaLumberjack


class O2MindMapCanvasView: UIView {
    
    ///
    ///主题相关的颜色字体等等
    ///
    static let canvasBgColor = UIColor(hex: "#fafafa") // 画布背景色 要和外面的UIViewController背景色一致
    
    private let font = UIFont(name: "PingFangSC-Regular", size: 14) // 字体
    private let textStyle = NSMutableParagraphStyle()
    
    private let rootBoxColor = UIColor(hex: "#618fb1") // root 节点背景色
    private let rootTextColor = UIColor.white // root 节点文字颜色
    private let boxColor = UIColor(hex: "#eaf0f4") // 节点背景色
    private let boxTextColor = UIColor.black // 节点文字颜色
    private let selectedBoxBorderColor = base_color // 选中状态边框颜色
    
    
    
    private var canvasNode: MindNodeSize?
    private var imageMap:[String:UIImage] = [:]
    private var lines:[MindNodeLine] = []
    
    // 转化脑图数据成可绘制数据对象
    func resolveData(json: MindRootNode) ->  (MindNodeSize, CGSize)? {
        if let root = json.root {
            lines = [] // 清空
            if let rootNode = self.recursiveNode(node: root, level: 0) {
               return self.paintElementPosition(root: rootNode)
            } else {
                DDLogError("计算节点内部大小返回nil")
            }
        } else {
            DDLogError("没有root数据")
        }
        return nil
    }
    
    // 重绘内容
    func repaintContent(node: MindNodeSize) {
        self.canvasNode = node
        self.downloadImagesAndRePaint(node: node)
        self.setNeedsDisplay()
    }
    
    // 点击画布 如果点击到脑图块 显示选中状态
    private var selectedNode: MindNodeData? = nil
    private var needRePaintForClick = false
    
    // 点击画布 选中节点或取消选中节点
    func clickCanvasWithPoint(point: CGPoint)-> MindNodeData? {
        if let node = self.canvasNode {
            DDLogDebug("点击了canvas。。。。。。。。。。。")
            self.needRePaintForClick = false // 先设置false
            self.recursionFindSelected(point: point, node: node) // 递归查找
            if !self.needRePaintForClick && self.selectedNode != nil { // 取消选中
                self.selectedNode = nil
                self.setNeedsDisplay() // 重绘
            } else if self.needRePaintForClick { // 选中
                self.setNeedsDisplay()  // 重绘
            } else {
                DDLogDebug("不需要动。。。。。。。。")
            }
        }
        return self.selectedNode
    }
    
    // 查询当前选中节点的位置对象 中心节点
    func getSelectNodePosition()-> (MindNodeSize?, MindNodeSize?) {
        if let node = self.canvasNode, self.selectedNode != nil {
            let size = self.recursionFindSelectedSize(node: node)
            return (size, self.canvasNode)
        } else {
            return (nil, self.canvasNode)
        }
    }
    
    
    // 外部设置选中的节点，比如新建节点等时候
    func reSelected(newSelected: MindNodeData?) {
        self.selectedNode = newSelected
    }
    
    // 保存成图片
    func saveAsImage()-> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, UIScreen.main.scale)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if let node = canvasNode {
            self.recursionPaint(node: node)
        }
        if lines.count > 0 {
            self.paintLines()
        }
    }
    
    // 下载图片 放到map中 并重绘
    private func downloadImagesAndRePaint(node: MindNodeSize) {
        if let image = node.data?.image {
            self.downloadImage(imageUrl: image)
        }
        if node.children.count > 0 {
            for child in node.children {
                self.downloadImagesAndRePaint(node: child)
            }
        }
    }
    // 绘制所有的连接线
    private func paintLines() {
        for line in lines {
            let bifurcationX = line.start.x < line.end.x ? (line.end.x - line.start.x) / 2 : (line.start.x - line.end.x) / 2
            let bifurcationPoint = line.start.x < line.end.x ? CGPoint(x:line.start.x + bifurcationX, y:line.start.y) : CGPoint(x:line.start.x - bifurcationX, y:line.start.y)
            let turnPoint = CGPoint(x: bifurcationPoint.x, y: line.end.y)
            let linePath = UIBezierPath()
            rootBoxColor.set()
            linePath.lineWidth = 1
            linePath.lineCapStyle = .round
            linePath.lineJoinStyle = .miter
            linePath.move(to: line.start)
            //第一个参数point为path终点坐标，第二个和第三个point参数为控制点坐标
            linePath.addCurve(to: line.end, controlPoint1: bifurcationPoint, controlPoint2: turnPoint)
            linePath.stroke()
        }
    }
    // 递归绘出所有内容
    private func recursionPaint(node: MindNodeSize) {
        let box = node.nodeBoxRect
        let bpath = UIBezierPath(roundedRect: box, cornerRadius: 8)
        if let nodeBg = node.data?.background, !nodeBg.isBlank {
            UIColor(hex: nodeBg).set()
        } else {
            if node.level == 0 {
                rootBoxColor.set()
            } else {
                boxColor.set()
            }
        }
        bpath.fill()
        bpath.stroke()
        // 选中的 加边框
        if node.data?.id != nil && self.selectedNode != nil && node.data?.id == self.selectedNode?.id {
            let borderBox = CGRect(x: box.minX - 1, y: box.minY - 1, width: box.width + 2, height: box.height + 2)
            let borderPath = UIBezierPath(roundedRect: borderBox, cornerRadius: 8)
            selectedBoxBorderColor.set()
            borderPath.lineWidth = 2
            borderPath.stroke()
        }
        // 图片
        if let imageRect = node.imageRect, let imageId = node.data?.image, let image = imageMap[imageId] {
            image.draw(in: imageRect)
        }
        // 第二行 图表
        if let priority = node.priorityRect {
            UIImage(named: self.priorityImg(priority: node.data?.priority))?.draw(in: priority)
        }
        if let progress = node.progressRect {
            UIImage(named: self.progressImg(progress: node.data?.progress))?.draw(in: progress)
        }
        if let link = node.hyperlinkRect {
            UIImage(named: "link")?.draw(in: link)
        }
        // 第三行 文字
        var textColor: UIColor = .black
        if let nodeTextColor = node.data?.color, !nodeTextColor.isBlank {
            textColor = UIColor(hex: nodeTextColor)
        } else {
            if node.level == 0 {
                textColor = rootTextColor
            } else {
                textColor = boxTextColor
            }
        }
        if let textRect = node.textRect, let text = node.data?.text {
            textStyle.alignment = NSTextAlignment.center
            textStyle.lineBreakMode = .byWordWrapping
            let textAtt:  [NSAttributedString.Key : Any] = [NSAttributedString.Key.font: font!, NSAttributedString.Key.foregroundColor: textColor, NSAttributedString.Key.paragraphStyle: textStyle]
            NSAttributedString(string: text, attributes: textAtt).draw(in: textRect)
        }
        if node.children.count > 0 {
            for child in node.children {
                self.recursionPaint(node: child)
            }
        }
    }
    // 优先级图标
    private func priorityImg(priority: Int?) -> String {
        if let p = priority {
            return "priority\(p)"
        }
        return "priorityx"
    }
    // 进度图标
    private func progressImg(progress: Int?) -> String {
        if let p = progress {
            return "progress\(p)"
        }
        return "progressx"
    }
    
    // 递归查找是否有选中的节点
    private func recursionFindSelected(point: CGPoint, node: MindNodeSize) {
         
        let box = node.nodeBoxRect
        if ( point.x >= box.minX && point.x <= box.maxX ) && (point.y >= box.minY && point.y <= box.maxY){
            self.needRePaintForClick = true
            self.selectedNode = node.data
            DDLogInfo("选中了。。。。。\(node.data?.id ?? "")")
            return
        }
        if node.children.count > 0 {
            for child in node.children {
                self.recursionFindSelected(point: point, node: child)
            }
        }
    }
    
    // 递归查询选中的那个节点的 Size对象
    private func recursionFindSelectedSize(node: MindNodeSize) -> MindNodeSize? {
        if node.data?.id != nil && node.data?.id == self.selectedNode?.id {
            return node
        } else {
            for item in node.children {
                if let childSize = self.recursionFindSelectedSize(node: item) {
                    return childSize
                }
            }
            return nil
        }
    }
    
    // 计算整个画布以及元素的位置
    private func paintElementPosition(root: MindNodeSize)-> (MindNodeSize, CGSize) {
        let cal = self.calcCanvasSize(root: root)
        let canvasSize = cal.0
        let leftChildrenSize = cal.1
        let rightChildrenSize = cal.2
        let leftChildren = cal.3
        let rightChildren = cal.4
         
        
        // root 放中间
        let left = (canvasSize.width - root.nodeBoxRect.width) / 2
        let top = (canvasSize.height - root.nodeBoxRect.height) / 2
        var newRoot = self.innerElementPosition(top: top, left: left, node: root)
        
        var newChildrenNode:[MindNodeSize] = []
        // 右边区域
        if rightChildren.count > 0 {
            var rightTop = (canvasSize.height - rightChildrenSize.height) / 2
            var subChildrenHeight:CGFloat = 0.0
            for child in rightChildren {
                subChildrenHeight += child.nodeBoxRect.height
            }
            let gap = (rightChildrenSize.height - subChildrenHeight) / CGFloat(rightChildren.count + 1)
            for child in rightChildren {
                let childLeft = left + themHorizontalSpace + root.nodeBoxRect.width
                var newNode = self.innerElementPosition(top: rightTop + gap, left: childLeft, node: child)
                if newNode.children.count > 0 {
                    let newNodeChildren = self.recursionRight(childrenNode: newNode.children, parentNode: newNode)
                    newNode.children = newNodeChildren
                }
                newChildrenNode.append(newNode)
                // 添加连接线
                let startLine = CGPoint(x: left + root.nodeBoxRect.width, y: top + (root.nodeBoxRect.height / 2)) // 开始节点在root上 右边中间
                let endLine = CGPoint(x: newNode.nodeBoxRect.origin.x, y: newNode.nodeBoxRect.origin.y + (newNode.nodeBoxRect.height / 2))
                lines.append(MindNodeLine(start: startLine, end: endLine))
                // 累加
                rightTop += child.nodeBoxRect.height + themVerticalSpace
            }
        }
        // 左边区域
        if leftChildren.count > 0 {
            var leftTop = (canvasSize.height - leftChildrenSize.height) / 2
            var subChildrenHeight:CGFloat = 0.0
            for child in leftChildren {
                subChildrenHeight += child.nodeBoxRect.height
            }
            let gap = (leftChildrenSize.height - subChildrenHeight) / CGFloat(leftChildren.count + 1)
            for child in leftChildren {
                let childLeft = left - themHorizontalSpace - child.nodeBoxRect.width
                var newNode = self.innerElementPosition(top: leftTop + gap, left: childLeft, node: child)
                if newNode.children.count > 0 {
                    let newNodeChildren = self.recursionLeft(childrenNode: newNode.children, parentNode: newNode)
                    newNode.children = newNodeChildren
                }
                newChildrenNode.append(newNode)
                // 添加连接线
                let startLine = CGPoint(x: left, y: top + (root.nodeBoxRect.height / 2)) // 开始节点在root上 左边中间
                let endLine = CGPoint(x: newNode.nodeBoxRect.origin.x + newNode.nodeBoxRect.width, y: newNode.nodeBoxRect.origin.y + (newNode.nodeBoxRect.height / 2))
                lines.append(MindNodeLine(start: startLine, end: endLine))
                // 累加
                leftTop += child.nodeBoxRect.height  + themVerticalSpace
            }
        }
        
        newRoot.children = newChildrenNode
        return (newRoot, canvasSize)
    }
    
    // 递归计算右边的区域
    private func recursionRight(childrenNode: [MindNodeSize], parentNode: MindNodeSize)-> [MindNodeSize] {
        let childSize = parentNode.childrenSize
        let allSize = parentNode.allSize
        var childrenAreaTop: CGFloat = 0
        let parentCenterTop = parentNode.nodeBoxRect.origin.y + parentNode.nodeBoxRect.height / 2
        if childSize.height < allSize.height {
            childrenAreaTop = parentCenterTop - allSize.height / 2
        } else {
            childrenAreaTop = parentCenterTop - childSize.height / 2
        }
        var childrenHeightCount:CGFloat = 0
        for child in childrenNode {
            childrenHeightCount += child.nodeBoxRect.height
        }
        var firstNodeTop: CGFloat = 0
        if childSize.height < allSize.height {
            firstNodeTop = childrenAreaTop + (allSize.height - childrenHeightCount) / 2
        } else {
            firstNodeTop = childrenAreaTop
        }
        var newChildrenNode: [MindNodeSize] = []
        for child in childrenNode {
            let left = parentNode.nodeBoxRect.origin.x + parentNode.nodeBoxRect.width + themHorizontalSpace
            var newChild = self.innerElementPosition(top: firstNodeTop, left: left, node: child)
            if newChild.children.count > 0 {
                let newRChildren = self.recursionRight(childrenNode: newChild.children, parentNode: newChild)
                newChild.children = newRChildren
            }
            newChildrenNode.append(newChild)
            // 添加连接线
            let startLine = CGPoint(x: parentNode.nodeBoxRect.origin.x + parentNode.nodeBoxRect.width, y: parentNode.nodeBoxRect.origin.y + (parentNode.nodeBoxRect.height / 2))
            let endLine = CGPoint(x: newChild.nodeBoxRect.origin.x, y: newChild.nodeBoxRect.origin.y + (newChild.nodeBoxRect.height / 2))
            lines.append(MindNodeLine(start: startLine, end: endLine))
            firstNodeTop += themVerticalSpace + child.nodeBoxRect.height
        }
        return newChildrenNode
    }
    // 递归左边区域
    private func recursionLeft(childrenNode: [MindNodeSize], parentNode: MindNodeSize)-> [MindNodeSize] {
        let childSize = parentNode.childrenSize
        let allSize = parentNode.allSize
        var childrenAreaTop: CGFloat = 0
        var firstNodeTop: CGFloat = 0
        let parentCenterTop = parentNode.nodeBoxRect.origin.y + parentNode.nodeBoxRect.height / 2
        if childSize.height < allSize.height {
            childrenAreaTop = parentCenterTop - allSize.height / 2
        } else {
            childrenAreaTop = parentCenterTop - childSize.height / 2
        }
        //循环累加子节点的高度 为了计算第一个节点的位置
        var childrenHeightCount:CGFloat = 0
        for child in childrenNode {
            childrenHeightCount += child.nodeBoxRect.height
        }
        if childSize.height < allSize.height {
            firstNodeTop = childrenAreaTop  +  (allSize.height - childrenHeightCount) / 2
        } else {
            firstNodeTop = childrenAreaTop
        }
        
        var newChildrenNode: [MindNodeSize] = []
        for child in childrenNode {
            let left = parentNode.nodeBoxRect.origin.x - themHorizontalSpace - child.nodeBoxRect.width
            var newChild = self.innerElementPosition(top: firstNodeTop, left: left, node: child)
            if newChild.children.count > 0 {
                let newRChildren = self.recursionLeft(childrenNode: newChild.children, parentNode: newChild)
                newChild.children = newRChildren
            }
            newChildrenNode.append(newChild)
            // 添加连接线
            let startLine = CGPoint(x: parentNode.nodeBoxRect.origin.x, y: parentNode.nodeBoxRect.origin.y + (parentNode.nodeBoxRect.height / 2)) // 开始节点在root上 左边中间
            let endLine = CGPoint(x: newChild.nodeBoxRect.origin.x + newChild.nodeBoxRect.width, y: newChild.nodeBoxRect.origin.y + (newChild.nodeBoxRect.height / 2))
            lines.append(MindNodeLine(start: startLine, end: endLine))
            firstNodeTop += themVerticalSpace + child.nodeBoxRect.height
        }
        return newChildrenNode
    }
    
    //计算所有元素的位置信息
    private func innerElementPosition(top: CGFloat, left: CGFloat, node: MindNodeSize)-> MindNodeSize {
        var newNode = node
        newNode.nodeBoxRect = CGRect(x: left, y: top, width: node.nodeBoxRect.width, height: node.nodeBoxRect.height)
        var rowTop = top + 10  // 内边距10
        // 第一行 图片位置
        if node.imageRect != nil {
            let imageLeft = left + (node.nodeBoxRect.width - (node.imageRect?.width ?? 0)) / 2 // 图片居中
            let imageTop = rowTop
            newNode.imageRect = CGRect(x: imageLeft, y: imageTop, width: (node.imageRect?.width ?? 0), height: (node.imageRect?.height ?? 0))
            rowTop +=  (node.imageRect?.height ?? 0) + 10
        }
        // 第二行 从左往右排
        var rowLeft = left + 10
        var hasRowSecond = false
        // 优先级
        if node.priorityRect != nil {
            let priorityLeft = rowLeft
            let priorityTop = rowTop
            newNode.priorityRect = CGRect(x: priorityLeft, y: priorityTop, width: (node.priorityRect?.width ?? 0), height: (node.priorityRect?.height ?? 0))
            rowLeft += 10 + (node.priorityRect?.width ?? 0)
            hasRowSecond = true
        }
        // 进度
        if node.progressRect != nil {
            let progressLeft = rowLeft
            let progressTop = rowTop
            newNode.progressRect = CGRect(x: progressLeft, y: progressTop, width: (node.progressRect?.width ?? 0), height: (node.progressRect?.height ?? 0))
            rowLeft += 10 + (node.progressRect?.width ?? 0)
            hasRowSecond = true
        }
        // 进度
        if node.hyperlinkRect != nil {
            let hyperlinkLeft = rowLeft
            let hyperlinkTop = rowTop
            newNode.hyperlinkRect = CGRect(x: hyperlinkLeft, y: hyperlinkTop, width: (node.hyperlinkRect?.width ?? 0), height: (node.hyperlinkRect?.height ?? 0))
            rowLeft += 10 + (node.hyperlinkRect?.width ?? 0)
            hasRowSecond = true
        }
        if  hasRowSecond {
            rowTop += 10 + 20 // 加间隔 和 图表的高度
        }
        // 文字位置
        if node.textRect != nil {
            let textLeft = left + (node.nodeBoxRect.width - (node.textRect?.width ?? 0)) / 2 // 文字居中
            let textTop = rowTop
            newNode.textRect = CGRect(x: textLeft, y: textTop, width: (node.textRect?.width ?? 0), height: (node.textRect?.height ?? 0))
        }
       
        
        return newNode
    }
     
    
    // 线条宽度
    private let themeLineWidth: CGFloat = 2
    private let themVerticalSpace: CGFloat = 44
    private let themHorizontalSpace: CGFloat = 66

    // 计算画布大小 ， 就是计算所有元素占据的空间大小
    // @return canvas大小 left区域大小， right区域大小， left子元素List， right子元素List
    private func calcCanvasSize(root: MindNodeSize) -> (CGSize, CGSize, CGSize, [MindNodeSize], [MindNodeSize]) {
        var width = root.nodeBoxRect.width
        var height = root.nodeBoxRect.height
        if root.children.count == 0 {
            // 检查屏幕大小和内容大小 使用大的那个
            width =  width * 1.5
            height = height * 1.5
            if width < SCREEN_WIDTH {
                width = SCREEN_WIDTH
            }
            if height < SCREEN_HEIGHT {
                height = SCREEN_HEIGHT
            }
            return (CGSize(width: width, height: height), CGSize.zero, CGSize.zero, [], [])
        }
        let len = root.children.count
        var rightLen = 0
        if (len > 2) {
          if (len % 2 == 0) {
            rightLen = len / 2
          } else {
            rightLen = (len / 2) + 1
          }
        }else {
          rightLen = 1
        }
        let rightList = root.children[0 ..< rightLen]
        let leftList = len-rightLen>0 ? root.children[rightLen ..< len] : []
        // 右边子节点
        var rightWidth = 0.0
        var rightHeight = 0.0
        var newRightList:[MindNodeSize] = []
        if(rightList.count > 0) {
            for rightNode in rightList  {
                let child = self.calcChildSize(node: rightNode, verticalSpace: themVerticalSpace, horizontalSpace: themHorizontalSpace)
                
                newRightList.append(child)
                rightWidth =  rightWidth > child.allSize.width ? rightWidth : child.allSize.width
                rightHeight += child.allSize.height + themHorizontalSpace
              }
          rightHeight -= themHorizontalSpace
        }
        let rightChildrenSize = CGSize(width: rightWidth, height: rightHeight) // 右边区域大小
        
        // 左边子节点
        var leftWidth = 0.0
        var leftHeight = 0.0
        var newLeftList:[MindNodeSize] = []
        if(leftList.count > 0) {
            for leftNode in leftList  {
                let child = self.calcChildSize(node: leftNode, verticalSpace: themVerticalSpace, horizontalSpace: themHorizontalSpace)
                newLeftList.append(child)
                leftWidth = leftWidth > child.allSize.width ? leftWidth : child.allSize.width;
                leftHeight += child.allSize.height + themHorizontalSpace
          }
          leftHeight -= themHorizontalSpace
        }
        let leftChildrenSize = CGSize(width: leftWidth, height: leftHeight) // 左边区域 大小
        
        ///
        /// root节点本身的宽+2个间隔+left和right最大的宽度*2
        /// root节点本身的高 和 left、right最大的高度*2
        ///
        width += (rightWidth > leftWidth ? rightWidth : leftWidth) * 2 + (themHorizontalSpace * 2)
        height += (rightHeight > leftHeight ? rightHeight : leftHeight) * 2
        
        // 先预留大小
        width = width * 1.5
        height = height * 1.5
        
        // 检查屏幕大小和内容大小 使用大的那个
        if width < SCREEN_WIDTH {
            width = SCREEN_WIDTH
        }
        if height < SCREEN_HEIGHT {
            height = SCREEN_HEIGHT
        }
        
        return (CGSize(width: width , height: height), leftChildrenSize, rightChildrenSize, newLeftList, newRightList)
    }
    
   
    // 递归计算子元素 占据空间大小
    private func calcChildSize(node: MindNodeSize, verticalSpace: CGFloat, horizontalSpace: CGFloat)-> MindNodeSize {
        var newNode = node
        var width = node.nodeBoxRect.width
        var height = node.nodeBoxRect.height
        
        var childrenWidth = 0.0
        var childrenHeight = 0.0
        var childrenSizeList:[MindNodeSize] = []
        if(node.children.count > 0) {
            for child in node.children {
                let childSizeNode = self.calcChildSize(node: child, verticalSpace: verticalSpace, horizontalSpace: horizontalSpace)
                childrenSizeList.append(childSizeNode)
                let childSize = childSizeNode.allSize
                childrenWidth = childrenWidth > childSize.width ? childrenWidth: childSize.width
                childrenHeight += childSize.height + verticalSpace
            }
            childrenHeight -= verticalSpace
        }
        newNode.children = childrenSizeList
        let newChildSize = CGSize(width: childrenWidth, height: childrenHeight)
        newNode.childrenSize = newChildSize
        width += childrenWidth + horizontalSpace
        height = height>childrenHeight ? height : childrenHeight
        newNode.allSize = CGSize(width: width, height: height)
        return newNode
    }
    
    // 递归计算所有节点的本身大小
    private func recursiveNode(node: MindNode, level: Int)-> MindNodeSize?  {
        if node.data != nil {
            var nodeSize = self.calcNodeSelfSize(node: node, level: level )
            if nodeSize != nil {
                if node.children != nil && node.children?.count ?? 0 > 0 {
                    var childrenNodeSize: [MindNodeSize] = []
                    node.children?.forEach({ nodeChild in
                        if let nodeChildSize = self.recursiveNode(node: nodeChild, level: level + 1) {
                            childrenNodeSize.append(nodeChildSize)
                        }
                    })
                    nodeSize?.children = childrenNodeSize
                }
            }
            return nodeSize
        }
        return nil
    }
    
    // 计算节点内部大小
    private func calcNodeSelfSize(node: MindNode, level: Int)-> MindNodeSize? {
        if (node.data != nil) {
            let data = node.data!
            // 第一行 图片
            var firstRowWidth = CGFloat(0)
            var firstRowHeight = CGFloat(0)
            var imageRect: CGRect?
            if data.image != nil && data.imageSize != nil {
                let imageSize = data.imageSize!
                firstRowWidth = CGFloat(imageSize.width ?? 0)
                firstRowHeight =  CGFloat(imageSize.height ?? 0)
                imageRect = CGRect(x: 0, y: 0, width: firstRowWidth, height: firstRowHeight)
            }
            // 第二行 固定图标 进度 优先级 超链接
            var secondRowWidth = CGFloat(0)
            var secondRowHeight = CGFloat(0)
            var priorityRect: CGRect?
            if data.priority != nil {
                secondRowWidth = 20
                secondRowHeight = 20
                priorityRect = CGRect(x: 0, y: 0, width: 20, height: 20)
            }
            var progressRect: CGRect?
            if data.progress != nil {
                if secondRowWidth > 0 {
                    secondRowWidth += 25 // 左边距5
                } else {
                    secondRowWidth = 20
                }
                secondRowHeight = 20
                progressRect = CGRect(x: 0, y: 0, width: 20, height: 20)
            }
            var hyperlinkRect: CGRect?
            if data.hyperlink != nil && data.hyperlink != "" {
                if secondRowWidth > 0 {
                    secondRowWidth += 25 // 左边距5
                } else {
                    secondRowWidth = 20
                }
                secondRowHeight = 20
                hyperlinkRect =  CGRect(x: 0, y: 0, width: 20, height: 20)
            }
            
            // 第三行 文字
            var thirdRowWidth = CGFloat(0)
            var thirdRowHeight = CGFloat(0)
            var textRect1: CGRect?
            if data.text != nil && data.text != "" {
                let textRect = self.calcTextRect(text: data.text!)
                thirdRowWidth = textRect.width
                thirdRowHeight = textRect.height
                textRect1 = textRect
            }
            
            // 计算
            var boxWidth = CGFloat(0)
            var boxHeight = CGFloat(0)
            // 图片
            if firstRowWidth > 0 {
                boxWidth = firstRowWidth
                boxHeight = firstRowHeight
            }
            // 图标
            if secondRowWidth > 0 && secondRowWidth > boxWidth {
                boxWidth = secondRowWidth
            }
            if secondRowHeight > 0 {
                if boxHeight > 0 {
                    boxHeight += secondRowHeight + 10 // 10上边距
                } else {
                    boxHeight = secondRowHeight
                }
            }
            // 文字
            if thirdRowWidth > 0 && thirdRowWidth > boxWidth {
                boxWidth = thirdRowWidth
            }
            if thirdRowHeight > 0  {
                if boxHeight > 0 {
                    boxHeight += thirdRowHeight + 10 // 10上边距
                } else {
                    boxHeight = thirdRowHeight
                }
            }
            
            if boxWidth > 0 && boxHeight > 0 {
                boxWidth += 20 // 左右内边距 各10
                boxHeight += 20 // 上下内边距 各10
                var nodeSize = MindNodeSize(nodeBoxRect: CGRect(x: 0, y: 0, width: boxWidth, height: boxHeight))
                nodeSize.level = level
                //内部元素
                nodeSize.imageRect = imageRect
                nodeSize.priorityRect = priorityRect
                nodeSize.progressRect = progressRect
                nodeSize.hyperlinkRect = hyperlinkRect
                nodeSize.textRect = textRect1
                nodeSize.data = data
                return nodeSize
            }
        }
        return nil
    }
    
    // 计算文字高度 宽度 最宽100
    private func calcTextRect(text: String)-> CGRect {
        textStyle.alignment = NSTextAlignment.center
        textStyle.lineBreakMode = .byWordWrapping
        let textAtt:  [NSAttributedString.Key : Any] = [NSAttributedString.Key.font: font!, NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: textStyle]
        let textRect = text.boundingRect(with: CGSize(width: 100, height: 0), options: .usesLineFragmentOrigin, attributes: textAtt, context: nil)
        return textRect
    }
    
    
    
    private var image: UIImage?
    
    // 下载图片 并刷新重绘
    private func downloadImage(imageUrl: String) {
        if let _ =  imageMap[imageUrl] {
            return
        } else {
            DDLogDebug("开始下载图片，url： \(imageUrl)")
            let url = URL(string: imageUrl)!
            getImageData(url: url) { data, response, error in
                guard let data = data, error == nil else {
                   DDLogError("下载图片错误，\(String(describing: error?.localizedDescription))")
                   return
                }
                DDLogDebug(response?.suggestedFilename ?? url.lastPathComponent)
                DDLogDebug("Download Finished")
                   // always update the UI from the main thread
                DispatchQueue.main.async() { [weak self] in
                    self?.imageMap[imageUrl] = UIImage(data: data)
                    self?.setNeedsDisplay()
                }
               }
        }
    }
    // 下载
    private func getImageData(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
}
