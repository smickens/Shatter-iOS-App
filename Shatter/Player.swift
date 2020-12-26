//
//  Player.swift
//  Scatter
//
//  Created by Shanti Mickens on 8/18/19.
//  Copyright © 2019 Shanti Mickens. All rights reserved.
//

import Foundation
import SpriteKit

class Player : SKShapeNode {
    
    var size : CGFloat = 20
    
    var lastDX : CGFloat = 0.0
    var lastDY : CGFloat = 0.0
    
    var stuck = false
    
    init(ellipseIn: CGRect) {
        super.init()
        
        self.name = "Ball"
        self.path = CGPath(ellipseIn: CGRect(x: -(size/2), y: -(size/2), width: size, height: size), transform: nil)
        self.position = CGPoint(x: 0, y: -355 + size)
        self.fillColor = #colorLiteral(red: 0.3019383252, green: 0.3019773364, blue: 0.3019207716, alpha: 1)
        self.lineWidth = 0
        
        self.physicsBody = SKPhysicsBody(circleOfRadius: size/2)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.isDynamic = true
        self.physicsBody?.restitution = 1.0
        self.physicsBody?.friction = 0.0
        self.physicsBody?.linearDamping = 0.0
        
        self.physicsBody?.collisionBitMask = PhysicsCategories.Border | PhysicsCategories.Paddle | PhysicsCategories.Block
        self.physicsBody?.categoryBitMask = PhysicsCategories.Ball
        self.physicsBody?.contactTestBitMask = PhysicsCategories.Block | PhysicsCategories.Powerup | PhysicsCategories.Paddle
    }
    
    func changeSize(size: CGFloat) {
        self.size = size
        self.path = CGPath(ellipseIn: CGRect(x: -(self.size/2), y: -(self.size/2), width: self.size, height: self.size), transform: nil)
        let curVelocity = self.physicsBody!.velocity
        self.physicsBody = SKPhysicsBody(circleOfRadius: self.size/2)
        self.physicsBody?.velocity = curVelocity
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.isDynamic = true
        self.physicsBody?.restitution = 1.0
        self.physicsBody?.friction = 0.0
        self.physicsBody?.linearDamping = 0.0
        self.physicsBody?.collisionBitMask = PhysicsCategories.Border | PhysicsCategories.Paddle | PhysicsCategories.Block
        self.physicsBody?.categoryBitMask = PhysicsCategories.Ball
        self.physicsBody?.contactTestBitMask = PhysicsCategories.Block | PhysicsCategories.Powerup
    }
    
    func changeSpeed(factor: CGFloat) {
        let speedUp = SKAction.run {
            let curDX = (self.physicsBody?.velocity.dx)!
            let curDY = (self.physicsBody?.velocity.dy)!
            self.physicsBody?.velocity = CGVector(dx: curDX * factor, dy: curDY * factor)
        }
        let delay = SKAction.wait(forDuration: 5)
        let reset = SKAction.run {
            let curDX = (self.physicsBody?.velocity.dx)!
            let curDY = (self.physicsBody?.velocity.dy)!
            self.physicsBody?.velocity = CGVector(dx: curDX / factor, dy: curDY / factor)
        }
        let speedUpandReset = SKAction.sequence([speedUp, delay, reset])
        self.parent?.run(speedUpandReset)
    }
    
    func stick() {
        // if the ball isn't already stuck, then it sticks it to the paddle
        if (self.stuck != true) {
            // sets the instance variable of stuck to true since the ball is now stuck to the paddle
            self.stuck = true
        
            // saves the ball's current velocity
            self.saveBallSpeed(speed: self.physicsBody!.velocity)
        
            // stops the ball
            self.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        
            // ensures the ball is touching the paddle
            let move = SKAction.moveTo(y: -355 + size, duration: 0.1)
            self.run(move)
        }
    }
    
    func unstick() {
        self.stuck = false
        self.physicsBody?.velocity = CGVector(dx: lastDX, dy: lastDY)
    }
    
    func saveBallSpeed(speed: CGVector) {
        lastDX = speed.dx
        lastDY = speed.dy
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
