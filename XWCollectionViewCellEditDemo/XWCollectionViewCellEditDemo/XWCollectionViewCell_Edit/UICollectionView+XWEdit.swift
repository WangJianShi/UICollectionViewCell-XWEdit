//
//  UICollectionView+XWEdit.swift
//  XWWidgetSwitfDemo
//
//  Created by 王剑石 on 2018/11/19.
//  Copyright © 2018 wangjianshi. All rights reserved.
//

import Foundation
import UIKit


extension DispatchQueue {
    private static var onceTracker = [String]()
    
    open class func once(token: String, block:() -> Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        if onceTracker.contains(token) {
            return
        }
        
        onceTracker.append(token)
        block()
    }
}


extension UICollectionView {
    
    public class func xw_hookHitTest() {
        
        struct Static {
            static var token = NSUUID().uuidString + "UICollectionView"
        }
        
        DispatchQueue.once(token: Static.token) {
            
            let cls: AnyClass = UICollectionView.self
            let originalSelector  = #selector(hitTest(_:with:))
            let swizzledSelector  = #selector(xw_hitTest(_:with:))
            let originalMethod = class_getInstanceMethod(cls, originalSelector)
            let swizzledMethod = class_getInstanceMethod(cls, swizzledSelector)
            let didAddMethod: Bool = class_addMethod(cls, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))
            
            if didAddMethod {
                class_replaceMethod(cls, swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
            } else {
                method_exchangeImplementations(originalMethod!, swizzledMethod!)
            }
            
        }
        
    }
    
    @objc func xw_hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        let view: UIView? = self.xw_hitTest(point, with: event)
        if let hitView: UIView = view {
            let cells = self.visibleCells
            for cell in cells {
                if cell.xw_leftEidtView != nil || cell.xw_rightEidtView != nil {
                    var isEditing: Bool = false
                    for subView in sequence(first: hitView, next: { $0?.superview }) {
                        if (subView.isKind(of: UICollectionView.self) || subView.isKind(of: UICollectionViewCell.self)) {
                           break
                        }
                        if subView == cell.xw_leftEidtView || subView == cell.xw_rightEidtView {
                            isEditing = true
                        }
                    }
                    
                    if !isEditing {
                        cell.xw_finishEditWith(animated: true)
                    }
                }
            }
        }
        
        return view
    }
    
    
}
