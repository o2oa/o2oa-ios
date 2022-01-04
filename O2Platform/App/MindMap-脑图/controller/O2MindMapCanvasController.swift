//
//  O2MindMapCanvasController.swift
//  O2Platform
//
//  Created by FancyLou on 2021/12/17.
//  Copyright © 2021 zoneland. All rights reserved.
//

import UIKit
import CocoaLumberjack

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "脑图"
        self.view.backgroundColor = O2MindMapCanvasView.canvasBgColor // 背景色
        self.loadMindMap()
        
    }
    
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
    // 点击画布
    private var selectedNode: MindNodeSize? = nil
    @objc private func clickCanvas(sender: UITapGestureRecognizer?) {
        if let point = sender?.location(in: sender?.view) {
            self.selectedNode = self.canvas?.clickCanvasWithPoint(point: point)
            if self.selectedNode != nil {
                self.bottomBar?.show(isRoot: self.selectedNode?.data?.isRoot() ?? false)
            } else {
                self.bottomBar?.hide()
            }
        }
    }
    
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
                DDLogDebug("canvas size \(size)")
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
            }
        }
        
    }
    
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
            }.catch { err in
                self.showError(title: "请求脑图数据错误！")
            }
        } else {
            DDLogError("错误，没有脑图id，无法获取数据！！！！")
        }
    }
  
    // MARK: - 节点工具栏操作
    
    // 创建子节点
    private func createSubNode() {
        DDLogDebug("创建子节点")
        if self.selectedNode == nil || self.selectedNode?.data == nil {
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
        if node.data?.id != nil && node.data?.id == self.selectedNode?.data?.id {
            let newNode = MindNode()
            let newData = MindNodeData()
            newData.text = text
            let time = Date().milliStamp
            newData.id = "mind_\(time)"
            newNode.data = newData
            newNode.children = []
            node.children?.append(newNode)
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
    

}


extension O2MindMapCanvasController: O2MindMapCanvasBottomBtnDelegate {
    
    func clickBtn(type: O2MindMapCanvasBottomBtnType) {
        DDLogDebug("type: \(type.rawValue)")
        switch type {
        case .createSubNode:
            self.createSubNode()
            break
        case .createSameLevelNode:
            break
        case .editNode:
            break
        case .deleteNode:
            break
        case .addImg:
            break
        case .addLink:
            break
        case .addIcon:
            break
        }
    }
}
