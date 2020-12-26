//
//  LevelSelectScene.swift
//  Scatter
//
//  Created by Shanti Mickens on 9/22/19.
//  Copyright © 2019 Shanti Mickens. All rights reserved.
//

import SpriteKit
import GameplayKit

var currentLevel = 1
let defaults = UserDefaults.standard

class LevelSelectScene : SKScene {
    
    var levelButtons = [SKShapeNode]()
    
    //produces random number between range
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    override func didMove(to view: SKView) {
        
        // sets background color to white
        self.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        // displays title screen
        let levelSelectLabel = SKLabelNode(text: "LEVELS")
        levelSelectLabel.fontName = "Mansalva-Regular"
        levelSelectLabel.fontSize = 60
        levelSelectLabel.fontColor = #colorLiteral(red: 0, green: 0.6613205075, blue: 0.6170555353, alpha: 1)
        levelSelectLabel.position = CGPoint(x: 0.0, y: 315.0)
        levelSelectLabel.zPosition = 2
        self.addChild(levelSelectLabel)
                
        // creates stage 1 section
        
        let section_width = self.frame.width - 50.0
        let stage_1_section = SKShapeNode(rect: CGRect(x: -section_width/2, y: 40.0, width: section_width, height: 220.0), cornerRadius: 15.0)
        stage_1_section.fillColor = #colorLiteral(red: 0.7621638179, green: 0.902371645, blue: 0.8869937062, alpha: 1)
        stage_1_section.lineWidth = 0
        self.addChild(stage_1_section)
        
        let stage_1_label = SKLabelNode(text: "STAGE 1")
        stage_1_label.position = CGPoint(x: 0.0, y: 210.0)
        stage_1_label.fontName = "JosefinSans-SemiBold"
        stage_1_label.fontSize = 35
        stage_1_label.fontColor = #colorLiteral(red: 0, green: 0.6613205075, blue: 0.6170555353, alpha: 1)
        self.addChild(stage_1_label)
        
        let stage_2_section = SKShapeNode(rect: CGRect(x: -section_width/2, y: -220.0, width: section_width, height: 220.0), cornerRadius: 15.0)
        stage_2_section.fillColor = #colorLiteral(red: 0.7621638179, green: 0.902371645, blue: 0.8869937062, alpha: 1)
        stage_2_section.lineWidth = 0
        self.addChild(stage_2_section)
        
        let stage_2_label = SKLabelNode(text: "STAGE 2")
        stage_2_label.position = CGPoint(x: 0.0, y: -50.0)
        stage_2_label.fontName = "JosefinSans-SemiBold"
        stage_2_label.fontSize = 35
        stage_2_label.fontColor = #colorLiteral(red: 0, green: 0.6613205075, blue: 0.6170555353, alpha: 1)
        self.addChild(stage_2_label)
        
        
        // fills in a row
        var levelNumber = 1
        for j in 1...4 {
            for i in 1...5 {
                let w : CGFloat = 60.0
                let h : CGFloat = 60.0
                let xPos : CGFloat = ((w + 10) * CGFloat(i-3))
                var yPos : CGFloat = -((h + 10) * CGFloat(j)) + 200.0
                if (levelNumber >= 11 && levelNumber <= 20) {
                    yPos -= 120.0
                }
                
                let levelButton = SKShapeNode(rect: CGRect(x: xPos - w/2, y: yPos, width: w, height: h), cornerRadius: 15.0)
                levelButton.name = String(levelNumber)
                levelButton.lineWidth = 0
                self.addChild(levelButton)
                levelButtons.append(levelButton)
                
                // gets boolean data for if level is unlocked
                if (defaults.bool(forKey: "unlocked_\(levelNumber)") == true || levelNumber == 1) {
                    // unlocked level
                    levelButton.fillColor = #colorLiteral(red: 0, green: 0.6613205075, blue: 0.6170555353, alpha: 1)
                } else {
                    // locked level
                    levelButton.fillColor = #colorLiteral(red: 0.5111412406, green: 0.7958028913, blue: 0.7701452374, alpha: 1)
                }
                
                let levelButtonLabel = SKLabelNode(text: String(levelNumber))
                levelButtonLabel.position = CGPoint(x: xPos, y: yPos + h/4)
                levelButtonLabel.fontName = "JosefinSans-SemiBold"
                levelButtonLabel.fontColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                levelButtonLabel.fontSize = 40.0
                self.addChild(levelButtonLabel)
                
                levelNumber += 1
            }
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            let locationOfTouch = touch.location(in: self)
             
            for button in levelButtons {
                if (button.contains(locationOfTouch)) {
                    
                    currentLevel = Int(button.name!)!
                    
                    // switchs to game scene and loads selected level
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
            
        }
        
    }
    
}

