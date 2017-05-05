//
//  ViewController.swift
//  TablePlanner
//
//  Created by ChristianBieniak on 2/4/17.
//  Copyright © 2017 Bieniapps. All rights reserved.
//

import UIKit
import SpriteKit

enum VCState {
    case floor
    case tables
    case table
}

class ViewController: UIViewController {
    
    var scene: SKScene!
    
    @IBOutlet weak var sceneView: SKView!
    
    var state : VCState = .floor {
        didSet {
            self.updateScene(oldValue)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupThirdEventScene()
       
        sceneView.presentScene(scene)
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchGestureRecognized(_:)))
        pinchGestureRecognizer.delegate = self
        view.addGestureRecognizer(pinchGestureRecognizer)
        
        let rotateGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(roatationGestureRecognized(_:)))
        rotateGestureRecognizer.delegate = self
        view.addGestureRecognizer(rotateGestureRecognizer)
    }
    
    
    @IBAction func showFloor(_ sender: Any) {
        self.state = .floor
    }
    
    @IBAction func showTables(_ sender: Any) {
        self.state = .tables
    }
    
    @IBAction func showTable(_ sender: Any) {
        self.state = .table
    }
    
    func updateScene(_ previousState: VCState) {
        guard self.state != previousState else {
            return
        }
        
        switch state {
        case .floor:
            self.setupThirdEventScene()
        case .tables:
            self.setupEventScene()
        case .table:
            self.setupSecondEventScene()
        }
        
        sceneView.presentScene(scene)
    }
    
    func setupEventScene() {
        let eventScene = FirstEventScene(size: CGSize(width: 500, height: 500))
        eventScene.addFloor(CGSize(width: 500, height: 500))
        eventScene.floorNode.addChild(eventScene.createTable())
        eventScene.addUI()
        self.scene = eventScene
    }
    
    func setupSecondEventScene() {
        let eventScene = SecondEventScene(size: CGSize(width: 500, height: 500))
        eventScene.setup()
        self.scene = eventScene
    }
    
    func setupThirdEventScene() {
        let eventScene = ThirdEventScene(size: CGSize(width: 500, height: 500))
        eventScene.addFloor(CGSize(width: 500, height: 500))
        //eventScene.floorNode.addChild(eventScene.createTable())
        eventScene.addUI()
        self.scene = eventScene
    }
    
    func pinchGestureRecognized(_ gesture: UIPinchGestureRecognizer) {
        if state != .floor {
            self.scene.pinchByScale(gesture.scale)  
        }
        
    }
    
    func roatationGestureRecognized(_ gesture: UIRotationGestureRecognizer) {
        self.scene.rotateWith(gesture.rotation)
    }

}

extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension SKScene {
    func pinchByScale(_ scale: CGFloat) { }
    
    func rotateWith(_ rotation: CGFloat) { }
}

enum NodeType : String {
    case floor
    case table
    case patron
    case emptySeat
    case ui
}

struct PhysicsCategory {
    static let None         : UInt32 = 0
    static let Patron       : UInt32 = 0b1       // 1
    static let Table        : UInt32 = 0b10      // 2
    static let Floor        : UInt32 = 0b100
    static let EmptySeat    : UInt32 = 0b1000
}




class Grid:SKSpriteNode {
    var rows:Int!
    var cols:Int!
    var blockSize:CGFloat!
    
    convenience init?(blockSize:CGFloat,rows:Int,cols:Int) {
        guard let texture = Grid.gridTexture(blockSize: blockSize,rows: rows, cols:cols) else {
            return nil
        }
        self.init(texture: texture, color:SKColor.clear, size: texture.size())
        self.blockSize = blockSize
        self.rows = rows
        self.cols = cols
    }
    
    class func gridTexture(blockSize:CGFloat,rows:Int,cols:Int) -> SKTexture? {
        // Add 1 to the height and width to ensure the borders are within the sprite
        let size = CGSize(width: CGFloat(cols)*blockSize+1.0, height: CGFloat(rows)*blockSize+1.0)
        UIGraphicsBeginImageContext(size)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        let bezierPath = UIBezierPath()
        let offset:CGFloat = 0.5
        // Draw vertical lines
        for i in 0...cols {
            let x = CGFloat(i)*blockSize + offset
            bezierPath.move(to: CGPoint(x: x, y: 0))
            bezierPath.addLine(to: CGPoint(x: x, y: size.height))
        }
        // Draw horizontal lines
        for i in 0...rows {
            let y = CGFloat(i)*blockSize + offset
            bezierPath.move(to: CGPoint(x: 0, y: y))
            bezierPath.addLine(to: CGPoint(x: size.width, y: y))
        }
        SKColor.orange.setStroke()
        bezierPath.lineWidth = 1.0
        bezierPath.stroke()
        context.addPath(bezierPath.cgPath)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return SKTexture(image: image!)
    }
    
    func gridPosition(row:Int, col:Int) -> CGPoint {
        let offset = blockSize / 2.0 + 0.5
        let x = CGFloat(col) * blockSize - (blockSize * CGFloat(cols)) / 2.0 + offset
        let y = CGFloat(rows - row - 1) * blockSize - (blockSize * CGFloat(rows)) / 2.0 + offset
        return CGPoint(x:x, y:y)
    }
}










