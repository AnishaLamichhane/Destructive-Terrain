//
//  GameViewController.swift
//  project29
//
//  Created by Anisha Lamichhane on 12/27/20.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    var currentGame: GameScene?
    
    @IBOutlet var angleLabel: UILabel!
    @IBOutlet var angleSlider: UISlider!
    @IBOutlet var velocitySlider: UISlider!
    @IBOutlet var velocityLabel: UILabel!
    @IBOutlet var playerNumber: UILabel!
    @IBOutlet var launchButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
                
       //         MARK:- from here we have our code for game scene
                currentGame = scene as? GameScene
                currentGame?.viewController = self
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
        angleChanged(self)
        velocityChanged(self)
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func angleChanged(_ sender: Any) {
        angleLabel.text = "Angle:\(Int(angleSlider.value))°"
    }
    
    @IBAction func velocityChanged(_ sender: Any) {
        velocityLabel.text = "Velocity:\(Int(velocitySlider.value))"
    }
    
    @IBAction func launch(_ sender: UIButton) {
        angleSlider.isHidden = true
        angleLabel.isHidden = true
        
        velocityLabel.isHidden = true
        velocitySlider.isHidden = true
        launchButton.isHidden = true
        
        currentGame?.launch(angle: Int(angleSlider.value), velocity: Int(velocitySlider.value))
        
    }
    
    func activatePlayer(number: Int) {
        if number == 1 {
            playerNumber.text = "<<<PLAYER ONE"
        }else {
            playerNumber.text = "PLAYER TWO>>>"
        }
        angleSlider.isHidden = false
        angleLabel.isHidden = false
        
        velocityLabel.isHidden = false
        velocitySlider.isHidden = false
        launchButton.isHidden = false
    }
    
}
