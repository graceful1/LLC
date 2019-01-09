//
//  GameScene.swift
//  SpaceGame
//
//  Created by Nancy Pittman on 12/20/18.
//  Copyright © 2018 Nancy LLC. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
	
	var starfield: SKEmitterNode!
	var player: SKSpriteNode!
	
	var scoreLabel: SKLabelNode!
	var score: Int = 0 {
		didSet {
			scoreLabel.text = "Score: \(score)"
		}
	}
	
	var gameTimer: Timer!
	var possibleAliens = ["alien", "alien2", "alien3"]
	var alienPossibleScales = [1, 1.5, 2]
	
	let alienCategory: Int32 = 0x1 << 1
	let photonTorepdoCategory: Int32 = 0x1 << 0
	
	weak var menuScene: MenuScene!
	
    override func didMove(to view: SKView) {
		
		starfield = SKEmitterNode(fileNamed: "Starfield")
		starfield.position = CGPoint(x: 430, y: self.frame.maxY)
		starfield.advanceSimulationTime(10)
		self.addChild(starfield)
		
		starfield.zPosition = -1

		self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
		self.physicsWorld.contactDelegate = self
		
		scoreLabel = SKLabelNode(text: "Score: 0")
		scoreLabel.position = CGPoint(x: self.frame.minX + 100, y: self.frame.maxY - 60)
		scoreLabel.fontName = "AmericanTypewriter-Bold"
		scoreLabel.fontSize = 36
		scoreLabel.fontColor = UIColor.white
		score = 0
		
		self.addChild(scoreLabel)
		
		gameTimer = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(addAlien), userInfo: nil, repeats: true)
		
    }
	
	@objc func addAlien() {
		possibleAliens = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleAliens) as! [String]
		alienPossibleScales = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: alienPossibleScales) as! [Double]
		
		let alien = SKSpriteNode(imageNamed: possibleAliens[0])
		let randomAlienXPosition = GKRandomDistribution(lowestValue: Int(self.frame.minX), highestValue: Int(self.frame.maxX))
		let xPosition = CGFloat(randomAlienXPosition.nextInt())

		alien.position = CGPoint(x: xPosition, y: self.frame.maxY)
		alien.setScale(CGFloat(alienPossibleScales[0]))

		alien.physicsBody = SKPhysicsBody(rectangleOf: alien.size)
		alien.physicsBody?.isDynamic = true

		alien.physicsBody?.categoryBitMask = UInt32(alienCategory)
		alien.physicsBody?.contactTestBitMask = UInt32(photonTorepdoCategory)
		alien.physicsBody?.collisionBitMask = 0
		
		self.addChild(alien)
		
		let animationDuration: TimeInterval = 7

		var actionArray = [SKAction]()
		actionArray.append(SKAction.move(to: CGPoint(x: xPosition, y: self.frame.minY), duration: animationDuration))

		actionArray.append(SKAction.removeFromParent())

		alien.run(SKAction.sequence(actionArray))
		
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		for t in touches { self.touchDown(atPoint: t.location(in: self)) }
	}
	
	func touchDown(atPoint: CGPoint) {
		fireTorpedo(atPoint: atPoint)
	}

	
	func fireTorpedo(atPoint: CGPoint) {
		self.run(SKAction.playSoundFileNamed("torpedo.mp3", waitForCompletion: false))
		
		let torpedoNode = SKSpriteNode(imageNamed: "torpedo")
		torpedoNode.position = atPoint
		torpedoNode.position.y += 5
		
		torpedoNode.physicsBody = SKPhysicsBody(circleOfRadius: torpedoNode.size.width / 2)
		torpedoNode.physicsBody?.isDynamic = true
		
		torpedoNode.physicsBody?.categoryBitMask = UInt32(photonTorepdoCategory)
		torpedoNode.physicsBody?.contactTestBitMask = UInt32(alienCategory)
		torpedoNode.physicsBody?.collisionBitMask = 0
		
		torpedoNode.physicsBody?.usesPreciseCollisionDetection = true
		
		self.addChild(torpedoNode)
		
		let animationDuration: TimeInterval = 0.3
		
		var actionArray = [SKAction]()
		actionArray.append(SKAction.move(to: CGPoint(x: torpedoNode.position.x, y: torpedoNode.position.y), duration: animationDuration))
		actionArray.append(SKAction.removeFromParent())
		
		torpedoNode.run(SKAction.sequence(actionArray))
	}
	
	func didBegin(_ contact: SKPhysicsContact) {
		var firstBody: SKPhysicsBody
		var secondBody: SKPhysicsBody
		
		if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
			firstBody = contact.bodyA
			secondBody = contact.bodyB
		} else {
			firstBody = contact.bodyB
			secondBody = contact.bodyA
		}
		
		if (Int32(firstBody.categoryBitMask) & photonTorepdoCategory) != 0 && (Int32(secondBody.categoryBitMask) & alienCategory) != 0 {
			torpedoDidCollideWithAlien(torpedoNode: firstBody.node as! SKSpriteNode, alienNode: secondBody.node as! SKSpriteNode)
		}
	
	}
	
	func torpedoDidCollideWithAlien(torpedoNode: SKSpriteNode, alienNode: SKSpriteNode) {
		let explosion = SKEmitterNode(fileNamed: "Explosion")!
		explosion.position = alienNode.position
		self.addChild(explosion)
		
		self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
		
		torpedoNode.removeFromParent()
		alienNode.removeFromParent()
		
		self.run(SKAction.wait(forDuration: 2)) {
			explosion.removeFromParent()
		}

		updateScore(alienWidth: alienNode.size.width)
		
	}
	
	func updateScore(alienWidth: CGFloat) {
		if alienWidth == 40 {
			score += 10
		} else if alienWidth == 60 {
			score += 5
		} else {
			score += 1
		}
	}
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
