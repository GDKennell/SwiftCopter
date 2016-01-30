//
//  GraphicsMathHelpers.swift
//  SwiftCopter
//
//  Created by Grant Kennell on 1/30/16.
//  Copyright © 2016 Grant Kennell. All rights reserved.
//

import Foundation
import SpriteKit

// Random 

func random() -> CGFloat {
  return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
}

func random(min min: CGFloat, max: CGFloat) -> CGFloat {
  return random() * (max - min) + min
}


// Size - Float

func * (left:CGSize, right: CGFloat) -> CGSize {
  return CGSize(width: left.width * right, height: left.height * right);
}

func * (left:CGFloat, right: CGSize) -> CGSize {
  return CGSize(width: right.width * left, height: right.height * left);
}

func / (left:CGSize, right: CGFloat) -> CGSize {
  return CGSize(width: left.width / right, height: left.height / right);
}

// Point - Point

func + (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
  func sqrt(a: CGFloat) -> CGFloat {
    return CGFloat(sqrtf(Float(a)))
  }
#endif

// Vectors

extension CGPoint {
  func length() -> CGFloat {
    return sqrt(x*x + y*y)
  }

  func normalized() -> CGPoint {
    return self / length()
  }
}