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
    var rolySpeed : Double = 100.0
    let roly = SKSpriteNode(imageNamed: "roly1")
    let background1 = SKSpriteNode(imageNamed: "background1")
    let background2 = SKSpriteNode(imageNamed: "background2")
    var isGrounded = true
    var lives = 3
    
    let lower : UInt32 = 0
    let upper : UInt32 = 500
    var randomNumber : UInt32 = 0
    
    override func sceneDidLoad() {

        self.lastUpdateTime = 0
        
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        scheduleTimerWithTimeInterval()
        
        
    }
    
    override func didEvaluateActions()  {
        checkCollisions()
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
        let zombieAnimation: SKAction =  SKAction.animate(with: textures,
                                           timePerFrame: 0.1)
        
        roly.run(SKAction.repeatForever(zombieAnimation))
        initBackground()
    }
    
    private func initBackground() {
        background1.anchorPoint = CGPoint.zero
        background1.position = CGPoint(x: -screenWidth, y: -screenHeight)
        background1.zPosition = -15
        self.addChild(background1)
        
        background2.anchorPoint = CGPoint.zero
        background2.position = CGPoint(x: -screenWidth, y: background1.size.height - screenHeight - 6)
        background2.zPosition = -15
        self.addChild(background2)
    }
    
    private func moveBackground(amount: CGFloat) {
        background1.position = CGPoint(x: background1.position.x, y: background1.position.y - amount)
        background2.position = CGPoint(x: background2.position.x, y: background2.position.y - amount)
        
        if(background1.position.y < (-background1.size.height - screenHeight)) {
            background1.position = CGPoint(x: background1.position.x, y: background2.position.y + background2.size.height - 6)
        }
        
        if(background2.position.y < (-background2.size.height - screenHeight)) {
            background2.position = CGPoint(x: background2.position.x, y: background1.position.y + background1.size.height - 6)
            
        }
    }

    
    func scheduleTimerWithTimeInterval() {
        timer = Timer.scheduledTimer(timeInterval: 50/self.rolySpeed, target: self, selector: #selector(self.generateRoad), userInfo: nil, repeats: true)
    
    }
    
    func generateRoad () {
        let roadTile = SKSpriteNode(imageNamed: "road")
        roadTile.position = CGPoint(x: 0, y: screenHeight + roadBlockSize * 2)
        roadTile.name = "road"
        roadTile.size = CGSize(width: roadBlockSize, height: roadBlockSize)
        addChild(roadTile)
        
        randomNumber = arc4random_uniform(upper - lower) + lower
        if(randomNumber < 10) {
            generatePit()
        }
    }
    
    func generatePit() {
       
        let pitTile = SKSpriteNode(imageNamed: "pit")
        pitTile.position = CGPoint(x: 0, y: screenHeight + roadBlockSize * 2)
        pitTile.name = "pit"
        pitTile.zPosition = 50
        pitTile.size = CGSize(width: roadBlockSize, height: roadBlockSize)
        addChild(pitTile)

    }
    
    func moveRoadDown(){
        enumerateChildNodes(withName: "road") { node, stop in
            
            if !node.hasActions() {
                let moveNodeDown = SKAction.move(to: CGPoint(x: node.position.x, y: node.position.y - CGFloat(self.rolySpeed)), duration: 1)
                node.run(moveNodeDown)
            }
            if node.position.y < (-1) * self.screenHeight - self.roadBlockSize - 50  {
                node.removeFromParent()
            }
        }
    }
    
    func movePitDown(){
        enumerateChildNodes(withName: "pit") { node, stop in
            
            if !node.hasActions() {
                let moveNodeDown = SKAction.move(to: CGPoint(x: node.position.x, y: node.position.y - CGFloat(self.rolySpeed)), duration: 1)
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
            self.rolySpeed = 200
            
            let jumpTime = 1.6 //if speed 100 time = 1.2
            let jump = SKAction.scale(by: 1.5, duration: jumpTime / 2)
            let land = SKAction.scale(by: 0.666667, duration: jumpTime / 2)
            roly.run(SKAction.sequence([jump, land]))
            
            let block = SKAction.run({
                self.roly.run(jump)
                self.roly.run(land)
            })
            
            let finish = SKAction.run({
                self.isGrounded = true
                self.rolySpeed = 100
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
        moveBackground(amount: 25)
        
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
        movePitDown()
        
        self.lastUpdateTime = currentTime
    }
    
    func checkCollisions() {
        var hitPits: [SKSpriteNode] = []
        enumerateChildNodes(withName: "pit") { node, _ in
            let pit = node as! SKSpriteNode
            if node.frame.insetBy(dx: 5, dy: 5).intersects(self.roly.frame) && self.isGrounded {
                hitPits.append(pit)
            }
        }
        for p in hitPits {
            rolyHitsPit(p)
        }
    }
    
    func rolyHitsPit(_ pit: SKSpriteNode) {
        //todo run(pitCollisionSound)
        lives -= 1
        
        let blinkTimes = 10.0
        let duration = 3.0
        let blinkAction = SKAction.customAction(withDuration: duration) { node, elapsedTime in
            let slice = duration / blinkTimes
            let remainder = Double(elapsedTime).truncatingRemainder(dividingBy: slice)
            node.isHidden = remainder > slice / 2
        }
        let setHidden = SKAction.run() {
            self.roly.isHidden = false
        }
        roly.run(SKAction.sequence([blinkAction, setHidden]))
        
    }
}
