//
//  ThirdEventScene.swift
//  TablePlanner
//
//  Created by ChristianBieniak on 1/5/17.
//  Copyright © 2017 Bieniapps. All rights reserved.
//

import UIKit
import SpriteKit

class ThirdEventScene: SKScene {
    
    var currentlyDraggedNode: SKNode?
    
    var currentScale: CGFloat = 1.0
    var currentRotation: CGFloat = 1.0
    
    var floorNode: SKShapeNode!
    var floorPlanNodes: [SKShapeNode] = []
    
    func addFloor(_ size: CGSize) {
        self.floorNode = SKShapeNode(rectOf: CGSize(width: 500, height: 500))
        self.floorNode.fillColor = .white
        self.floorNode.position = CGPoint(x: 250, y: 250)
        self.addChild(self.floorNode)
        
    
        //self.physicsWorld.contactDelegate = self
        
        //        if let grid = Grid(blockSize: 10.0, rows:50, cols:50) {
        //            self.floorNode.addChild(grid)
        //        }
    }
    
    func addUI() {
        
        let addTableNode = TappableNode(circleOfRadius: 25)
        addTableNode.fillColor = .yellow
        addTableNode.position = CGPoint(x: 60, y: 60)
        addTableNode.userData = ["type" : NodeType.ui.rawValue ]
        addTableNode.isUserInteractionEnabled = true
        addTableNode.wasTouched = { [unowned self] in
            //            guard self.floorPlanNodes.count > 0 else {
            //                return
            //            }
            //            let item = self.floorPlanNodes.removeLast()
            //            item.removeFromParent()
            
            self.calculatePaths()
        }
        self.addChild(addTableNode)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if touches.count == 1 {
            guard let firstTouch = touches.first else { return }
            
            guard self.currentlyDraggedNode == nil else { return }
            
            let path = CGMutablePath()
            path.move(to: firstTouch.location(in: self.floorNode))
            let currNode = SKShapeNode(path: path)
            currNode.strokeColor = .blue
            currNode.lineWidth = 4.0
            currNode.fillColor = .clear
            
            self.floorNode.addChild(currNode)
            
            lastLocation = firstTouch.location(in: self.floorNode)
            
            if currNode != self, currNode != self.floorNode {
                self.currentlyDraggedNode = currNode
            }
        } else if touches.count == 2 {
            //pinch
            let touchArrays = Array(touches)
            let touch1 = touchArrays[0]
            let touch2 = touchArrays[1]
            
            
            
            //build a square
            let touch1x = touch1.location(in: self.floorNode).x
            let touch1y = touch1.location(in: self.floorNode).y
            let touch2x = touch2.location(in: self.floorNode).x
            let touch2y = touch2.location(in: self.floorNode).y
            
            
            
            
            let path = CGMutablePath()
            path.move(to: CGPoint(x: touch1x, y: touch1y))
            path.addLine(to: CGPoint(x: touch1x, y: touch2y))
            path.addLine(to: CGPoint(x: touch2x, y: touch2y))
            path.addLine(to: CGPoint(x: touch2x, y: touch1y))
            path.addLine(to: CGPoint(x: touch1x, y: touch1y))
            
            let currNode = SKShapeNode(path: path)
            currNode.strokeColor = .red
            currNode.lineWidth = 4.0
            currNode.fillColor = .clear
            
            if currNode != self, currNode != self.floorNode {
                self.currentlyDraggedNode = currNode
                self.floorNode.addChild(currNode)
            }
            
        }
        
    }
    var lastLocation: CGPoint?
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        if touches.count == 1 {
            if let firstTouch = touches.first,
                let currentNode = self.currentlyDraggedNode as? SKShapeNode {
                let path = currentNode.path!.mutableCopy()
                var location = firstTouch.location(in: self.floorNode)
                if let safeLastLoc = lastLocation {
                    if  -30...30 ~= (safeLastLoc.x - location.x) {
                        location.x = safeLastLoc.x
                    }
                    
                    if  -30...30 ~= (safeLastLoc.y - location.y) {
                        location.y = safeLastLoc.y
                    }
                    
                }
                
                
                location.x = CGFloat(Int(location.x / 10) * 10)
                location.y = CGFloat(Int(location.y / 10) * 10)
                
                
                path!.addLine(to: location)
                currentNode.path = path
            }
            
            
            //pinch to make square
        } else if touches.count == 2 {
            //pinch
            let touchArrays = Array(touches)
            let touch1 = touchArrays[0]
            let touch2 = touchArrays[1]
            
            //build a square
            let touch1x = touch1.location(in: self.floorNode).x
            let touch1y = touch1.location(in: self.floorNode).y
            let touch2x = touch2.location(in: self.floorNode).x
            let touch2y = touch2.location(in: self.floorNode).y
            
            let path = CGMutablePath()
            path.move(to: CGPoint(x: touch1x, y: touch1y))
            path.addLine(to: CGPoint(x: touch1x, y: touch2y))
            path.addLine(to: CGPoint(x: touch2x, y: touch2y))
            path.addLine(to: CGPoint(x: touch2x, y: touch1y))
            path.addLine(to: CGPoint(x: touch1x, y: touch1y))
            
            if let currentNode = self.currentlyDraggedNode as? SKShapeNode {
                currentNode.path = path
            }
            
        }
        
        
        
    }
    
    func calculatePaths() {
        let allPaths = self.floorPlanNodes.flatMap({ $0.path })
        
        let path = allPaths.reduce(CGMutablePath()) { (res, path) -> CGPath in
            let copy = res.mutableCopy()
            copy!.addPath(path)
            return copy!
        }
        
        let region = SKRegion(path: path)
        let currNode = SKShapeNode(path: region.path!)
        currNode.strokeColor = .orange
        currNode.lineWidth = 4.0
        currNode.fillColor = .clear
        
        self.floorNode.addChild(currNode)
        
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if let node = self.currentlyDraggedNode as? SKShapeNode {
            self.floorPlanNodes.append(node)
            
            if touches.count == 1 {
                let path = node.path!.mutableCopy()
                path!.closeSubpath()
                node.path = path
                node.fillColor = .blue
            }
            
            
            self.currentlyDraggedNode = nil
        }
        
    }
    
    override func pinchByScale(_ scale: CGFloat) {
        if scale > currentScale {
            currentScale = scale
            if(self.size.height < 800) {
                let zoomIn = SKAction.scale(by: 1.05, duration:0)
                self.floorNode.run(zoomIn)
            }
        }
        if scale < currentScale {
            currentScale = scale
            if(self.size.height > 200) {
                let zoomOut = SKAction.scale(by: 0.95, duration:0)
                self.floorNode.run(zoomOut)
            }
        }
    }
    
    
    override func rotateWith(_ rotation: CGFloat) {
        
        //TODO ROTATE
        //        if rotation > currentRotation {
        //            currentRotation = rotation
        //
        //           self.floorNode.run(SKAction.rotate(byAngle: 0.0001, duration: 0))
        //
        //        }
        //        if rotation < currentRotation {
        //            currentRotation = rotation
        //            self.floorNode.run(SKAction.rotate(byAngle: -0.0001, duration: 0))
        //        }
        
        //
    }
    
}

extension ThirdEventScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        
        var patronNode: SKNode!
        var tableNode: LabeledShapeNode!
        
        if contact.bodyA.categoryBitMask == PhysicsCategory.Patron &&
            contact.bodyB.categoryBitMask == PhysicsCategory.Table {
            patronNode = contact.bodyA.node
            tableNode = contact.bodyB.node as! LabeledShapeNode
            
        } else if contact.bodyB.categoryBitMask == PhysicsCategory.Patron &&
            contact.bodyA.categoryBitMask == PhysicsCategory.Table {
            patronNode = contact.bodyB.node
            tableNode = contact.bodyA.node as! LabeledShapeNode
            
        } else {
            return
        }
        if tableNode.count < 8 {
            patronNode.removeFromParent()
            tableNode.count = tableNode.count + 1
        }
        
    }
}
