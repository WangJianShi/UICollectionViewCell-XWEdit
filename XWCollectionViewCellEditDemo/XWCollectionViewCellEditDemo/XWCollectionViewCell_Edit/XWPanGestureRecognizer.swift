//
//  XWPanGestureRecognizer.swift
//  XWWidgetSwitfDemo
//
//  Created by 王剑石 on 2018/11/7.
//  Copyright © 2018年 wangjianshi. All rights reserved.
//

import UIKit


struct XWPanGestureRecognizerDirection: OptionSet {
    let rawValue: Int
    static let right = XWPanGestureRecognizerDirection(rawValue: 1 << 1)
    static let left = XWPanGestureRecognizerDirection(rawValue: 1 << 2)
    static let up = XWPanGestureRecognizerDirection(rawValue: 1 << 3)
    static let down = XWPanGestureRecognizerDirection(rawValue: 1 << 4)
    static let horizontal = XWPanGestureRecognizerDirection(rawValue: 1 << 1 | 1 << 2)
    static let vertical = XWPanGestureRecognizerDirection(rawValue: 1 << 3 | 1 << 4)
}

@objc protocol XWPanGestureRecognizerDelegate: UIGestureRecognizerDelegate {

    func gestureRecognizer(gestureRecognizer: XWPanGestureRecognizer, shouldBeginWithVelocity veloctiy: CGPoint) -> Bool
}

class XWPanGestureRecognizer: UIPanGestureRecognizer,UIGestureRecognizerDelegate {
    
    weak var panDelegate: XWPanGestureRecognizerDelegate?
    
    var direction: XWPanGestureRecognizerDirection = [.horizontal,.vertical]
    
    fileprivate var velocityBegin: CGPoint = CGPoint.zero
    
    var velocityWhenBegin: CGPoint {
        
        get{
            return velocityBegin
        }
    }
    
    var translation: CGPoint {
        
        get{
            if let view = targetView {
                return self.translation(in: view)
            }
            return CGPoint.zero
        }
    }
    
    var velocity: CGPoint {
        
        get {
            if let view = targetView {
                return self.velocity(in: view)
            }
            return CGPoint.zero
        }
    }
    
    var targetView: UIView? {
        
        didSet {
            if targetView != nil {
                targetView?.removeGestureRecognizer(self)
            }
        }
    }
    
    var paning: Bool {
        get {
            if self.state == .began || self.state == .changed {
                return true
            }
            return false
        }
    }
    
    var isHorizontalWhenBegin: Bool {
        
        return fabs(velocityBegin.x) >= fabs(velocityBegin.y)
    }
    
    var isLeftWhenBegin: Bool {
        
        return velocityBegin.x <= 0
    }
    
    override init(target: Any?, action: Selector?) {
        
        super.init(target: target, action: action)
        self.delegate = self
    }
    
    func shouldBeginByDirection() -> Bool {
        
        let velocity: CGPoint = velocityBegin
        switch self.direction {
        case .up:
            return fabs(velocity.x) <= fabs(velocity.y) && velocity.y < 0
        case .down:
            return fabs(velocity.x) <= fabs(velocity.y) && velocity.y > 0
        case .left:
            return fabs(velocity.x) >= fabs(velocity.y) && velocity.x < 0
        case .right:
            return fabs(velocity.x) >= fabs(velocity.y) && velocity.x > 0
        case .horizontal:
            return fabs(velocity.x) >= fabs(velocity.y)
        case .vertical:
            return fabs(velocity.x) <= fabs(velocity.y)
        
        default:
            return true
        }
        
    }
    
    func updateVelocityWhenBegin() {
        
        var velocity: CGPoint = self.velocity
        if velocity.x == 0 && velocity.y == 0 {
            
            velocity = translation
        }
        velocityBegin = velocity
    }
    
    //MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        self.updateVelocityWhenBegin()
        var result: Bool = true
        self.velocityBegin = self.velocity
        result = self.panDelegate?.gestureRecognizerShouldBegin?(gestureRecognizer) ?? true
        result = self.panDelegate?.gestureRecognizer(gestureRecognizer: self, shouldBeginWithVelocity: self.velocityWhenBegin) ?? true
        
        if result {
            
            result = self.shouldBeginByDirection()
        }
        
        return result
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return self.panDelegate?.gestureRecognizer?(self,shouldRecognizeSimultaneouslyWith:otherGestureRecognizer) ?? false
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return self.panDelegate?.gestureRecognizer?(self,shouldBeRequiredToFailBy:otherGestureRecognizer) ?? false
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return self.panDelegate?.gestureRecognizer?(self,shouldRequireFailureOf:otherGestureRecognizer) ?? false
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        return self.panDelegate?.gestureRecognizer?(self,shouldReceive:touch) ?? true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive press: UIPress) -> Bool {
        
        return self.panDelegate?.gestureRecognizer?(self,shouldReceive:press) ?? true
    }

}
