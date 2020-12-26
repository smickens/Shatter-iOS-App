//
//  MenuScene.swift
//  Scatter
//
//  Created by Shanti Mickens on 9/22/19.
//  Copyright © 2019 Shanti Mickens. All rights reserved.
//

import SpriteKit
import GameplayKit

class MenuScene: SKScene {
    
    var playButton : SKShapeNode?
    var levelSelectButton : SKShapeNode?
    
    //produces random number between range
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    override func didMove(to view: SKView) {

        super.didMove(to: view)
        self.size = view.frame.size
        
        // sets background color to white
        self.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        // displays title screen
        let title = SKLabelNode(text: "SHATTER")
        title.name = "Title"
        title.fontName = "Mansalva-Regular"
        title.fontSize = 60
        title.fontColor = #colorLiteral(red: 0, green: 0.6613205075, blue: 0.6170555353, alpha: 1)
        title.position = CGPoint(x: 0.0, y: 275.0)
        title.zPosition = 2
        self.addChild(title)
        
        // creates random shapes that fall in the background
        for _ in 1...18 {
            let randStartHeight = random(min: 150.0, max: 900.0)
            let randX = random(min: -self.frame.width/2, max: self.frame.width/2)
            switch (round(random(min: 1, max: 3))) {
                case 1: // square block
                    AddBlock(x: randX, y: self.frame.height + randStartHeight, index: Int(random(min: 1, max: 6)))
                    break
                case 2: // equilateral triangle
                    AddTriangleBlock(x: randX, y: self.frame.height + randStartHeight, index: Int(random(min: 1, max: 6)), dir: "Up")
                    break
                case 3: // right triangle
                    AddRightTriangleBlock(x: randX, y: self.frame.height + randStartHeight, index: Int(random(min: 1, max: 6)), dir: "Top Left")
                    break
                default:
                    AddBlock(x: randX, y: self.frame.height + randStartHeight, index: Int(random(min: 1, max: 6)))
            }
        }
        
        for child in self.children {
            if (child.name != "Title") {
                // makes blocks spin around at varying speeds
                let randSpeed = random(min: 4.5, max: 7.0)
                let rotate : SKAction?
                if (round(random(min: 0, max: 1)) == 0) {
                    rotate = SKAction.rotate(byAngle: 10, duration: TimeInterval(randSpeed))
                } else {
                    rotate = SKAction.rotate(byAngle: -10, duration: TimeInterval(randSpeed))
                }
                let delay = SKAction.wait(forDuration: TimeInterval(randSpeed))
                let rotateBlock = SKAction.sequence([rotate!, delay])
                let keepRotating = SKAction.repeatForever(rotateBlock)
                child.run(keepRotating)
                
                // makes blocks fall at varying speeds
                let fall = SKAction.moveTo(y: -self.frame.height - 150.0, duration: TimeInterval(random(min: 3.0, max: 5.5)))
                let delete = SKAction.run {
                    child.removeFromParent()
                }
                let fallThenDelete = SKAction.sequence([fall, delete])
                child.run(fallThenDelete)
            }
        }
        
        let delay = SKAction.wait(forDuration: 3.25)
        let displayMenu = SKAction.run {
            let fadeIn = SKAction.fadeIn(withDuration: 1.0)
            
            let buttonWidth = 200.0
            let buttonHeight = 60.0
            
            self.playButton = SKShapeNode(rect: CGRect(x: -buttonWidth/2, y: 0.0, width: buttonWidth, height: buttonHeight), cornerRadius: 15.0)
            self.playButton?.fillColor = #colorLiteral(red: 0.5111412406, green: 0.7958028913, blue: 0.7701452374, alpha: 1)
            self.playButton?.lineWidth = 0
            self.playButton?.alpha = 0.0
            self.playButton?.run(fadeIn)
            self.addChild(self.playButton!)
            
            let playLabel = SKLabelNode(text: "Play")
            playLabel.position = CGPoint(x: 0.0, y: buttonHeight/4)
            playLabel.fontName = "JosefinSans-SemiBold"
            playLabel.fontColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            playLabel.fontSize = 35.0
            playLabel.alpha = 0.0
            playLabel.run(fadeIn)
            self.addChild(playLabel)
            
            self.levelSelectButton = SKShapeNode(rect: CGRect(x: -buttonWidth/2, y: -75.0, width: buttonWidth, height: buttonHeight), cornerRadius: 15.0)
            self.levelSelectButton?.fillColor = #colorLiteral(red: 0.5111412406, green: 0.7958028913, blue: 0.7701452374, alpha: 1)
            self.levelSelectButton?.lineWidth = 0
            self.levelSelectButton?.alpha = 0.0
            self.levelSelectButton?.run(fadeIn)
            self.addChild(self.levelSelectButton!)
            
            let levelSelectLabel = SKLabelNode(text: "Levels")
            levelSelectLabel.position = CGPoint(x: 0.0, y: -75.0+buttonHeight/4)
            levelSelectLabel.fontName = "JosefinSans-SemiBold"
            levelSelectLabel.fontColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            levelSelectLabel.fontSize = 35.0
            levelSelectLabel.alpha = 0.0
            levelSelectLabel.run(fadeIn)
            self.addChild(levelSelectLabel)
        }
        let waitThenDisplayMenu = SKAction.sequence([delay, displayMenu])
        self.run(waitThenDisplayMenu)
        
    }
    
    // creates a new block based on an x and y position and an index for its intial color
    func AddRightTriangleBlock(x: CGFloat, y: CGFloat, index: Int, dir: String) {
        let block = RightTriangle(blockX: x, blockY: y, colorIndex: index, direction: dir)
        self.addChild(block)
    }
    
    // creates a new block based on an x and y position and an index for its intial color
    func AddTriangleBlock(x: CGFloat, y: CGFloat, index: Int, dir: String) {
        let block = Triangle(blockX: x, blockY: y, colorIndex: index, direction: dir)
        self.addChild(block)
    }
    
    // creates a new block based on an x and y position and an index for its intial color
    func AddBlock(x: CGFloat, y: CGFloat, index: Int) {
        let block = Square(blockX: x, blockY: y, colorIndex: index)
        self.addChild(block)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            let locationOfTouch = touch.location(in: self)
            
            if (playButton != nil) {
                if ((playButton?.contains(locationOfTouch))!) {
                    // when play button is pressed it switches to the game scene
                    let switchToGameScene = SKAction.run {
                        let scene = SKScene(fileNamed: "GameScene")!
                        scene.size = self.size
                        scene.scaleMode = self.scaleMode
                        let transition = SKTransition.fade(with: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), duration: 1.0)
                        self.view?.presentScene(scene, transition: transition)
                    }
                    self.run(switchToGameScene)
                }
            }
                
            if (levelSelectButton != nil) {
                if ((levelSelectButton?.contains(locationOfTouch))!) {
                    // when level select button is pressed it switches to the level select scene
                    let switchToLevelSelectScene = SKAction.run {
                        let scene = SKScene(fileNamed: "LevelSelectScene")!
                        scene.size = self.size
                        scene.scaleMode = self.scaleMode
                        let transition = SKTransition.fade(with: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), duration: 1.0)
                        self.view?.presentScene(scene, transition: transition)
                    }
                    self.run(switchToLevelSelectScene)
                }
            }
            
        }
        
    }
}
