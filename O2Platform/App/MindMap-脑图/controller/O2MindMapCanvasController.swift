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
            sender?.scale = 1
        }
    }
    // 移动画布
    @objc private func move(sender: UIPanGestureRecognizer? ) {
        if let transation = sender?.translation(in: self.view), let oldCenter = sender?.view?.center {
            let newCenter = CGPoint(x: oldCenter.x + transation.x, y: oldCenter.y + transation.y)
            var newCenterY = CGFloat.minimum(newCenter.y, self.view.frame.height)
            newCenterY = CGFloat.maximum(0, newCenterY)
            var newCenterX = CGFloat.minimum(newCenter.x, self.view.frame.width)
            newCenterX = CGFloat.maximum(0, newCenterX)
            sender?.view?.center = CGPoint(x: newCenterX, y: newCenterY)
            sender?.setTranslation(CGPoint.zero, in: self.view)
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
            }
        } else {
            DDLogError("脑图内容为空！！！！")
        }
    }
    
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
 

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
