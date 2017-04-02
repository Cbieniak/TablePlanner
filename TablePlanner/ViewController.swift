//
//  ViewController.swift
//  TablePlanner
//
//  Created by ChristianBieniak on 2/4/17.
//  Copyright © 2017 Bieniapps. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {
    
    var scene: EventScene!

    override func viewDidLoad() {
        super.viewDidLoad()
        scene = EventScene(size: CGSize(width: 500, height: 500))
        scene.addFloor(CGSize(width: 500, height: 500))
        scene.addTables()
        
        if let skView = self.view as? SKView {
            skView.presentScene(scene)
        }
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchGestureRecognized(_:)))
        view.addGestureRecognizer(pinchGestureRecognizer)
    }
    
    func pinchGestureRecognized(_ gesture: UIPinchGestureRecognizer) {
        self.scene.pinchByScale(gesture.scale)
    }

}

class EventScene: SKScene {
    
    var currentlyDraggedNode: SKNode?
    
    var currentScale: CGFloat = 1.0
    
    var floorNode: SKShapeNode!
    
    func addFloor(_ size: CGSize) {
        self.floorNode = SKShapeNode(rectOf: CGSize(width: 500, height: 500))
        self.floorNode.fillColor = .white
        self.floorNode.position = CGPoint(x: 250, y: 250)
        
        self.addChild(self.floorNode)
        
    }
    
    func addTables() {
        let tableNode = SKShapeNode(rectOf: CGSize(width: 50, height: 50))
        tableNode.fillColor = .brown
        tableNode.position = CGPoint(x: 430, y: 20)
        
        self.floorNode.addChild(tableNode)
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let firstTouch = touches.first {
            let currNode = self.atPoint(firstTouch.location(in: self))
            if currNode != self, currNode != self.floorNode {
               self.currentlyDraggedNode = currNode
            }
          
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let firstTouch = touches.first,
            let currentNode = self.currentlyDraggedNode {
            currentNode.position = firstTouch.location(in: self.floorNode)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.currentlyDraggedNode = nil
    }
    
    func pinchByScale(_ scale: CGFloat) {
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



