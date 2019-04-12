//
//  GameScene.swift
//  Day66
//
//  Created by kirsty darbyshire on 11/04/2019.
//  Copyright © 2019 Loquax. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var balloonColours = ["pink", "yellow", "white"]
    var possibleBitMasks = [2,4,8,16,32,64]
    var balloons = [SKSpriteNode]()
    var window: SKSpriteNode!

    var scoreLabel: SKLabelNode!
    var timerLabel: SKLabelNode!
    var playAgainLabel: SKLabelNode!
    
    var gameTimer: Timer?
    var clockTimer: Timer?
    
    var gameOver = false
    
    var score = 0 {
        didSet {
            scoreLabel.text = "\(score)"
        }
    }
    
    var timeLeft = 0 {
        didSet {
            timerLabel.text = "\(timeLeft)"
        }
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = .cyan
        
        window = SKSpriteNode(imageNamed: "window-room")
        window.position = CGPoint(x: 512, y: 384)
        window.name = "window"
        window.zPosition = 80
        addChild(window)
        
        let outsideView = SKSpriteNode(imageNamed: "view1")
        outsideView.position = CGPoint(x: 512, y: 384)
        outsideView.zPosition = -1
        addChild(outsideView)
        
        let scoreFrame = SKSpriteNode(imageNamed: "blackboard")
        scoreFrame.position = CGPoint(x: 950, y: 125)
        scoreFrame.zPosition = 90
        addChild(scoreFrame)
        
        let clockFrame = SKSpriteNode(imageNamed: "clock")
        clockFrame.position = CGPoint(x: 50, y: 625)
        clockFrame.zPosition = 90
        addChild(clockFrame)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: 950, y: 200)
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.verticalAlignmentMode = .center
        scoreLabel.zPosition = 91
        addChild(scoreLabel)
        
        timerLabel = SKLabelNode(fontNamed: "Futura")
        timerLabel.fontColor = .black
        timerLabel.position = CGPoint(x: 50, y: 600)
        timerLabel.horizontalAlignmentMode = .center
        timerLabel.verticalAlignmentMode = .center
        timerLabel.zPosition = 91
        addChild(timerLabel)
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        startGame()
    }
    
    func startGame() {
        
        gameOver = false
        
        score = 0
        timeLeft = 60
        
        gameTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(createBalloon), userInfo: nil, repeats: true)
        
        clockTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countdown), userInfo: nil, repeats: true)
        
    }
    
    @objc func countdown() {
        if timeLeft > 0 {
            timeLeft -= 1
        } else {
            gameOver = true
            gameTimer?.invalidate()
            clockTimer?.invalidate()
            playAgain()
        }
    }
    
    @objc func createBalloon() {
        guard let randomColour = balloonColours.randomElement() else { return }
        let balloon = SKSpriteNode(imageNamed: "balloon-\(randomColour)")
        balloon.physicsBody = SKPhysicsBody(texture: balloon.texture!, size: balloon.size)
        
        balloon.position = CGPoint(x: Int.random(in: 200...824), y: 0)
        balloon.physicsBody?.velocity = CGVector(dx: Int.random(in: -100...100), dy: Int.random(in:50...500))
        balloon.physicsBody?.restitution = 0.05
        
        let balloonBitMask = possibleBitMasks.randomElement()!
        balloon.physicsBody?.collisionBitMask = UInt32(balloonBitMask)
        balloon.physicsBody?.categoryBitMask = UInt32(balloonBitMask)
        balloon.zPosition = CGFloat(balloonBitMask)

        balloon.name = randomColour
        
        balloons.append(balloon)
        addChild(balloon)
    }
    

    
    override func update(_ currentTime: TimeInterval) {
        // remove whatever has gone off screen
        for node in children {
            if node.position.x < -300 || node.position.x > 1400
                || node.position.y < -300 || node.position.y > 800 {
                node.removeFromParent()
            }
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        for node in tappedNodes {
            if let nodeName = node.name {
                if balloonColours.contains(nodeName) && !gameOver {
                    if let pop = SKEmitterNode(fileNamed: "pop") {
                        pop.position = node.position
                        
                        switch nodeName {
                        case "pink":
                            pop.particleColor = .purple
                        case "yellow":
                            pop.particleColor = .yellow
                        default:
                            pop.particleColor = .white
                        }
                        
                        addChild(pop)
                        run(SKAction.playSoundFileNamed("pop.mp3", waitForCompletion: false))
                        
                        // get rid of emitter node when it's finished
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            pop.removeFromParent()
                        }
                    }
                    node.removeFromParent()
                    score += 5
                }
                if nodeName == "playagain" && gameOver {
                    playAgainLabel.text = ""
                    startGame()
                }

            }
            
        }
    }
    
    func playAgain() {
        playAgainLabel = SKLabelNode(text: "Your score was \(score). \n Tap to play again!")
        playAgainLabel.fontColor = .white
        playAgainLabel.position = CGPoint(x: 512, y: 400)
        playAgainLabel.horizontalAlignmentMode = .center
        playAgainLabel.verticalAlignmentMode = .center
        playAgainLabel.zPosition = 110
        playAgainLabel.name = "playagain"
        addChild(playAgainLabel)
    }
    
}
