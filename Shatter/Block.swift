//
//  Block.swift
//  Scatter
//
//  Created by Shanti Mickens on 9/9/19.
//  Copyright © 2019 Shanti Mickens. All rights reserved.
//

import Foundation
import SpriteKit

class Block: SKShapeNode {
    
    var index : Int = 0
    var colors : [UIColor] = [#colorLiteral(red: 0, green: 0.6613205075, blue: 0.6170555353, alpha: 1), #colorLiteral(red: 0, green: 0.6613205075, blue: 0.6170555353, alpha: 1), #colorLiteral(red: 0, green: 0.6613205075, blue: 0.6170555353, alpha: 1), #colorLiteral(red: 0.5111412406, green: 0.7958028913, blue: 0.7701452374, alpha: 1), #colorLiteral(red: 0.5111412406, green: 0.7958028913, blue: 0.7701452374, alpha: 1), #colorLiteral(red: 0.7621638179, green: 0.902371645, blue: 0.8869937062, alpha: 1)]
    var x : CGFloat = 0.0
    var y : CGFloat = 0.0
    
    var w : CGFloat = 48.0
    var h : CGFloat = 48.0
    
    //produces random number between range
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    init(x: CGFloat, y: CGFloat, colorIndex: Int) {
        super.init()
        
        self.x = x
        self.y = y
        self.index = colorIndex - 1
        self.position = CGPoint(x: self.x, y: self.y)
        self.fillColor = colors[self.index]
        self.lineWidth = 0
        
        // currently only have powerups on square blocks
        switch(round(random(min: 1, max: 3))) {
        case 1:
            let powerup = Powerup(xPos: self.x, yPos: self.y)
            powerup.zPosition = 1
            self.addChild(powerup)
        default:
            break
        }
    }
    
    func onHit() -> Powerup? {
        
        var powerup : Powerup? = nil
        if (self.index < colors.count - 1) {
            // changes it color
            self.index += 1
            self.fillColor = colors[self.index]
        } else {
            if (self.children.count > 0) {
                powerup = (self.childNode(withName: "Powerup") as! Powerup)
                powerup?.position = self.position
                self.removeAllChildren()
            }
            
            // it destroys the block
            self.removeFromParent()
        }
        return powerup
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
