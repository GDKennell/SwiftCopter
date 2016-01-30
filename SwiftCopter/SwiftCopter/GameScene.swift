//
//  GameScene.swift
//  SwiftCopter
//
//  Created by Grant Kennell on 1/30/16.
//  Copyright (c) 2016 Grant Kennell. All rights reserved.
//

import SpriteKit

let kGasPedalActionKey = "GasPedalActionKey"

let GAME_SCALE: CGFloat = 0.4

let GAME_GRAVITY: CGFloat = -1

let HELICOPTER_FORCE: CGFloat = 700;

struct PhysicsCategory {
  static let None      : UInt32 = 0
  static let All       : UInt32 = UInt32.max
  static let Enemy     : UInt32 = 0b1       // 1
  static let Projectile: UInt32 = 0b10      // 2
  static let Helicopter: UInt32 = 0b100     // 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {

  let helicopter = SKSpriteNode(imageNamed: "Helicopter blade up")

  override func didMoveToView(view: SKView) {
    setup()
    addHelicopter()
    addBird()
  }

  func setup() {
    backgroundColor = SKColor.whiteColor()

    physicsWorld.gravity = CGVectorMake(0, GAME_GRAVITY)
    physicsWorld.contactDelegate = self
  }

  func addHelicopter() {
    helicopter.physicsBody = SKPhysicsBody(rectangleOfSize: helicopter.size)
    helicopter.physicsBody?.dynamic = true
    helicopter.physicsBody?.categoryBitMask = PhysicsCategory.Helicopter
    helicopter.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile & PhysicsCategory.Helicopter
    helicopter.physicsBody?.collisionBitMask = PhysicsCategory.None

    helicopter.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
    helicopter.size = helicopter.size * GAME_SCALE
    addChild(helicopter)
    addBird()
  }

  func addBird() {
    let bird = SKSpriteNode(imageNamed: "bird 2")
    bird.size = bird.size * GAME_SCALE

    let birdY = random(min: bird.size.height/2, max: size.height - (bird.size.height - bird.size.height/2))
    bird.position = CGPoint(x: size.width + bird.size.width/2, y: birdY)

    bird.physicsBody = SKPhysicsBody(rectangleOfSize: bird.size)
    bird.physicsBody?.dynamic = true
    bird.physicsBody?.categoryBitMask = PhysicsCategory.Enemy
    bird.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile & PhysicsCategory.Helicopter
    bird.physicsBody?.collisionBitMask = PhysicsCategory.None

    addChild(bird)

    let randDuration = random(min: CGFloat(2.0), max: CGFloat(3.0))
    let actionMove = SKAction.moveTo(CGPoint(x: -bird.size.width/2, y: birdY), duration: NSTimeInterval(randDuration))
    let actionMoveDone = SKAction.removeFromParent()
    bird.runAction(SKAction.sequence([actionMove, actionMoveDone]))
    
  }

  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    guard let touchLocation = touches.first?.locationInNode(self) else {
      return
    }

    if (touchLocation.x < 0.3 * size.width) {
      startGasPedal();
    }
  }

  override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    guard let touchLocation = touches.first?.locationInNode(self) else {
      return
    }

    if (touchLocation.x < 0.3 * size.width) {
      stopGasPedal();
    }
    else {
      let isTargetedBullet =  false
      if (isTargetedBullet) {
        let direction = touchLocation - helicopter.position;
        launchMissile(direction.normalized());
      }
      else {
        launchMissile(CGPointMake(1, 0));
      }
    }

  }

  func startGasPedal() {
    if (helicopter.position.y < 0 || helicopter.position.y > size.height) {
      helicopter.position.y = size.height / 2;
    }
    let gasRepeatInterval:NSTimeInterval = 1;

    let impulseAction = SKAction.applyForce(CGVectorMake(0, HELICOPTER_FORCE), duration: gasRepeatInterval);
    helicopter.runAction(SKAction.repeatActionForever(impulseAction), withKey: kGasPedalActionKey)
  }

  func stopGasPedal() {
    helicopter.removeActionForKey(kGasPedalActionKey)
  }

  func launchMissile(direction: CGPoint) {
    let projectile = SKSpriteNode(imageNamed: "Missile 2")
    projectile.position = helicopter.position
    projectile.size = projectile.size * GAME_SCALE

    projectile.physicsBody = SKPhysicsBody(rectangleOfSize: projectile.size)
    projectile.physicsBody?.dynamic = true
    projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
    projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy
    projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
    projectile.physicsBody?.usesPreciseCollisionDetection = true

    addChild(projectile)

    let shootAmount = direction * 1000
    let realDest = shootAmount + projectile.position

    let actionMove = SKAction.moveTo(realDest, duration: 2.0)
    let actionMoveDone = SKAction.removeFromParent()
    projectile.runAction(SKAction.sequence([actionMove, actionMoveDone]))
  }

  func didBeginContact(contact: SKPhysicsContact) {
    var firstBody: SKPhysicsBody
    var secondBody: SKPhysicsBody
    if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
      firstBody = contact.bodyA
      secondBody = contact.bodyB
    } else {
      firstBody = contact.bodyB
      secondBody = contact.bodyA
    }

    if ((firstBody.categoryBitMask & PhysicsCategory.Enemy != 0) &&
      (secondBody.categoryBitMask & PhysicsCategory.Projectile != 0)) {
        projectileDidCollideWithMonster(firstBody.node as! SKSpriteNode, monster: secondBody.node as! SKSpriteNode)
    }
  }


  func projectileDidCollideWithMonster(projectile:SKSpriteNode, monster:SKSpriteNode) {
    print("Hit")
    projectile.removeFromParent()
    monster.removeFromParent()
  }

}

