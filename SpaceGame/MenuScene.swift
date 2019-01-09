//
//  MenuScene.swift
//  SpaceGame
//
//  Created by Nancy Pittman on 1/4/19.
//  Copyright © 2019 Nancy LLC. All rights reserved.
//

import UIKit
import SpriteKit

class MenuScene: SKScene {
	
	var starfield: SKEmitterNode!
	var newGameButtonNode: SKSpriteNode!
	var difficultyLabelNode: SKLabelNode!
	var currentGame: GameScene!
	
	let slider = UISlider(frame: CGRect(x: 57, y: 315, width: 250, height: 5))
	
	override func didMove(to view: SKView) {
		starfield = self.childNode(withName: "starfield") as! SKEmitterNode
		starfield.advanceSimulationTime(10)
		
		newGameButtonNode = self.childNode(withName: "newGameButton") as! SKSpriteNode
		difficultyLabelNode = self.childNode(withName: "difficultyLabel") as! SKLabelNode
		loadSlider()
	}
	
	private func loadSlider() {
		slider.minimumValue = 1
		slider.maximumValue = 10
		slider.isContinuous = true
		slider.addTarget(self, action: #selector(sliderValueDidChange(_:)), for: .valueChanged)
		view?.addSubview(slider)
	}
	
	@objc func sliderValueDidChange(_ sender:UISlider!) {
		changeDifficulty(value: sender.value)
	}
	
	func changeDifficulty(value: Float) {
		difficultyLabelNode.text = String(format: "Speed: %.f", value)
	}
	
	override func willMove(from view: SKView) {
		slider.removeFromSuperview()
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		let touch = touches.first
		
		if let location = touch?.location(in: self) {
			let nodesArray = self.nodes(at: location)
			if nodesArray.first?.name == "newGameButton" {
				let transition = SKTransition.flipHorizontal(withDuration: 0.5)
				let gameScene = GameScene(size: self.size)
				self.view?.presentScene(gameScene, transition: transition)
			}
		}
	}

}
