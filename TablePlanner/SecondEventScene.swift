//
//  SecondEventScene.swift
//  TablePlanner
//
//  Created by ChristianBieniak on 17/4/17.
//  Copyright © 2017 Bieniapps. All rights reserved.
//

import UIKit
import SpriteKit

class SecondEventScene: SKScene {
    
    //construct a table with 6
    
    var floorNode: SKShapeNode!
    var tableNode: SKShapeNode!
    
    var currentlyDraggedNode: SKNode?
    
    func setup()  {
        self.setupPhysics()
        self.addFloor(self.size)
        self.setupTable()
        self.setupEmptySeats()
        
        for _ in 0...5 {
            self.floorNode.addChild(self.createPatron())
        }
    }
    
    
    func setupPhysics() {
        self.physicsWorld.contactDelegate = self
    }
    
    func addFloor(_ size: CGSize) {
        self.floorNode = SKShapeNode(rectOf: CGSize(width: 500, height: 500))
        self.floorNode.fillColor = .white
        self.floorNode.position = CGPoint(x: 250, y: 250)
        self.addChild(self.floorNode)
        
    }
    
    func setupTable() {
        
        self.tableNode = SKShapeNode(rectOf: CGSize(width: 200, height: 200), cornerRadius: 20)
        tableNode.fillColor = .brown
        tableNode.userData =  ["type" : NodeType.table.rawValue ]
        self.floorNode.addChild(self.tableNode)
        self.floorNode.zPosition = 1
        self.tableNode.position = CGPoint(x: 50, y: 50)
    }
    
    func setupEmptySeats() {
        var emptyNodes = [SKShapeNode]()
        for _ in 0...5 {
            let patronPhysics = SKPhysicsBody(circleOfRadius: 15)
            patronPhysics.categoryBitMask = PhysicsCategory.EmptySeat
            patronPhysics.contactTestBitMask = PhysicsCategory.Patron
            patronPhysics.collisionBitMask = PhysicsCategory.None
            patronPhysics.affectedByGravity = false
            
            let patronNode = SKShapeNode(circleOfRadius: 15)
            patronNode.strokeColor = .orange
            patronNode.physicsBody = patronPhysics
            patronNode.userData =  ["type" : NodeType.emptySeat.rawValue ]
            patronNode.zPosition = 2
            emptyNodes.append(patronNode)
            self.tableNode.addChild(patronNode)
            patronNode.position = CGPoint(x:0, y: 0)
        }
        
        emptyNodes[0].position = CGPoint(x: 0, y: -120)
        emptyNodes[1].position = CGPoint(x: 0, y: 120)
        emptyNodes[2].position = CGPoint(x: 120, y: -35)
        emptyNodes[3].position = CGPoint(x: 120, y: 35)
        emptyNodes[4].position = CGPoint(x: -120, y: -35)
        emptyNodes[5].position = CGPoint(x: -120, y: 35)
        
    }
    
    func createPatron() -> SKShapeNode {
        let patronPhysics = SKPhysicsBody(circleOfRadius: 15)
        patronPhysics.categoryBitMask = PhysicsCategory.Patron
        patronPhysics.contactTestBitMask = PhysicsCategory.EmptySeat
        patronPhysics.collisionBitMask = PhysicsCategory.None
        patronPhysics.affectedByGravity = false
        let patronNode = SKShapeNode(circleOfRadius: 15)
        patronNode.fillColor = .orange
        patronNode.position = CGPoint(x: -200, y: -200)
        patronNode.physicsBody = patronPhysics
        patronNode.zPosition = 3
        patronNode.userData =  ["type" : NodeType.patron.rawValue ]
        return patronNode
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let firstTouch = touches.first else { return }
        
        let currNode = self.atPoint(firstTouch.location(in: self))
        
        if let safeData = currNode.userData,
            (safeData["type"] as! String) == NodeType.patron.rawValue {
            self.currentlyDraggedNode = currNode
            return
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
        
        
    }
    
}

extension SecondEventScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        var patronNode: SKNode!
        var emptyNode: SKShapeNode!
        
        if contact.bodyA.categoryBitMask == PhysicsCategory.Patron &&
            contact.bodyB.categoryBitMask == PhysicsCategory.EmptySeat {
            patronNode = contact.bodyA.node
            emptyNode = contact.bodyB.node as! SKShapeNode
            
        } else if contact.bodyB.categoryBitMask == PhysicsCategory.Patron &&
            contact.bodyA.categoryBitMask == PhysicsCategory.EmptySeat {
            patronNode = contact.bodyB.node
            emptyNode = contact.bodyA.node as! SKShapeNode
            
        } else {
            return
        }
        
        guard emptyNode.fillColor != UIColor.orange else {
            return
        }
        
        //        patronNode.removeFromParent()
        //        self.tableNode.addChild(patronNode)
        //        patronNode.position = emptyNode.position
        patronNode.removeFromParent()
        //transition to patron
        emptyNode.fillColor = .orange
        
    }
}


