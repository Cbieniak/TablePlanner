//
//  FloorViewController.swift
//  TablePlanner
//
//  Created by ChristianBieniak on 1/5/17.
//  Copyright © 2017 Bieniapps. All rights reserved.
//

import UIKit
import SpriteKit

class FloorViewController: UIViewController {

    var scene: SKScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupThirdEventScene()
        
        if let skView = self.view as? SKView {
            skView.presentScene(scene)
        }
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchGestureRecognized(_:)))
        pinchGestureRecognizer.delegate = self
        view.addGestureRecognizer(pinchGestureRecognizer)
        
        let rotateGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(roatationGestureRecognized(_:)))
        rotateGestureRecognizer.delegate = self
        view.addGestureRecognizer(rotateGestureRecognizer)
    }

    
    func setupThirdEventScene() {
        let eventScene = ThirdEventScene(size: CGSize(width: 500, height: 500))
        eventScene.addFloor(CGSize(width: 500, height: 500))
        //eventScene.floorNode.addChild(eventScene.createTable())
        eventScene.addUI()
        self.scene = eventScene
    }
    
    func pinchGestureRecognized(_ gesture: UIPinchGestureRecognizer) {
        self.scene.pinchByScale(gesture.scale)
    }
    
    func roatationGestureRecognized(_ gesture: UIRotationGestureRecognizer) {
        self.scene.rotateWith(gesture.rotation)
    }

}

extension FloorViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}



