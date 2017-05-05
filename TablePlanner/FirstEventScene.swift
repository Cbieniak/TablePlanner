//
//  FirstEventScene.swift
//  TablePlanner
//
//  Created by ChristianBieniak on 17/4/17.
//  Copyright © 2017 Bieniapps. All rights reserved.
//

import UIKit
import SpriteKit

class FirstEventScene: SKScene {
    
    var currentlyDraggedNode: SKNode?
    
    var currentScale: CGFloat = 1.0
    
    var floorNode: SKShapeNode!
    
    func addFloor(_ size: CGSize) {
        self.floorNode = SKShapeNode(rectOf: CGSize(width: 500, height: 500))
        self.floorNode.fillColor = .white
        self.floorNode.position = CGPoint(x: 250, y: 250)
        self.addChild(self.floorNode)
        self.physicsWorld.contactDelegate = self
    }
    
    func createTable() -> SKShapeNode {
        
        let outerLayer = SKShapeNode(rectOf: CGSize(width: 150, height: 150))
        outerLayer.position = CGPoint(x: -100, y: 20)
        
        //table needs to contain an outer layer
        let tablePhysics = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 50))
        tablePhysics.categoryBitMask = PhysicsCategory.Table
        tablePhysics.contactTestBitMask = PhysicsCategory.Patron
        tablePhysics.collisionBitMask = PhysicsCategory.None
        tablePhysics.affectedByGravity = false
        let tableNode = LabeledShapeNode(rectOf: CGSize(width: 50, height: 50), cornerRadius: 5)
        tableNode.setupLabel()
        tableNode.fillColor = .brown
        tableNode.userData =  ["type" : NodeType.table.rawValue ]
        tableNode.physicsBody = tablePhysics
        
        outerLayer.addChild(tableNode)
        
        return outerLayer
    }
    
    
    func createPatron() -> SKShapeNode {
        let patronPhysics = SKPhysicsBody(circleOfRadius: 15)
        patronPhysics.categoryBitMask = PhysicsCategory.Patron
        patronPhysics.contactTestBitMask = PhysicsCategory.Table
        patronPhysics.collisionBitMask = PhysicsCategory.Table | PhysicsCategory.Patron
        patronPhysics.affectedByGravity = false
        let patronNode = SKShapeNode(circleOfRadius: 15)
        patronNode.fillColor = .orange
        patronNode.position = CGPoint(x: 430, y: 0)
        patronNode.physicsBody = patronPhysics
        patronNode.userData =  ["type" : NodeType.patron.rawValue ]
        return patronNode
    }
    
    func addUI() {
        
        let addTableNode = TappableNode(circleOfRadius: 25)
        addTableNode.fillColor = .yellow
        addTableNode.position = CGPoint(x: 60, y: 60)
        addTableNode.userData = ["type" : NodeType.ui.rawValue ]
        addTableNode.isUserInteractionEnabled = true
        addTableNode.wasTouched = { [unowned self] in
            self.floorNode.addChild(self.createTable())
        }
        self.addChild(addTableNode)
        
        let addPatronNode = TappableNode(circleOfRadius: 25)
        addPatronNode.fillColor = .green
        addPatronNode.position = CGPoint(x: self.frame.width - 60, y: 60)
        addPatronNode.userData = ["type" : NodeType.ui.rawValue ]
        addPatronNode.isUserInteractionEnabled = true
        addPatronNode.wasTouched = { [unowned self] in
            self.floorNode.addChild(self.createPatron())
        }
        self.addChild(addPatronNode)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let firstTouch = touches.first else { return }
        
        var currNode = self.atPoint(firstTouch.location(in: self))
        
        
        if currNode is SKLabelNode {
            currNode = currNode.parent!.parent!
        }
        
        if currNode is LabeledShapeNode {
            currNode = currNode.parent!
        }
        
        if let safeData = currNode.userData,
            (safeData["type"] as! String) == NodeType.ui.rawValue {
            return
        }
        
        if currNode != self, currNode != self.floorNode {
            self.currentlyDraggedNode = currNode
        }
        
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        if let firstTouch = touches.first,
            let currentNode = self.currentlyDraggedNode {
            currentNode.position = firstTouch.location(in: self.floorNode)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.currentlyDraggedNode = nil
        
        guard let firstTouch = touches.first else { return }
        
        //handle tap
        var currNode = self.atPoint(firstTouch.location(in: self))
        
        if currNode is SKLabelNode {
            currNode = currNode.parent!
        }
        
        if let node = currNode as? LabeledShapeNode {
            guard node.count > 0 else {
                return
            }
            
            guard !node.isShowingPatrons else {
                node.parent!.children.forEach { if ($0.userData!.value(forKey: "type") as! String) == NodeType.patron.rawValue { $0.removeFromParent() } }
                node.isShowingPatrons = false
                return
            }
            node.isShowingPatrons = true
            
            let degree = 360 / node.count
            for i in 1...node.count {
                
                let iDeg = i * degree
                
                let pat = self.createPatron()
                pat.physicsBody = nil
                
                currNode.parent!.addChild(pat)
                pat.position = currNode.position
                
                let bounds = currNode.parent!.frame
                
                //if 180 its in the middle bottom
                // if 360 it at middle top
                // if 90 its left middle
                // if 270
                // 45 - 135
                // 135 - 225
                // 225 - 315
                // 315 - 360, 0 - 45
                let halfWidth = bounds.width / 2
                let halfHeight = bounds.height / 2
                
                print(iDeg)
                
                var position = CGPoint.zero
                
                if 45...134 ~= iDeg {
                    let percent = 1 - (((CGFloat(iDeg) - 45.0)) / 90.0)
                    
                    position = CGPoint(x: bounds.width - halfWidth, y: (bounds.height * percent) - halfHeight)
                    
                }
                
                if 135...224 ~= iDeg {
                    let percent =  ((CGFloat(iDeg) - 135.0)) / 90.0
                    position = CGPoint(x: (bounds.width  * percent) - halfWidth, y: bounds.height - halfHeight)
                }
                
                if 225...314 ~= iDeg {
                    let percent =  (CGFloat(iDeg) - 225) / 90.0
                    position = CGPoint(x: -(bounds.width) + halfWidth, y: (bounds.height * percent) - halfHeight)
                }
                
                if 0...44 ~= iDeg {
                    let percent =  (CGFloat(iDeg)) / 90.0
                    position = CGPoint(x: (bounds.width * percent) - halfWidth, y: -(bounds.height - halfHeight))
                }
                
                if 315...360 ~= iDeg {
                    let percent =  (CGFloat(iDeg - 315) + 45) / 90.0
                    position = CGPoint(x: (bounds.width * percent) - halfWidth, y: -(bounds.height - halfHeight))
                }
                
                pat.run(SKAction.move(to: position, duration: 0.3))
            }
            
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
    
    
}

extension FirstEventScene: SKPhysicsContactDelegate {
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

class TappableNode: SKShapeNode {
    var wasTouched: (() -> ())?
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        self.wasTouched?()
    }
    
    
    
}

protocol Patron {
    var name: String { get set }
    var id: String { get set }
    var node: SKNode { get set }
}

protocol Table {
    var id: String { get set }
    var tableNode: SKNode { get set }
    var totalSeats: Int { get set }
    
    var patrons: [Patron] { get set }
    
    func add(_ patron: Patron) -> Bool
    func remove(_ patron: Patron) -> Bool
    
}

////    x
//// x [ ] x
//// x [ ] x
////    x


protocol TableNode {
    
    var sittingNodes: [SKShapeNode] { get set }
    
    var displayingSeats: Bool { get set }
    
    func fillSeat()
    func emptySeat()
    
    func displaySeats()
    func hideSeats()
    
    
}

class StandardTableNode: SKShapeNode {
    
}

class LabeledShapeNode: SKShapeNode {
    var countNode: SKLabelNode!
    var count = 0 {
        didSet {
            countNode.text = "\(count)"
        }
    }
    
    var isShowingPatrons: Bool = false
    
    func setupLabel() {
        self.countNode = SKLabelNode(text: "\(count)")
        self.countNode.position = CGPoint(x: 0, y: -(self.frame.height / 2) + (self.countNode.frame.height / 2))
        self.addChild(countNode)
        
    }
}
