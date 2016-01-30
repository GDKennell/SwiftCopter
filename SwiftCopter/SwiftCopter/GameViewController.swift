//
//  GameViewController.swift
//  SwiftCopter
///
//  Created by Grant Kennell on 1/30/16.
//  Copyright (c) 2016 Grant Kennell. All rights reserved.
//

// Thanks to Ray Wenderlich for the tutorial on which this is based:
// http://www.raywenderlich.com/119815/sprite-kit-swift-2-tutorial-for-beginners

import UIKit
import SpriteKit

class GameViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    let scene = GameScene(size: view.bounds.size)
    let skView = view as! SKView
    skView.showsFPS = true
    skView.showsNodeCount = true
    skView.ignoresSiblingOrder = true
    scene.scaleMode = .ResizeFill
    skView.presentScene(scene)
  }

  override func prefersStatusBarHidden() -> Bool {
    return true
  }
}
