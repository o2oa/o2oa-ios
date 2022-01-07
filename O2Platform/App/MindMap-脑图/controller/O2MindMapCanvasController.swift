//
//  O2MindMapCanvasController.swift
//  O2Platform
//
//  Created by FancyLou on 2021/12/17.
//  Copyright © 2021 zoneland. All rights reserved.
//

import UIKit
import CocoaLumberjack
import Promises

class O2MindMapCanvasController: UIViewController {

    private lazy var viewModel: O2MindMapViewModel = {
        return O2MindMapViewModel()
    }()
    
    var id: String? // 脑图id
    
    private var mindMapItem: MindMapItem? // 脑图对象
    private var root: MindRootNode? // 脑图具体内容的对象
    
    private var canvas: O2MindMapCanvasView? // 脑图画布
    
    // 底部工具栏
    private var bottomBar: O2MindMapCanvasBottomBar?
    // 点击画布
    private var selectedNode: MindNodeData? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "脑图"
        self.view.backgroundColor = O2MindMapCanvasView.canvasBgColor // 背景色
        self.loadMindMap()
    }
    
    private func addSavebtn() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "保存", style: .plain, target: self, action: #selector(saveMindMap))
    }
    
    
    // MARK: - 事件
    
    // 双指缩放
    @objc private func scale(sender: UIPinchGestureRecognizer?) {
        if let scale = sender?.scale {
            if self.canvas != nil {
                self.canvas!.transform = self.canvas!.transform.scaledBy(x: scale, y: scale)
            }
            // 缩放完成后重置
            sender?.scale = 1
        }
    }
    // 移动画布
    @objc private func move(sender: UIPanGestureRecognizer? ) {
        if let transation = sender?.translation(in: self.view), let oldCenter = sender?.view?.center {
            let newCenter = CGPoint(x: oldCenter.x + transation.x, y: oldCenter.y + transation.y)
            let canvansH = self.canvas?.frame.height ?? 0
            var maxY:CGFloat = 0
            if canvansH >= self.view.frame.height {
                maxY = (canvansH - self.view.frame.height) / 2
            }
            // let maxY = (canvansH / 2) +  self.view.frame.height
            var newCenterY = CGFloat.minimum(newCenter.y, maxY + (self.view.frame.height / 2))
            newCenterY = CGFloat.maximum((self.view.frame.height / 2) - maxY, newCenterY)
            let canvansW = self.canvas?.frame.width ?? 0
            var maxX:CGFloat = 0
            if canvansW > self.view.frame.width {
                maxX = (canvansW - self.view.frame.width) / 2
            }
            // let maxX = (canvansW / 2) +  self.view.frame.width
            var newCenterX = CGFloat.minimum(newCenter.x, maxX + (self.view.frame.width / 2))
            newCenterX = CGFloat.maximum((self.view.frame.width / 2) - maxX , newCenterX)
            sender?.view?.center = CGPoint(x: newCenterX, y: newCenterY)
            // 移动完成后归零
            sender?.setTranslation(CGPoint.zero, in: self.view)
        }
    }
    
    @objc private func clickCanvas(sender: UITapGestureRecognizer?) {
        if let point = sender?.location(in: sender?.view) {
            self.selectedNode = self.canvas?.clickCanvasWithPoint(point: point)
            // 当前脑图是否可编辑
            if self.mindMapItem?.editable == true {
                if self.selectedNode != nil {
                    self.bottomBar?.show(isRoot: self.selectedNode?.isRoot() ?? false)
                } else {
                    self.bottomBar?.hide()
                }
            } else {
                DDLogError("当前用户不可编辑")
            }
        }
    }
    
    
    // MARK: - 画布相关处理
    
    ///
    /// 绘画脑图
    private func painMindMap() {
        DDLogDebug("开始绘画脑图。。。\(SCREEN_WIDTH) \(SCREEN_HEIGHT)")
        if let root = root {
            self.canvas = O2MindMapCanvasView() // 这里直接new ？？
            if let paint = self.canvas!.resolveData(json: root) {
                let size = paint.1
                DDLogDebug("canvas size \(size)")
                var x: CGFloat = 0
                var y: CGFloat = 0
                if size.width > SCREEN_WIDTH {
                    x = 1 - ((size.width - SCREEN_WIDTH ) / 2)
                }
                if size.height > SCREEN_HEIGHT {
                    y = 1 - ((size.height - SCREEN_HEIGHT) / 2)
                }
                self.view.addSubview(canvas!)
                canvas!.backgroundColor = O2MindMapCanvasView.canvasBgColor // 背景色
                canvas!.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
                canvas!.repaintContent(node: paint.0)
                let pinch = UIPinchGestureRecognizer(target: self, action: #selector(scale))
                canvas!.addGestureRecognizer(pinch)
                let move = UIPanGestureRecognizer(target: self, action: #selector(move))
                canvas!.addGestureRecognizer(move)
                canvas!.addTapGesture(target: self, action: #selector(clickCanvas))
            }
            // 添加底部工具栏
            self.bottomBar = O2MindMapCanvasBottomBar.newBar(y: self.view.frame.height)
            self.view.addSubview(self.bottomBar!)
            self.bottomBar?.delegate = self
        } else {
            DDLogError("脑图内容为空！！！！")
        }
    }
    // 数据变化 重新绘制
    private func notifyDataChanged() {
        if let root = root {
            // 重新计算大小
            if let paint = self.canvas!.resolveData(json: root) {
                let size = paint.1
                var x: CGFloat = 0
                var y: CGFloat = 0
                if size.width > SCREEN_WIDTH {
                    x = 1 - ((size.width - SCREEN_WIDTH ) / 2)
                }
                if size.height > SCREEN_HEIGHT {
                    y = 1 - ((size.height - SCREEN_HEIGHT) / 2)
                }
                // 修改画布大小
                canvas!.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
                // 重新绘画脑图
                canvas!.repaintContent(node: paint.0)
                if self.selectedNode != nil {
                    self.moveSelectedNode2Center()
                }
            }
        }
    }
    
    // 移动画布 让选中的节点移动到中心
    private func moveSelectedNode2Center() {
        if self.selectedNode == nil {
            DDLogError("没有选中的节点，无法移动")
            return
        }
        if let selectP = self.canvas?.getSelectNodePosition(), let selectNodeP = selectP.0, let rootNodeP = selectP.1 {
            let selectPoint = CGPoint(x: (selectNodeP.nodeBoxRect.origin.x + selectNodeP.nodeBoxRect.width / 2), y: selectNodeP.nodeBoxRect.origin.y + selectNodeP.nodeBoxRect.height / 2)
            let selectViewPoint = self.canvas!.convert(selectPoint, to: self.view)
            let rootPoint = CGPoint(x: (rootNodeP.nodeBoxRect.origin.x + rootNodeP.nodeBoxRect.width / 2), y: rootNodeP.nodeBoxRect.origin.y + rootNodeP.nodeBoxRect.height / 2)
            let rootViewPoint = self.canvas!.convert(rootPoint, to: self.view)
            var newX = (2 * rootViewPoint.x - selectViewPoint.x)
            var newY = (2 * rootViewPoint.y - selectViewPoint.y)
            DDLogInfo("新的 x ： \(newX) y: \(newY)")
            let maxY = self.view.frame.height / 2 + (self.canvas!.frame.height - self.view.frame.height) / 2
            let minY = self.view.frame.height / 2 - (self.canvas!.frame.height - self.view.frame.height) / 2
            let maxX = self.view.frame.width / 2 + (self.canvas!.frame.width - self.view.frame.width) / 2
            let minX = self.view.frame.width / 2 - (self.canvas!.frame.width - self.view.frame.width) / 2
            if newX > maxX {
                newX = maxX
            }
            if newX < minX {
                newX = minX
            }
            if newY > maxY {
                newY = maxY
            }
            if newY < minY {
                newY = minY
            }
            let newCenter = CGPoint(x: newX, y: newY)
            DDLogInfo("新的 root节点的中心点 外部位置 ： \(newCenter)")
            self.canvas?.center = newCenter
        } else {
            DDLogError("没有选中的节点或root节点")
        }
    }
    
    
    // MARK: - 后端请求相关
    /// 请求脑图数据
    private func loadMindMap() {
        if let viewId = id, !viewId.isBlank {
            self.showLoading()
            self.viewModel.loadMindMapView(id: viewId).then { (item, node) in
                self.hideLoading()
                self.mindMapItem = item
                self.title = item.name // 修改标题
                self.root = node
                self.painMindMap()
                if self.mindMapItem?.editable == true {
                    self.addSavebtn()
                }
            }.catch { err in
                self.showError(title: "请求脑图数据错误！")
            }
        } else {
            DDLogError("错误，没有脑图id，无法获取数据！！！！")
        }
    }
    
    
    //  保存脑图 结束后更新预览图
    @objc private func saveMindMap() {
        if let root = self.root,let item = self.mindMapItem, let id = item.id {
            // 需要先保存缩略图 然后把id放入MindMapItem中 然后保存对象
            self.showLoading()
            if let image = self.canvas?.saveAsImage() {
                self.viewModel.saveMindMapThumb(image: image, id: id).then { imgId -> Promise<String> in
                    DDLogInfo("保存缩略图成功！\(imgId)")
                    let content = root.toJSONString() ?? ""
                    item.content = content
                    item.fileVersion = item.fileVersion ?? 0 + 1
                    item.icon = imgId
                    return self.viewModel.saveMindMap(mind: item)
                }.then { _ in
                    self.showSuccess(title: "保存成功！")
                    self.mindMapItem = item
                }.catch { err in
                    DDLogError(err.localizedDescription)
                    self.showError(title: "保存失败！")
                }
            }
        }
    }
    
    
  
    // MARK: - 节点工具栏操作
    
    // 创建子节点
    private func createSubNode() {
        DDLogDebug("创建子节点")
        if self.selectedNode == nil {
            DDLogError("请先选择节点！！")
            return
        }
        self.showPromptAlert(title: "创建子节点", message: "请输入节点内容", inputText: "") { action, result in
            if result == "" || result.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                self.showError(title: "请输入节点内容！")
                return
            }
            if let node = self.root?.root {
                let newNode = self.createSubNodeWithTextRecursion(node: node, text: result)
                self.root?.root = newNode
                self.notifyDataChanged()
            } else {
                DDLogError("脑图数据对象不存在，无法创建。。。")
            }
        }
    }
    
    // 创建新的子节点到对象中
    private func createSubNodeWithTextRecursion(node: MindNode, text:String)-> MindNode {
        if node.data?.id != nil && node.data?.id == self.selectedNode?.id {
            let newNode = MindNode()
            let newData = MindNodeData()
            newData.text = text
            let time = Date().milliStamp
            newData.id = "mind_\(time)"
            newNode.data = newData
            newNode.children = []
            node.children?.append(newNode)
            self.selectedNode = newData
            self.canvas?.reSelected(newSelected: newData)
        } else {
            if let nChild = node.children {
                var children: [MindNode] = []
                for item in nChild {
                    let newChild = self.createSubNodeWithTextRecursion(node: item, text: text)
                    children.append(newChild)
                }
                node.children = children
            }
        }
        return node
    }
    
    // 创建同级节点
    private func createSameLevelNode() {
        DDLogDebug("创建同级节点")
        if self.selectedNode == nil {
            DDLogError("请先选择节点！！")
            return
        }
        self.showPromptAlert(title: "创建同级节点", message: "请输入节点内容", inputText: "") { action, result in
            if result == "" || result.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                self.showError(title: "请输入节点内容！")
                return
            }
            if let node = self.root?.root {
                let newNode = self.createSameLevelNodeWithTextRecursion(node: node, text: result)
                self.root?.root = newNode
                self.notifyDataChanged()
            } else {
                DDLogError("脑图数据对象不存在，无法创建。。。")
            }
        }
    }
    
    // 创建新的同级节点到对象中
    private func createSameLevelNodeWithTextRecursion(node: MindNode, text:String)-> MindNode {
        if let nChild = node.children {
            var children: [MindNode] = []
            for item in nChild {
                if item.data?.id != nil && item.data?.id == self.selectedNode?.id {
                    let newNode = MindNode()
                    let newData = MindNodeData()
                    newData.text = text
                    let time = Date().milliStamp
                    newData.id = "mind_\(time)"
                    newNode.data = newData
                    newNode.children = []
                    children.append(newNode)
                    self.selectedNode = newData
                    self.canvas?.reSelected(newSelected: newData)
                    // 忘了添加兄弟节点
                    children.append(item)
                } else {
                    let newChild = self.createSubNodeWithTextRecursion(node: item, text: text)
                    children.append(newChild)
                }
            }
            node.children = children
        }
        return node
    }
    
    // 修改节点文字
    private func updateNodeText() {
        DDLogDebug("修改节点文字内容")
        if self.selectedNode == nil {
            DDLogError("请先选择节点！！")
            return
        }
        self.showPromptAlert(title: "修改节点内容", message: "请输入节点内容", inputText: self.selectedNode?.text ?? "") { action, result in
            if result == "" || result.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                self.showError(title: "请输入节点内容！")
                return
            }
            if let node = self.root?.root {
                let newNode = self.updateNodeTextRecursion(node: node, text: result)
                self.root?.root = newNode
                self.notifyDataChanged()
            } else {
                DDLogError("脑图数据对象不存在，无法创建。。。")
            }
        }
    }
    private func updateNodeTextRecursion(node: MindNode, text:String)-> MindNode {
        if node.data?.id != nil && node.data?.id == self.selectedNode?.id {
            let newData = node.data!
            newData.text = text
            node.data = newData
            self.selectedNode = newData
            self.canvas?.reSelected(newSelected: newData)
        } else {
            if let nChild = node.children {
                var children: [MindNode] = []
                for item in nChild {
                    let newChild = self.updateNodeTextRecursion(node: item, text: text)
                    children.append(newChild)
                }
                node.children = children
            }
        }
        return node
    }
    // 删除节点
    private func deleteNode() {
        DDLogDebug("删除选中的节点")
        if self.selectedNode == nil {
            DDLogError("请先选择节点！！")
            return
        }
        self.showDefaultConfirm(title: "提示", message: "确定要删除【\(self.selectedNode?.text ?? "")】这个节点吗") { action in
            if let node = self.root?.root {
                let newNode = self.deleteSelectNodeRecursion(node: node)
                self.root?.root = newNode
                self.notifyDataChanged()
            } else {
                DDLogError("脑图数据对象不存在，无法创建。。。")
            }
        }
    }
    private func deleteSelectNodeRecursion(node: MindNode)-> MindNode {
        if let nChild = node.children {
            var children: [MindNode] = []
            for item in nChild {
                if item.data?.id != nil && item.data?.id == self.selectedNode?.id {
                    // 找到后清除选中的节点
                    self.selectedNode = nil
                    self.canvas?.reSelected(newSelected: nil)
                } else {
                    let newChild = self.deleteSelectNodeRecursion(node: item)
                    children.append(newChild)
                }
            }
            node.children = children
        }
        return node
    }
    

    private func addLink() {
        DDLogDebug("删除选中的节点")
        if self.selectedNode == nil {
            DDLogError("请先选择节点！！")
            return
        }
        let dialog = O2MindMapAddLinkDialog.mindMapNodeLinkDialog(link: self.selectedNode?.hyperlink, linkTitle: self.selectedNode?.hyperlinkTitle, delegate: self)
        dialog.show()
    }
    private func updateNodeLink(link:String, linkTitle: String) {
        if let node = self.root?.root {
            let newNode = self.updateNodeLinkRecursion(node: node, link: link, linkTitle: linkTitle)
            self.root?.root = newNode
            self.notifyDataChanged()
        } else {
            DDLogError("脑图数据对象不存在，无法创建。。。")
        }
    }
    private func updateNodeLinkRecursion(node: MindNode, link:String, linkTitle: String)-> MindNode {
        if node.data?.id != nil && node.data?.id == self.selectedNode?.id {
            let newData = node.data!
            newData.hyperlink = link
            newData.hyperlinkTitle = linkTitle
            node.data = newData
            self.selectedNode = newData
            self.canvas?.reSelected(newSelected: newData)
        } else {
            if let nChild = node.children {
                var children: [MindNode] = []
                for item in nChild {
                    let newChild = self.updateNodeLinkRecursion(node: item, link: link, linkTitle: linkTitle)
                    children.append(newChild)
                }
                node.children = children
            }
        }
        return node
    }
    
}

// MARK: - 点击底部工具栏按钮
extension O2MindMapCanvasController: O2MindMapCanvasBottomBtnDelegate {
    
    func clickBtn(type: O2MindMapCanvasBottomBtnType) {
        DDLogDebug("type: \(type.rawValue)")
        switch type {
        case .createSubNode:
            self.createSubNode()
            break
        case .createSameLevelNode:
            self.createSameLevelNode()
            break
        case .editNode:
            self.updateNodeText()
            break
        case .deleteNode:
            self.deleteNode()
            break
        case .addImg:
            break
        case .addLink:
            self.addLink()
            break
        case .addIcon:
            break
        }
    }
}

// MARK: - 添加超链接的delegate
extension O2MindMapCanvasController: O2MindMapAddLinkDialogDelegate {
    func deleteLink() {
        DDLogInfo("删除超链接")
        self.updateNodeLink(link: "", linkTitle: "")
    }
    
    func saveLink(link: String, linkTitle: String) {
        DDLogInfo("保存超链接 link: \(link) linkTitle: \(linkTitle)")
        self.updateNodeLink(link: link, linkTitle: linkTitle)
    }
    
}
