//
//  GameScene.swift
//  RolyPoly
//
//  Created by alex alex on 10/10/16.
//  Copyright © 2016 alex. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    private var spinnyNode : SKShapeNode?
    
    var timer = Timer()
    var screenSize: CGRect = UIScreen.main.bounds
    var screenWidth : CGFloat = 0.0
    var screenHeight : CGFloat = 0.0
    let roadBlockSize : CGFloat = 100.0
    
    let roly = SKSpriteNode(imageNamed: "roly")
    var isGrounded = true
    
    override func sceneDidLoad() {

        self.lastUpdateTime = 0
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(M_PI), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
        
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        scheduleTimerWithTimeInterval()
        
        
    }
    
    override func didMove(to view: SKView) {
        roly.size = CGSize(width: roadBlockSize, height: roadBlockSize)
        roly.position = CGPoint(x: 0, y: 0)
        roly.zPosition = CGFloat(100)
        addChild(roly)
        scheduleTimerWithTimeInterval()
    }
    
    func scheduleTimerWithTimeInterval() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.generateRoad), userInfo: nil, repeats: true)
    
    }
    
    func generateRoad () {
        let roadTile = SKSpriteNode(imageNamed: "road")
        roadTile.position = CGPoint(x: 0, y: screenHeight + roadBlockSize * 2)
        roadTile.name = "road"
        roadTile.size = CGSize(width: roadBlockSize, height: roadBlockSize)
        addChild(roadTile)
    }
    
    func moveRoadDown(){
        enumerateChildNodes(withName: "road") { node, stop in
            
            if !node.hasActions() {
                let moveNodeDown = SKAction.move(to: CGPoint(x: node.position.x, y: node.position.y - 100), duration: 1)
                node.run(moveNodeDown)
            }
            if node.position.y < (-1) * self.screenHeight - self.roadBlockSize - 50  {
                node.removeFromParent()
            }
        }
    }
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
        
        if isGrounded {
            isGrounded = false
            
            let jumpTime = 0.6
            let jump = SKAction.scale(by: 1.5, duration: jumpTime / 2)
            let land = SKAction.scale(by: 0.666667, duration: jumpTime / 2)
            roly.run(SKAction.sequence([jump, land]))
            
            let block = SKAction.run({
                self.roly.run(jump)
                self.roly.run(land)
            })
            
            let finish = SKAction.run({
                self.isGrounded = true
            })
            
            let sequence = SKAction.sequence([block, SKAction.wait(forDuration: jumpTime), finish])
            
            self.run(sequence)

        }
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        
        moveRoadDown()
        
        self.lastUpdateTime = currentTime
    }
}
