//
//  GameScene.swift
//  Scatter
//
//  Created by Shanti Mickens on 5/2/19.
//  Copyright © 2019 Shanti Mickens. All rights reserved.
//

/*
 To Do -
    1. add pause menu
    2. display powerup
 */

import SpriteKit
import GameplayKit

//use these to assign physicsBody into categories and then only allow certain physicsBody to interact with other physicsBodies
struct PhysicsCategories {
    //numbers in binary form
    static let None : UInt32 = 0 // keeps objects from colliding
    static let Paddle : UInt32 = 0x1 << 1 //1
    static let Ball : UInt32 = 0x1 << 2 // 2
    static let Block : UInt32 = 0x1 << 3 // 3
    static let Powerup : UInt32 = 0x1 << 4 // 4
    static let Border : UInt32 = 0x1 << 5 // 5
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // game over buttons
    var replayButton : SKShapeNode?
    var nextLevelButton : SKShapeNode?
    var levelSelectButton : SKShapeNode?
    
    // keeps of number of balls in play
    var numBalls = 1
    var balls = [Player(ellipseIn: CGRect(x: 0, y: -500, width: 40, height: 40))]
    
    var paddle = Paddle()
    // true when sticky paddle powerup is gained
    var stickyPaddle = false
    
    var gameArea = CGRect()
    
    // holds coordinates for blocks
    var blockCoordinates = [[CGPoint]]()
    
    // true when game has ended
    var gameover = false
    
    // default level value is 1 right now (later will be selected level from level menu)
    private var level : Level = Level(levelName: "Level_1")
    
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
                
        self.physicsWorld.contactDelegate = self
        
        // creates rectangle, where game will be played
        gameArea = CGRect(x: -(self.size.width/2), y: -(self.size.height/2), width: self.size.width, height: self.size.height)
        
        // adds level name
        let levelLabel = SKLabelNode(text: "Level: \(currentLevel)")
        levelLabel.position = CGPoint(x: gameArea.minX + 50, y: gameArea.maxY - 30)
        levelLabel.fontName = "JosefinSans-SemiBold"
        levelLabel.fontSize = 20
        levelLabel.fontColor = #colorLiteral(red: 0, green: 0.6613205075, blue: 0.6170555353, alpha: 1)
        self.addChild(levelLabel)
        
        let background = SKShapeNode(rect: gameArea)
        background.fillColor = UIColor.white
        background.zPosition = 0
        self.addChild(background)
        
        self.addChild(paddle)
        self.addChild(balls[0])
        
        self.name = "Scene"
        
        // adds the border of the screen to keep the ball on screen
        let path = UIBezierPath()
        path.move(to: CGPoint(x: -self.frame.width/2, y: -self.frame.height/2))
        path.addLine(to: CGPoint(x: -self.frame.width/2, y: self.frame.height/2))
        path.addLine(to: CGPoint(x: self.frame.width/2, y: self.frame.height/2))
        path.addLine(to: CGPoint(x: self.frame.width/2, y: -self.frame.height/2))
        let partialBorder = SKPhysicsBody(edgeChainFrom: path.cgPath)
        partialBorder.restitution = 1.0
        partialBorder.friction = 0.0
        partialBorder.linearDamping = 0.0
        partialBorder.categoryBitMask = PhysicsCategories.Border
        partialBorder.collisionBitMask = PhysicsCategories.Ball | PhysicsCategories.Paddle
        partialBorder.contactTestBitMask = PhysicsCategories.None
        self.physicsBody = partialBorder
        
        // adds bottom
        let bottom = SKShapeNode(rect: CGRect(x: -self.frame.width/2, y: 0, width: self.frame.width*2, height: 5))
        bottom.name = "Bottom"
        bottom.position = CGPoint(x: 0, y: gameArea.minY - 40)
        bottom.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width*2, height: 5))
        bottom.physicsBody?.affectedByGravity = false
        bottom.physicsBody?.categoryBitMask = PhysicsCategories.Border
        bottom.physicsBody?.collisionBitMask = PhysicsCategories.None
        bottom.physicsBody?.contactTestBitMask = PhysicsCategories.Ball
        self.addChild(bottom)
        
        // sets ball in motion
        balls[0].physicsBody?.velocity = self.physicsBody!.velocity
        let minAngle = 20;
        let maxAngle = 160;
        let degrees = arc4random_uniform(UInt32(maxAngle-minAngle)) + UInt32(minAngle)
        let radians = CGFloat(degrees) * CGFloat.pi / 180.0
        balls[0].physicsBody!.applyImpulse(CGVector(dx: 8*cos(radians), dy: 8*sin(radians)))
        
        // TEMPORARY: shows outline of physics bodies to help with debugging
        //view.showsPhysics = true
        
        level = Level(levelName: "Level_\(currentLevel)")
        let blocks = level.getBlocksArray()
        setupBlockCoordinates(blocks)
        setupBlocks(blocks)
        
        gameover = false
        
    }
        
    func didBegin(_ contact: SKPhysicsContact) {
        var nodeA = contact.bodyA.node
        var nodeB = contact.bodyB.node
        
        if (nodeA?.name != "Ball") {
            // swaps a and b, so that a is always the ball
            let tempNode = nodeB
            nodeB = nodeA
            nodeA = tempNode
        }
        
        if (nodeA?.name == "Ball" && nodeB?.name == "Bottom") {
            // if ball hits bottom, then it is removed
            //print("ball removed")
            balls.remove(at: balls.firstIndex(of: nodeA as! Player)!)
            nodeA?.removeFromParent()
            numBalls -= 1
        }
        
        if (nodeA?.name == "Ball" && nodeB?.name == "Paddle") {
            if (stickyPaddle) {
                //print("stick")
                let ballNode = nodeA as! Player
                ballNode.stick()
            }
        }
        
        if (nodeA?.name == "Ball" && nodeB?.name == "Square") {
            guard let block : Square = nodeB as? Square else { return }
            let powerup : Powerup? = block.onHit()
            if (powerup != nil) {
                self.addChild(powerup!)
                powerup?.fall()
            }
        }
        
        if (nodeA?.name == "Ball" && nodeB?.name == "Triangle") {
            guard let triangle : Triangle = nodeB as? Triangle else { return }
            // lowers blocks strength by 1 on each hit
            let powerup : Powerup? = triangle.onHit()
            if (powerup != nil) {
                self.addChild(powerup!)
                powerup?.fall()
            }
        }
        
        if (nodeA?.name == "Ball" && nodeB?.name == "Right Triangle") {
            guard let triangle : RightTriangle = nodeB as? RightTriangle else { return }
            // lowers blocks strength by 1 on each hi
            let powerup : Powerup? = triangle.onHit()
            if (powerup != nil) {
                self.addChild(powerup!)
                powerup?.fall()
            }
        }
        
        if (nodeA?.name == "Ball" && nodeB?.name == "Powerup") {
            //print("Ball hit powerup!")
            let powerup : Powerup = nodeB as! Powerup
            if (balls.count > 0) {
                AddPowerup(type: powerup.getType(), ballNode: nodeA as? Player)
            }
            nodeB?.removeFromParent()
        }
        
        if (nodeA?.name == "Paddle" && nodeB?.name == "Powerup") {
            //print("Paddle hit powerup!")
            let powerup : Powerup = nodeB as! Powerup
            if (balls.count > 0) {
                AddPowerup(type: powerup.getType(), ballNode: balls[0])
            }
            nodeB?.removeFromParent()
        }
        
        if (nodeA?.name == "Powerup" && nodeB?.name == "Paddle") {
            //print("Paddle hit powerup!")
            let powerup : Powerup = nodeA as! Powerup
            if (balls.count > 0) {
                AddPowerup(type: powerup.getType(), ballNode: balls[0])
            }
            nodeA?.removeFromParent()
        }
        
    }
    
    func AddPowerup(type: String, ballNode: Player?) {
        self.removeAllActions()
        if (type == "Good") {
            // randomly picks between big paddle, slows down, ball bigger, sticky paddle, extra ball
            switch (round(random(min: 1, max: 5))) {
                case 1: // big paddle
                    //print("big paddle")
                    let grow = SKAction.run {
                        self.paddle.changeSize(size: 105.0)
                    }
                    let delay = SKAction.wait(forDuration: 5)
                    let reset = SKAction.run {
                        self.paddle.changeSize(size: 85.0)
                    }
                    let growAndReset = SKAction.sequence([grow, delay, reset])
                    self.run(growAndReset)
                case 2: // slows down
                    //print("slows down")
                    ballNode?.changeSpeed(factor: 0.75)
                case 3: // ball bigger
                    //print("ball grows")
                    let grow = SKAction.run {
                        ballNode?.changeSize(size: 25.0)
                    }
                    let delay = SKAction.wait(forDuration: 5)
                    let reset = SKAction.run {
                        ballNode?.changeSize(size: 20.0)
                    }
                    let growAndReset = SKAction.sequence([grow, delay, reset])
                    self.run(growAndReset)
                case 4: // sticky paddle
                    //print("sticky paddle")
                    self.stickyPaddle = true
                case 5: // extra ball
                    //print("extra ball")
                    let extraBall = Player(ellipseIn: CGRect(x: paddle.position.x, y: -500, width: 40, height: 40))
                    extraBall.name = "Ball"
                    self.addChild(extraBall)
                    
                    balls.append(extraBall)
                    
                    // sets ball in motion
                    extraBall.physicsBody?.velocity = self.physicsBody!.velocity
                    let minAngle = 10;
                    let maxAngle = 170;
                    let degrees = arc4random_uniform(UInt32(maxAngle-minAngle)) + UInt32(minAngle)
                    let radians = CGFloat(degrees) * CGFloat.pi / 180.0
                    extraBall.physicsBody!.applyImpulse(CGVector(dx: 8*cos(radians), dy: 8*sin(radians)))
                
                    numBalls += 1
                default:
                    break;
            }
        } else if (type == "Bad"){
            // randomly picks between small paddle, speed up, ball smaller
            switch (round(random(min: 1, max: 3))) {
                case 1: // small paddle
                    //print("small paddle")
                    let grow = SKAction.run {
                        self.paddle.changeSize(size: 65.0)
                    }
                    let delay = SKAction.wait(forDuration: 5)
                    let reset = SKAction.run {
                        self.paddle.changeSize(size: 85.0)
                    }
                    let growAndReset = SKAction.sequence([grow, delay, reset])
                    self.run(growAndReset)
                case 2: // speed up
                    //print("speed up")
                    ballNode?.changeSpeed(factor: 1.25)
                case 3: // ball smaller
                    //print("ball shrinks")
                    let grow = SKAction.run {
                        ballNode?.changeSize(size: 15.0)
                    }
                    let delay = SKAction.wait(forDuration: 5)
                    let reset = SKAction.run {
                        ballNode?.changeSize(size: 20.0)
                    }
                    let growAndReset = SKAction.sequence([grow, delay, reset])
                    self.run(growAndReset)
                default:
                    break
            }
        }
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
    
    func setupBlockCoordinates(_ blocks: [[Int]]) {
        for i in 0..<blocks.count {
            var rowArray = [CGPoint]()
            for j in 0..<blocks[i].count {
                // takes size of block + 10 and multiplies it get the coordinates position
                let xPos = CGFloat(48.0 + 7.0) * CGFloat(j-3)
                let yPos = -CGFloat(48.0 + 7.0) * CGFloat(i-3) + 200.0
                rowArray.append(CGPoint(x: xPos, y: yPos))
            }
            blockCoordinates.append(rowArray)
        }
    }
    
    // looks at value at blocks[i][j] and checks the first character for the block type, second for its strength, and the third for its direction then it adds that block at the corresponding coordinates
    func setupBlocks(_ blocks: [[Int]]) {
        for i in 0..<blocks.count {
            for j in 0..<blocks[i].count {
                //print(blocks[i][j])
                let firstNum = Array(String(blocks[i][j]))[0]
                var secondNum : Character = "0"
                var thirdNum : Character = "0"
                if (blocks[i][j] > 9) {
                    secondNum = Array(String(blocks[i][j]))[1]
                }
                if (blocks[i][j] > 99) {
                    thirdNum = Array(String(blocks[i][j]))[2]
                }
                                
                switch(Int(String(firstNum))!) {
                    case 0: // no block
                        break
                    case 1: // square block
                        AddBlock(x: blockCoordinates[i][j].x, y: blockCoordinates[i][j].y, index: Int(String(secondNum))!)
                            //print(Int(String(secondNum))!)
                        break
                    case 2: // equilateral triangle
                        switch(Int(String(thirdNum))!) {
                            case 1: // up
                                if (j < 3) {
                                    AddTriangleBlock(x: blockCoordinates[i][j].x + CGFloat(16*abs(j-3)), y: blockCoordinates[i][j].y, index: Int(String(secondNum))!, dir: "Up")
                                } else if (j > 3) {
                                    AddTriangleBlock(x: blockCoordinates[i][j].x - CGFloat(16*abs(j-3)), y: blockCoordinates[i][j].y, index: Int(String(secondNum))!, dir: "Up")
                                } else {
                                    AddTriangleBlock(x: blockCoordinates[i][j].x, y: blockCoordinates[i][j].y, index: Int(String(secondNum))!, dir: "Up")
                                }
                                break
                            case 2: // down
                                if (j < 3) {
                                    AddTriangleBlock(x: blockCoordinates[i][j].x + CGFloat(16*abs(j-3)), y: blockCoordinates[i][j].y, index: Int(String(secondNum))!, dir: "Down")
                                } else if (j > 3) {
                                    AddTriangleBlock(x: blockCoordinates[i][j].x - CGFloat(16*abs(j-3)), y: blockCoordinates[i][j].y, index: Int(String(secondNum))!, dir: "Down")
                                } else {
                                    AddTriangleBlock(x: blockCoordinates[i][j].x, y: blockCoordinates[i][j].y, index: Int(String(secondNum))!, dir: "Down")
                                }
                                break
                            default:
                                print("error")
                        }
                        break
                    case 3: // right triangle
                        switch(Int(String(thirdNum))!) {
                            case 1: // top left
                                AddRightTriangleBlock(x: blockCoordinates[i][j].x, y: blockCoordinates[i][j].y, index: Int(String(secondNum))!, dir: "Top Left")
                                break
                            case 2: // top right
                                AddRightTriangleBlock(x: blockCoordinates[i][j].x, y: blockCoordinates[i][j].y, index: Int(String(secondNum))!, dir: "Top Right")
                                break
                            case 3: // bottom left
                                AddRightTriangleBlock(x: blockCoordinates[i][j].x, y: blockCoordinates[i][j].y, index: Int(String(secondNum))!, dir: "Bottom Left")
                                break
                            case 4: // bottom right
                                AddRightTriangleBlock(x: blockCoordinates[i][j].x, y: blockCoordinates[i][j].y, index: Int(String(secondNum))!, dir: "Bottom Right")
                                break
                            default:
                                print("error")
                        }
                        break
                    default:
                        print("error")
                }
            }
        }
    }
    
    // Called before each frame is rendered
    override func update(_ currentTime: TimeInterval) {
        
        if (!(gameover)) {
            // if all the balls are gone, then the game is over and it brings up the game over screen
            if (numBalls == 0) {
                // gameover
                gameover = true
                
                // stops the ball
                for ball in balls {
                    ball.physicsBody?.velocity.dx = 0
                    ball.physicsBody?.velocity.dy = 0
                }
                
                // fades everything in background
                for child in self.children {
                    if child is Block {
                        child.alpha = 0.5
                    }
                    if child.name == "Player" || child.name == "Paddle" {
                        child.alpha = 0.5
                    }
                    
                    // stops any powerups
                    if child.name == "Powerup" {
                        child.removeAllActions()
                    }
                }
                
                // displays title label
                let title = SKLabelNode(text: "Gameover!")
                title.fontName = "Mansalva-Regular"
                title.fontSize = 75
                title.fontColor = #colorLiteral(red: 0, green: 0.6613205075, blue: 0.6170555353, alpha: 1)
                title.position = CGPoint(x: 0.0, y: 250.0)
                title.zPosition = 5
                self.addChild(title)
                
                let fadeIn = SKAction.fadeIn(withDuration: 1.0)
                
                let buttonWidth = 200.0
                let buttonHeight = 60.0
                
                self.replayButton = SKShapeNode(rect: CGRect(x: -buttonWidth/2, y: 00.0, width: buttonWidth, height: buttonHeight), cornerRadius: 15.0)
                self.replayButton?.fillColor = #colorLiteral(red: 0.5111412406, green: 0.7958028913, blue: 0.7701452374, alpha: 1)
                self.replayButton?.lineWidth = 0
                self.replayButton?.alpha = 0.0
                self.replayButton?.zPosition = 2
                self.replayButton?.run(fadeIn)
                self.addChild(self.replayButton!)
                
                let replayLabel = SKLabelNode(text: "Replay")
                replayLabel.position = CGPoint(x: 0.0, y: buttonHeight/4)
                replayLabel.fontName = "JosefinSans-SemiBold"
                replayLabel.fontColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                replayLabel.fontSize = 35.0
                replayLabel.alpha = 0.0
                replayLabel.zPosition = 3
                replayLabel.run(fadeIn)
                self.addChild(replayLabel)
                
                self.levelSelectButton = SKShapeNode(rect: CGRect(x: -buttonWidth/2, y: -75.0, width: buttonWidth, height: buttonHeight), cornerRadius: 15.0)
                self.levelSelectButton?.fillColor = #colorLiteral(red: 0.5111412406, green: 0.7958028913, blue: 0.7701452374, alpha: 1)
                self.levelSelectButton?.lineWidth = 0
                self.levelSelectButton?.alpha = 0.0
                self.levelSelectButton?.zPosition = 2
                self.levelSelectButton?.run(fadeIn)
                self.addChild(self.levelSelectButton!)
                
                let levelSelectLabel = SKLabelNode(text: "Levels")
                levelSelectLabel.position = CGPoint(x: 0.0, y: -75.0+buttonHeight/4)
                levelSelectLabel.fontName = "JosefinSans-SemiBold"
                levelSelectLabel.fontColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                levelSelectLabel.fontSize = 35.0
                levelSelectLabel.alpha = 0.0
                levelSelectLabel.zPosition = 3
                levelSelectLabel.run(fadeIn)
                self.addChild(levelSelectLabel)
            }
            
            // makes sure balls don't go straight up/down or left/right
            for ball in balls {
                if !(ball.stuck) {
                    if (abs((ball.physicsBody?.velocity.dx)!) < 20) {
                        if (round(random(min: 0, max: 1)) == 0) {
                            ball.physicsBody?.velocity.dx += 20
                        } else {
                            ball.physicsBody?.velocity.dx += -20
                        }
                    } else if (abs((ball.physicsBody?.velocity.dx)!) < 40) {
                        if (round(random(min: 0, max: 1)) == 0) {
                            ball.physicsBody?.velocity.dx += 30
                        } else {
                            ball.physicsBody?.velocity.dx += -30
                        }
                    }
                    if (abs((ball.physicsBody?.velocity.dy)!) < 20) {
                        if (round(random(min: 0, max: 1)) == 0) {
                            ball.physicsBody?.velocity.dy += 20
                        } else {
                            ball.physicsBody?.velocity.dy += -20
                        }
                    } else if (abs((ball.physicsBody?.velocity.dy)!) < 40) {
                        if (round(random(min: 0, max: 1)) == 0) {
                            ball.physicsBody?.velocity.dy += 30
                        } else {
                            ball.physicsBody?.velocity.dy += -30
                        }
                    }
                }
            }
            
            var win = true
            for child in self.children {
                // if there are still blocks left, then the player hasn't won yet
                if child is Block {
                    win = false
                    return
                }
            }
            // if all the blocks are gone, then the player has won and it brings up the menu
            if (win) {
                // player won
                gameover = true
                
                // stops the ball
                for ball in balls {
                    ball.physicsBody?.velocity.dx = 0
                    ball.physicsBody?.velocity.dy = 0
                }
                
                // fades everything in background
                for child in self.children {
                    if child is Block {
                        child.alpha = 0.5
                    }
                    if child.name == "Player" || child.name == "Paddle" {
                        child.alpha = 0.5
                    }
                    
                    // stops any powerups
                    if child.name == "Powerup" {
                        child.removeAllActions()
                    }
                }
                
                // displays title label
                let title = SKLabelNode(text: "You Won!")
                title.fontName = "Mansalva-Regular"
                title.fontSize = 75
                title.fontColor = #colorLiteral(red: 0, green: 0.6613205075, blue: 0.6170555353, alpha: 1)
                title.position = CGPoint(x: 0.0, y: 250.0)
                title.zPosition = 5
                self.addChild(title)
                
                // sets user defaults variable unlocked for the next level to true
                defaults.set(true, forKey: "unlocked_\(currentLevel+1)")
                
                let fadeIn = SKAction.fadeIn(withDuration: 1.0)
                
                let buttonWidth = 200.0
                let buttonHeight = 60.0
                
                self.nextLevelButton = SKShapeNode(rect: CGRect(x: -buttonWidth/2, y: 50.0, width: buttonWidth, height: buttonHeight), cornerRadius: 15.0)
                self.nextLevelButton?.fillColor = #colorLiteral(red: 0.5111412406, green: 0.7958028913, blue: 0.7701452374, alpha: 1)
                self.nextLevelButton?.lineWidth = 0
                self.nextLevelButton?.alpha = 0.0
                self.nextLevelButton?.zPosition = 2
                self.nextLevelButton?.run(fadeIn)
                self.addChild(self.nextLevelButton!)
                
                let nextLevelLabel = SKLabelNode(text: "Next")
                nextLevelLabel.position = CGPoint(x: 0.0, y: 50.0+buttonHeight/4)
                nextLevelLabel.fontName = "JosefinSans-SemiBold"
                nextLevelLabel.fontColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                nextLevelLabel.fontSize = 35.0
                nextLevelLabel.alpha = 0.0
                nextLevelLabel.zPosition = 3
                nextLevelLabel.run(fadeIn)
                self.addChild(nextLevelLabel)
                
                self.replayButton = SKShapeNode(rect: CGRect(x: -buttonWidth/2, y: -25.0, width: buttonWidth, height: buttonHeight), cornerRadius: 15.0)
                self.replayButton?.fillColor = #colorLiteral(red: 0.5111412406, green: 0.7958028913, blue: 0.7701452374, alpha: 1)
                self.replayButton?.lineWidth = 0
                self.replayButton?.alpha = 0.0
                self.replayButton?.zPosition = 2
                self.replayButton?.run(fadeIn)
                self.addChild(self.replayButton!)
                
                let replayLabel = SKLabelNode(text: "Replay")
                replayLabel.position = CGPoint(x: 0.0, y: -25.0+buttonHeight/4)
                replayLabel.fontName = "JosefinSans-SemiBold"
                replayLabel.fontColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                replayLabel.fontSize = 35.0
                replayLabel.alpha = 0.0
                replayLabel.zPosition = 3
                replayLabel.run(fadeIn)
                self.addChild(replayLabel)
                
                self.levelSelectButton = SKShapeNode(rect: CGRect(x: -buttonWidth/2, y: -100.0, width: buttonWidth, height: buttonHeight), cornerRadius: 15.0)
                self.levelSelectButton?.fillColor = #colorLiteral(red: 0.5111412406, green: 0.7958028913, blue: 0.7701452374, alpha: 1)
                self.levelSelectButton?.lineWidth = 0
                self.levelSelectButton?.alpha = 0.0
                self.levelSelectButton?.zPosition = 2
                self.levelSelectButton?.run(fadeIn)
                self.addChild(self.levelSelectButton!)
                
                let levelSelectLabel = SKLabelNode(text: "Levels")
                levelSelectLabel.position = CGPoint(x: 0.0, y: -100.0+buttonHeight/4)
                levelSelectLabel.fontName = "JosefinSans-SemiBold"
                levelSelectLabel.fontColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                levelSelectLabel.fontSize = 35.0
                levelSelectLabel.alpha = 0.0
                levelSelectLabel.zPosition = 3
                levelSelectLabel.run(fadeIn)
                self.addChild(levelSelectLabel)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if (gameover) {
            for touch in touches {
                
                let locationOfTouch = touch.location(in: self)
                
                if (replayButton != nil) {
                    if ((replayButton?.contains(locationOfTouch))!) {
                        // when replay button is pressed it restarts the game scene
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
                
                if (nextLevelButton != nil) {
                    if ((nextLevelButton?.contains(locationOfTouch))!) {
                        // when next level button is pressed it increments the current level variable and restarts the game scene
                        currentLevel += 1
                        
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
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if (numBalls > 0) {
            for ball in balls {
                if (ball.stuck) {
                    print("unstick")
                    ball.unstick()
                    self.stickyPaddle = false
                }
            }
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if (numBalls > 0 && !(gameover)) {
            for touch in touches {
                
                // starting point of touch
                let startOfTouch = touch.previousLocation(in: self)
                // ending point of touch
                let endOfTouch = touch.location(in: self)
                
                // calculates distance finger moved
                var amountMoved = endOfTouch.x - startOfTouch.x
                
                paddle.position.x += amountMoved
                
                if paddle.position.x > gameArea.maxX - paddle.paddleWidth/2 {
                    amountMoved -= (gameArea.maxX - paddle.paddleWidth/2) - paddle.position.x
                    paddle.position.x = gameArea.maxX - paddle.paddleWidth/2
                } else if paddle.position.x < gameArea.minX + paddle.paddleWidth/2 {
                    amountMoved += (gameArea.minX + paddle.paddleWidth/2) - paddle.position.x
                    paddle.position.x = gameArea.minX + paddle.paddleWidth/2
                }
                
                for ball in balls {
                    if (ball.stuck) {
                        ball.position.x += amountMoved
                    }
                }
                
            }
        }
        
    }
    
}


