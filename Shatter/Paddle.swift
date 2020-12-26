//
//  Paddle.swift
//  Scatter
//
//  Created by Shanti Mickens on 8/18/19.
//  Copyright © 2019 Shanti Mickens. All rights reserved.
//

import Foundation
import SpriteKit

class Paddle : SKShapeNode {
    
    var xPos : CGFloat = 0
    var yPos : CGFloat = -340
    var paddleWidth : CGFloat = 85
    var paddleHeight : CGFloat = 22
    
    override init() {
        super.init()
        
        self.name = "Paddle"
        self.path = CGPath(rect: CGRect(x: xPos-paddleWidth/2, y: 0-paddleHeight/2, width: paddleWidth, height: paddleHeight), transform: nil)
        self.position = CGPoint(x: xPos, y: yPos)
        self.fillColor = #colorLiteral(red: 0, green: 0.6613205075, blue: 0.6170555353, alpha: 1)
        self.lineWidth = 0
        
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: paddleWidth, height: paddleHeight))
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.isDynamic = false
        self.physicsBody?.restitution = 1.0
        self.physicsBody?.friction = 0.0
        self.physicsBody?.linearDamping = 0.0
        self.physicsBody?.collisionBitMask = PhysicsCategories.Ball
        self.physicsBody?.categoryBitMask = PhysicsCategories.Paddle
        self.physicsBody?.contactTestBitMask = PhysicsCategories.Powerup | PhysicsCategories.Ball
        
    }
    
    func changeSize(size: CGFloat) {
        self.paddleWidth = size
        self.path = CGPath(rect: CGRect(x: -self.paddleWidth/2, y: -self.paddleHeight/2, width: self.paddleWidth, height: self.paddleHeight), transform: nil)
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.paddleWidth, height: self.paddleHeight))
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.isDynamic = false
        self.physicsBody?.restitution = 1.0
        self.physicsBody?.friction = 0.0
        self.physicsBody?.linearDamping = 0.0
        self.physicsBody?.collisionBitMask = PhysicsCategories.Ball
        self.physicsBody?.categoryBitMask = PhysicsCategories.Paddle
        self.physicsBody?.contactTestBitMask = PhysicsCategories.Powerup
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
