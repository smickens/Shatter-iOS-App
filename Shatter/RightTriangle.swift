//
//  RightTriangle.swift
//  Scatter
//
//  Created by Shanti Mickens on 9/2/19.
//  Copyright © 2019 Shanti Mickens. All rights reserved.
//

import Foundation
import SpriteKit

class RightTriangle: Block {
    
    init(blockX: CGFloat, blockY: CGFloat, colorIndex: Int, direction: String) {
        super.init(x: blockX, y: blockY, colorIndex: colorIndex)
        
        self.name = "Right Triangle"
        
        let path = UIBezierPath()
        switch(direction) {
            case "Top Left":
                path.move(to: CGPoint(x: self.w/2, y: self.h/2))
                path.addLine(to: CGPoint(x: self.w/2, y: -self.h/2))
                path.addLine(to: CGPoint(x: -self.w/2, y: -self.h/2))
                path.addLine(to: CGPoint(x: self.w/2, y: self.h/2))
                path.addLine(to: CGPoint(x: self.w/2, y: -self.h/2))
            case "Top Right":
                path.move(to: CGPoint(x: -self.w/2, y: self.h/2))
                path.addLine(to: CGPoint(x: self.w/2, y: -self.h/2))
                path.addLine(to: CGPoint(x: -self.w/2, y: -self.h/2))
                path.addLine(to: CGPoint(x: -self.w/2, y: self.h/2))
                path.addLine(to: CGPoint(x: self.w/2, y: -self.h/2))
            case "Bottom Left":
                path.move(to: CGPoint(x: -self.w/2, y: self.h/2))
                path.addLine(to: CGPoint(x: self.w/2, y: self.h/2))
                path.addLine(to: CGPoint(x: self.w/2, y: -self.h/2))
                path.addLine(to: CGPoint(x: -self.w/2, y: self.h/2))
                path.addLine(to: CGPoint(x: self.w/2, y: self.h/2))
            case "Bottom Right":
                path.move(to: CGPoint(x: -self.w/2, y: self.h/2))
                path.addLine(to: CGPoint(x: self.w/2, y: self.h/2))
                path.addLine(to: CGPoint(x: -self.w/2, y: -self.h/2))
                path.addLine(to: CGPoint(x: -self.w/2, y: self.h/2))
                path.addLine(to: CGPoint(x: self.w/2, y: self.h/2))
            default:
                print("error")
        }
        self.path = path.cgPath
        
        self.physicsBody = SKPhysicsBody(edgeChainFrom: path.cgPath)
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
