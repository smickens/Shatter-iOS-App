//
//  Square.swift
//  Scatter
//
//  Created by Shanti Mickens on 8/5/19.
//  Copyright © 2019 Shanti Mickens. All rights reserved.
//

import Foundation
import SpriteKit

class Square : Block {
    
    init(blockX: CGFloat, blockY: CGFloat, colorIndex: Int) {
        super.init(x: blockX, y: blockY, colorIndex: colorIndex)
        
        self.name = "Square"
        self.path = CGPath(rect: CGRect(x: -self.w/2, y: -self.h/2, width: self.w, height: self.h), transform: nil)
        
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: w, height: h))
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.isDynamic = false
        self.physicsBody?.restitution = 1.0
        self.physicsBody?.friction = 0.0
        self.physicsBody?.collisionBitMask = PhysicsCategories.Ball
        self.physicsBody?.categoryBitMask = PhysicsCategories.Block
        self.physicsBody?.contactTestBitMask = PhysicsCategories.Ball
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

