//
//  GameScene.swift
//  SwiftCopter
//
//  Created by Grant Kennell on 1/30/16.
//  Copyright (c) 2016 Grant Kennell. All rights reserved.
//

import SpriteKit

let kHelicopterAnimationKey = "HelicopterAnimation"
let kGasPedalActionKey = "GasPedalActionKey"

let GAME_SCALE: CGFloat = 0.4

let GAME_GRAVITY: CGFloat = -1

let HELICOPTER_FORCE: CGFloat = 70;

let HELI_ANIMATION_TIME_SLOW: NSTimeInterval = 0.2;
let HELI_ANIMATION_TIME_FAST: NSTimeInterval = 0.08;

let EXPLOSION_TIME: NSTimeInterval = 0.02

let BIRD_ANIMATION_TIME: NSTimeInterval = 0.2

let ENEMY_REPEAT_TIME: NSTimeInterval = 2

let BACKGROUND_SCROLL_SPEED: NSTimeInterval = 4;

let INTRO_TIME: NSTimeInterval = 10

struct PhysicsCategory {
  static let None      : UInt32 = 0
  static let All       : UInt32 = UInt32.max
  static let Enemy     : UInt32 = 0b1       // 1
  static let Projectile: UInt32 = 0b10      // 2
  static let Helicopter: UInt32 = 0b100     // 4
  static let ScreenEdge: UInt32 = 0b1000    // 8
}

class GameScene: SKScene, SKPhysicsContactDelegate {

  let helicopter = SKSpriteNode(imageNamed: "Helicopter blade up")
  var enemyGenerationTimer:NSTimer? = nil

  override func didMoveToView(view: SKView) {
    setup()
    addHelicopter()

    self.performSelector("beginEnemyGeneration", withObject: nil, afterDelay: INTRO_TIME)
  }

  func beginEnemyGeneration() {
    enemyGenerationTimer = NSTimer.scheduledTimerWithTimeInterval(ENEMY_REPEAT_TIME, target: self, selector: "addBird", userInfo: nil, repeats: true)
  }

  func setup() {
    backgroundColor = SKColor.whiteColor()

    physicsWorld.gravity = CGVectorMake(0, GAME_GRAVITY)
    physicsWorld.contactDelegate = self
    setupScrollingBackground(imageNamed: "short background")
    setupScreenEdge()
  }

  func setupScreenEdge() {
    let screenEdgeSprite = SKSpriteNode()
    screenEdgeSprite.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
    screenEdgeSprite.physicsBody?.categoryBitMask = PhysicsCategory.ScreenEdge
    screenEdgeSprite.physicsBody?.contactTestBitMask = PhysicsCategory.Helicopter
    screenEdgeSprite.physicsBody?.collisionBitMask = PhysicsCategory.None
    addChild(screenEdgeSprite)
  }

  func setupScrollingBackground(imageNamed imageName: String) {
    let background1 = createBackgroundNode(imageNamed: imageName)
    let background2 = createBackgroundNode(imageNamed: imageName)

    let originalBackgroundPosition = CGPoint(x: background1.size.width / 2, y: background1.size.height / 2)
    let resetPosition = originalBackgroundPosition + CGPoint(x: background1.size.width, y: 0)


    let doubleBackground = SKSpriteNode(color: UIColor.clearColor(), size:
      CGSize(width: 2 * background1.size.width, height: background1.size.height))
    doubleBackground.addChild(background1)
    doubleBackground.addChild(background2)

    addChild(doubleBackground)

    background1.position = originalBackgroundPosition
    background2.position = resetPosition

    let originalContainerPosition = doubleBackground.position;
    let moveAction = SKAction.moveByX(-background1.size.width, y: 0, duration: NSTimeInterval(background1.size.width) / (50 * BACKGROUND_SCROLL_SPEED));
    let resetAction = SKAction.moveTo(originalContainerPosition, duration: 0)
    doubleBackground.runAction(SKAction.repeatActionForever(SKAction.sequence([moveAction, resetAction])))
  }

  func createBackgroundNode(imageNamed imageName: String) -> SKSpriteNode {
    let backgroundNode = SKSpriteNode(imageNamed: imageName);
    backgroundNode.size.width *= size.height / backgroundNode.size.height;
    backgroundNode.size.height = size.height;
    backgroundNode.zPosition = -1

    return backgroundNode;
  }

  let heliFrames = [SKTexture(imageNamed:"Helicopter blade up.png"),
    SKTexture(imageNamed:"Helicopter blade center.png"),
    SKTexture(imageNamed:"Helicopter blade down.png"),
    SKTexture(imageNamed:"Helicopter blade center.png")];

  func addHelicopter() {
    helicopter.size = UIImage(named: "Helicopter blade up.png")!.size * GAME_SCALE
    helicopter.physicsBody = SKPhysicsBody(rectangleOfSize: helicopter.size)
    helicopter.physicsBody?.dynamic = true
    helicopter.physicsBody?.categoryBitMask = PhysicsCategory.Helicopter
    helicopter.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy// & PhysicsCategory.ScreenEdge
    helicopter.physicsBody?.collisionBitMask = PhysicsCategory.None

    let leftEdgeBuffer: CGFloat = 0.05 * self.view!.frame.size.width;
    helicopter.position = CGPoint(x: helicopter.size.width + leftEdgeBuffer - helicopter.size.width / 2.0, y: size.height * 0.5)


    helicopter.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(heliFrames, timePerFrame: HELI_ANIMATION_TIME_SLOW)), withKey: kHelicopterAnimationKey)

    addChild(helicopter)
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

    let birdFrames = [SKTexture(imageNamed:"bird 1.png"),
                      SKTexture(imageNamed:"bird 2.png"),
                      SKTexture(imageNamed:"bird 3.png"),
                      SKTexture(imageNamed:"bird 2.png")];

    bird.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(birdFrames, timePerFrame: BIRD_ANIMATION_TIME)))

    addChild(bird)

    let randDuration = random(min: CGFloat(3.0), max: CGFloat(4.5))
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
    if (helicopter.parent == nil || helicopter.position.y < 0 || helicopter.position.y > size.height) {
      helicopter.removeAllActions()
      helicopter.removeFromParent();
      addHelicopter()
    }
    let gasRepeatInterval:NSTimeInterval = 100;

    let impulseAction = SKAction.applyForce(CGVectorMake(0, HELICOPTER_FORCE), duration: gasRepeatInterval);
    helicopter.runAction(impulseAction, withKey: kGasPedalActionKey)
    helicopter.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(heliFrames, timePerFrame: HELI_ANIMATION_TIME_FAST)));
  }

  func stopGasPedal() {
    helicopter.removeAllActions()
    helicopter.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(heliFrames, timePerFrame: HELI_ANIMATION_TIME_SLOW)));
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
        projectileDidCollideWithEnemy(firstBody.node as! SKSpriteNode, enemy: secondBody.node as! SKSpriteNode)
    }
    else if (firstBody.categoryBitMask & PhysicsCategory.Enemy != 0 &&
            secondBody.categoryBitMask & PhysicsCategory.Helicopter != 0) {
        enemyDidCollideWithHelicopter(firstBody.node as! SKSpriteNode);
    }
    else if (firstBody.categoryBitMask & PhysicsCategory.Helicopter != 0 &&
            secondBody.categoryBitMask & PhysicsCategory.ScreenEdge != 0) {
        explodeHelicopter();
    }
  }

  func enemyDidCollideWithHelicopter(enemy: SKSpriteNode) {
    print("Hit")
    enemy.removeFromParent()
    explodeHelicopter()
    explodeCrow(enemy)
  }

  func explodeHelicopter() {
    let heliExplosionSprite = SKSpriteNode(imageNamed: "Helicopter explosion 1.png")
    addChild(heliExplosionSprite)
    heliExplosionSprite.size = heliExplosionSprite.size * GAME_SCALE
    heliExplosionSprite.position = helicopter.position

    helicopter.removeFromParent();

    let explosionFrames = [SKTexture(imageNamed:"Helicopter explosion 1.png"),
                          SKTexture(imageNamed:"Helicopter explosion 2.png"),
                          SKTexture(imageNamed:"Helicopter explosion 3.png")];

    let animationAction = SKAction.repeatAction(SKAction.animateWithNormalTextures(explosionFrames, timePerFrame: EXPLOSION_TIME), count: 1)
    let removeAction = SKAction.removeFromParent();
    heliExplosionSprite.runAction(SKAction.sequence([animationAction, removeAction]));
  }

  func explodeCrow(crow: SKSpriteNode) {
    let crowExplosionSprite = SKSpriteNode(imageNamed: "exploding crow 1.png")
    addChild(crowExplosionSprite)
    crowExplosionSprite.size = crowExplosionSprite.size * GAME_SCALE * 1.8;
    crowExplosionSprite.position = crow.position

    crow.removeFromParent();

    let explosionFrames = [SKTexture(imageNamed:"exploding crow 1.png"),
                          SKTexture(imageNamed:"exploding crow 2.png"),
                          SKTexture(imageNamed:"exploding crow 3.png")];

    let animationAction = SKAction.repeatAction(SKAction.animateWithNormalTextures(explosionFrames, timePerFrame: EXPLOSION_TIME), count: 1)
    let removeAction = SKAction.removeFromParent();
    crowExplosionSprite.runAction(SKAction.sequence([animationAction, removeAction]));
  }

  func projectileDidCollideWithEnemy(projectile:SKSpriteNode, enemy:SKSpriteNode) {
    print("Hit")
    projectile.removeFromParent()
    explodeCrow(enemy)
  }

}

