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
    
    let roly = SKSpriteNode(imageNamed: "roly1")
    var isGrounded = true
    
    override func sceneDidLoad() {

        self.lastUpdateTime = 0
        
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
        // 1
        var textures:[SKTexture] = []
        // 2
        for i in 1...5 {
            textures.append(SKTexture(imageNamed: "roly\(i)"))
        }
        // 3
        textures.append(textures[2])
        textures.append(textures[1])
        
        // 4
        var zombieAnimation: SKAction =  SKAction.animate(with: textures,
                                           timePerFrame: 0.1)
        
        roly.run(SKAction.repeatForever(zombieAnimation))
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
    
    func generatePit() {
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
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
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
