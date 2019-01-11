//
//  ExitScene.swift
//  SpaceGame
//
//  Created by Nancy Pittman on 1/10/19.
//  Copyright © 2019 Nancy LLC. All rights reserved.
//

import UIKit
import SpriteKit

class ExitScene: SKScene {
	
	var score: Int = 0
	var scoreLabel: SKLabelNode!
	var newGameButtonNode: SKSpriteNode!
	
	override func didMove(to view: SKView) {
		scoreLabel = self.childNode(withName: "scoreLabel") as! SKLabelNode
		scoreLabel.text = "\(score)"
	}
	

}
