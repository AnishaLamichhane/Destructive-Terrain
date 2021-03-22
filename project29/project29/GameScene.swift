//
//  GameScene.swift
//  project29
//
//  Created by Anisha Lamichhane on 12/27/20.
//

import SpriteKit
import GameplayKit

enum CollisionTypes: UInt32 {
    case banana = 1
    case building = 2
    case player = 4
}
//MARK:- the game view controller needs to manage the user interface and the game scene needs to manage everything inside the game.
//MARK:- we need to give view controller the property of game scene and same to the game scene so that they can communicate with each other.
class GameScene: SKScene, SKPhysicsContactDelegate {
    var buildings = [BuildingNode]()
    weak var viewController: GameViewController?
    var player1: SKSpriteNode!
    var player2: SKSpriteNode!
    var banana: SKSpriteNode!
    var currentPlayer = 1
    
    override func didMove(to view: SKView) {
        backgroundColor = UIColor(hue: 0.669, saturation: 0.99, brightness: 0.67, alpha: 1)
        createBuilding()
        createplayer()
        physicsWorld.contactDelegate = self // inform me of collisions
    }
    
    func createBuilding() {
        
        var currentX: CGFloat = -15
        while currentX < 1024 { // make buildig while not touching edge
            let size = CGSize(width: Int.random(in: 2...4) * 40, height: Int.random(in: 300...600))
            currentX += size.width + 2
            let building = BuildingNode(color: .red, size: size)
            building.position = CGPoint(x: currentX - (size.width/2), y: size.height/2) //SpriteKit positions nodes based on their center, so we need to do a little division of width and height to place these buildings correctly
            building.setup()
            addChild(building)
            buildings.append(building)
            
            
        }
    }
    
    func launch(angle: Int, velocity: Int) {
        let speed = Double(velocity) / 10.0
        let radians = deg2rad(degrees: angle)
        
        if banana != nil {
            banana.removeFromParent()
            banana = nil
        }
        banana = SKSpriteNode(imageNamed: "banana")
        banana.name = "banana"
        banana.physicsBody = SKPhysicsBody(circleOfRadius: banana.size.width/2)
        banana.physicsBody?.categoryBitMask = CollisionTypes.banana.rawValue
        banana.physicsBody?.collisionBitMask = CollisionTypes.building.rawValue | CollisionTypes.player.rawValue
        banana.physicsBody?.contactTestBitMask = CollisionTypes.building.rawValue | CollisionTypes.player.rawValue
        banana.physicsBody?.usesPreciseCollisionDetection = true // only use it for a small body and fast moving object
        addChild(banana)
        
        if currentPlayer == 1 {
            banana.position = CGPoint(x: player1.position.x - 30, y: player1.position.y + 40)
            banana.physicsBody?.angularVelocity = -20
            
            let raiseArm = SKAction.setTexture(SKTexture(imageNamed: "player1Throw"))
            let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
            let pause = SKAction.wait(forDuration: 0.15) // hold on for small amount of time
            let sequence = SKAction.sequence([raiseArm, pause, lowerArm])
            player1.run(sequence)
            
            let impulse = CGVector(dx: cos(radians) * speed, dy: sin(radians) * speed)
            banana.physicsBody?.applyImpulse(impulse)
        }else {
            banana.position = CGPoint(x: player2.position.x - 30, y: player2.position.y + 40)
            banana.physicsBody?.angularVelocity = 20
            
            let raiseArm = SKAction.setTexture(SKTexture(imageNamed: "player2Throw"))
            let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
            let pause = SKAction.wait(forDuration: 0.15) // hold on for small amount of time
            let sequence = SKAction.sequence([raiseArm, pause, lowerArm])
            player2.run(sequence)
            
            let impulse = CGVector(dx: cos(radians) * -speed, dy: sin(radians) * speed)
            banana.physicsBody?.applyImpulse(impulse)
        }
    }
    
    func createplayer() {
        player1 = SKSpriteNode(imageNamed: "player")
        player1.name = "player1"
        player1.physicsBody = SKPhysicsBody(circleOfRadius: player1.size.width/2) // to make them round
        player1.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue // which category this physics body belongs to
        player1.physicsBody?.collisionBitMask = CollisionTypes.banana.rawValue // collide with banana
        player1.physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue //tell me when it hit banana
        player1.physicsBody?.isDynamic = false // dont move by any phhysical factors like gravity or sth
        
        let player1Building = buildings[1]
        player1.position = CGPoint(x: player1Building.position.x, y: player1Building.position.y + (player1Building.size.height + player1.size.height)/2 )
        addChild(player1)
        
        //for player 2
        player2 = SKSpriteNode(imageNamed: "player")
        player2.name = "player2"
        player2.physicsBody = SKPhysicsBody(circleOfRadius: player2.size.width/2) // to make them round
        player2.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue // which category this physics body belongs to
        player2.physicsBody?.collisionBitMask = CollisionTypes.banana.rawValue // collide with banana
        player2.physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue //tell me when it hit banana
        player2.physicsBody?.isDynamic = false // dont move by any phhysical factors like gravity or sth
        
        let player2Building = buildings[buildings.count - 2 ]
        player2.position = CGPoint(x: player2Building.position.x, y: player2Building.position.y + (player2Building.size.height + player2.size.height)/2 )
        addChild(player2)
    }
    
    func deg2rad(degrees: Int) -> Double {
        return Double(degrees) * .pi / 180
    }
    
    func didBegin(_ contact: SKPhysicsContact) { //called when two bodies contact with each other
        let firstBody: SKPhysicsBody
        let secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask { // this is the comparasion between two bodies based on which category do these belong to
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        guard let firstNode = firstBody.node else { return}
        guard let secondNode = secondBody.node else {return}
        
        if firstNode.name == "banana" && secondNode.name == "building" {
            bananaHit(building: secondNode, atPoint: contact.contactPoint) // at point parameter points where the collision actually happened
        }
        else if firstNode.name == "banana" && secondNode.name == "player1"{
            destroy(player: player1)
        }
        else if firstNode.name == "banana" && secondNode.name == "player2"{
            destroy(player: player2)
        }
    }
    
    func destroy(player: SKSpriteNode){
        if let explosion = SKEmitterNode(fileNamed: "hitPlayer") {
            explosion.position = player.position
            addChild(explosion)
        }
        player.removeFromParent()
        banana.removeFromParent()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let newGame = GameScene(size: self.size) // we are using strong self.
            newGame.viewController = self.viewController // the new gameScene points to our viewcontroller &&
            self.viewController?.currentGame = newGame  // viewcontroller points to our newgame scene
            self.changePlayer()
            newGame.currentPlayer = self.currentPlayer
            
            let transition = SKTransition.doorway(withDuration: 1.5)
            self.view?.presentScene(newGame, transition: transition)
        }
    }
    
    func bananaHit(building: SKNode, atPoint contactPoint: CGPoint) {
        guard let building = building as? BuildingNode else {return}
        let buildingLocation = convert(contactPoint, to: building) //asks the game scene to convert the collision contact point into the coordinates relative to the building node
        building.hit(at: buildingLocation)
        
        if let explosion = SKEmitterNode(fileNamed: "hitBuilding"){
            explosion.position = contactPoint
            addChild(explosion)
        }
        banana.name = ""
        banana.removeFromParent()
        banana = nil
        
        changePlayer()
    }
    
    func changePlayer() {
        if currentPlayer == 1 {
            currentPlayer = 2
        } else {
            currentPlayer = 1
        }
        viewController?.activatePlayer(number: currentPlayer) // show the player 1 name or 2 name in our ui kit
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard banana != nil else { return }
        if abs(banana.position.y) > 1000 {
            banana.removeFromParent()
            banana =  nil
            changePlayer()
        }
    }
}
