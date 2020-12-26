//
//  Powerup.swift
//  Scatter
//
//  Created by Shanti Mickens on 8/18/19.
//  Copyright © 2019 Shanti Mickens. All rights reserved.
//

import Foundation
import SpriteKit

class Powerup : SKShapeNode {
    
    //produces random number between range
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    var goodColor : UIColor = #colorLiteral(red: 0.01014056616, green: 0.571777761, blue: 0.2686420381, alpha: 1)
    var badColor : UIColor = #colorLiteral(red: 0.8888825178, green: 0.1739994287, blue: 0.2071017623, alpha: 1)

    init(xPos: CGFloat, yPos: CGFloat) {
        super.init()
        
        let size : CGFloat = 25.0
        
        self.name = "Powerup"
        self.path = CGPath(ellipseIn: CGRect(x: -size/2, y: -size/2, width: size, height: size), transform: nil)
        self.position = CGPoint(x: 0, y: 0)
        self.fillColor = UIColor.clear
        self.lineWidth = 0
        
        self.physicsBody = SKPhysicsBody(circleOfRadius: size/2)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.isDynamic = true
        self.physicsBody?.collisionBitMask = PhysicsCategories.None
        self.physicsBody?.categoryBitMask = PhysicsCategories.Powerup
        self.physicsBody?.contactTestBitMask = PhysicsCategories.Paddle | PhysicsCategories.Ball
        
    }
    
    func getType() -> String {
        if (self.fillColor == goodColor) {
            // gives player good powerup (big paddle, slow down, ball bigger, sticky paddle, extra ball)
            return "Good"
        } else {
            // gives player bad powerup (small paddle, speed up, ball smaller)
            return "Bad"
        }
    }
    
    func fall() {
        // picks randomly between good and bad powerup
        switch(round(random(min: 1, max: 2))) {
        case 1:
            self.fillColor = goodColor
        case 2:
            self.fillColor = badColor
        default:
            print("error")
        }
        
        let fallAction = SKAction.moveBy(x: 0, y: -100, duration: 0.5)
        let delete = SKAction.removeFromParent()
        let continueFalling = SKAction.repeat(fallAction, count: 10)
        let fallThenDelete = SKAction.sequence([continueFalling, delete])
        self.run(fallThenDelete)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
