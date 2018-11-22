//
//  UICollectionViewCell+XWEdit.swift
//  XWWidgetSwitfDemo
//
//  Created by 王剑石 on 2018/11/16.
//  Copyright © 2018 wangjianshi. All rights reserved.
//

import Foundation
import UIKit

fileprivate let XWEditMaxBouncesWidth: CGFloat = 100.0

extension UIView {
    
    private struct XWViewEdit_Key {
        static var originWidth  = "originWidth"
    }
    
    var xw_originWidth: CGFloat {
        
        get {
            if let width: CGFloat = objc_getAssociatedObject(self, &XWViewEdit_Key.originWidth) as? CGFloat {
                
                return width
            }
            
            return 0
        }
        set {
            objc_setAssociatedObject(self,&XWViewEdit_Key.originWidth,newValue,objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    //返回该view所在的父view
    func superView<T: UIView>(of: T.Type) -> T? {
        for view in sequence(first: self.superview, next: { $0?.superview }) {
            if let father = view as? T {
                return father
            }
        }
        return nil
    }
    
    
}

extension UICollectionViewCell {
    
    
    private struct XWCellEdit_Key {
        
        static var leftEidtView  = "xw_leftEidtView"
        static var rightEidtView  = "xw_rightEidtView"
        static var lastPanTranslation  = "lastPanTranslation"
        
    }
    
    fileprivate var lastPanTranslation: CGPoint {
        
        get {
            if let point: CGPoint = objc_getAssociatedObject(self, &XWCellEdit_Key.lastPanTranslation) as? CGPoint {
                
                return point
            }
            
            return CGPoint.zero
        }
        set {
            objc_setAssociatedObject(self,&XWCellEdit_Key.lastPanTranslation,newValue,objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var xw_leftEidtView: UIView? {
        
        get {
            if let view: UIView = objc_getAssociatedObject(self, &XWCellEdit_Key.leftEidtView) as? UIView {
                
                return view
            }
            
            return nil
        }
        set {
            
            if  (objc_getAssociatedObject(self, &XWCellEdit_Key.leftEidtView) as? UIView) != newValue {
                
                xw_leftEidtView?.removeFromSuperview()
                if let leftView = newValue {
                    self.clipsToBounds = true
                    leftView.removeFromSuperview()
                    self.insertSubview(leftView, at: 0)
                    if self.contentView.backgroundColor == nil {
                        self.contentView.backgroundColor = self.backgroundColor ?? UIColor.white
                        if self.backgroundColor == nil {
                            self.backgroundColor = self.contentView.backgroundColor
                        }
                    }
                }
            }
            objc_setAssociatedObject(self,&XWCellEdit_Key.leftEidtView,newValue,objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            updatePanGestureRecognizer()
        }
    }
    
    var xw_rightEidtView: UIView? {
        
        get {
            if let view: UIView = objc_getAssociatedObject(self, &XWCellEdit_Key.rightEidtView) as? UIView {
                
                return view
            }
            
            return nil
        }
        set {
            
            if  (objc_getAssociatedObject(self, &XWCellEdit_Key.rightEidtView) as? UIView) != newValue {
            
                xw_rightEidtView?.removeFromSuperview()
                if let rightView = newValue {
                    self.clipsToBounds = true
                    rightView.removeFromSuperview()
                    self.insertSubview(rightView, at: 0)
                    if self.contentView.backgroundColor == nil {
                        self.contentView.backgroundColor = self.backgroundColor ?? UIColor.white
                        if self.backgroundColor == nil {
                            self.backgroundColor = self.contentView.backgroundColor
                        }
                    }
                }
            }
            objc_setAssociatedObject(self,&XWCellEdit_Key.rightEidtView,newValue,objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            updatePanGestureRecognizer()
        }
    }
    
    public func xw_finishEditWith(animated: Bool) {
        
        let x: CGFloat = self.contentView.frame.origin.x
        if x != 0 {
            
            self.lastPanTranslation = CGPoint.zero
            if animated {
                UIView.animate(withDuration: 0.22) {
                    
                    self.handlerPanWithTranslation(translation: CGPoint(x: -x, y: 0))
                    self.xw_leftEidtView?.layoutIfNeeded()
                    self.xw_rightEidtView?.layoutIfNeeded()
                }
            }else {
                
                UIView.performWithoutAnimation {
                    self.handlerPanWithTranslation(translation: CGPoint(x: -x, y: 0))
                }
            }
        }
    }
    
    public func xw_isEditing() -> Bool {
        
        return self.contentView.frame.origin.x != 0
    }
    
    public func xw_showLeftEditView() {
        
        scrollToLeftView()
    }
    
    public func xw_showRightEditView() {
        
        scrollToRightView()
    }
    
    fileprivate func updatePanGestureRecognizer()  {

        if self.xw_leftEidtView != nil || self.xw_rightEidtView != nil {
            var pan: XWPanGestureRecognizer? = self.getPanGestureRecognizer()
            if pan == nil {
                
                pan = XWPanGestureRecognizer.init(target: self, action: #selector(onPanGestureRecognizer(pan:)))
                pan?.panDelegate = self
                pan?.targetView = self
                pan?.direction = .horizontal
                self.addGestureRecognizer(pan!)
            }
            self.isUserInteractionEnabled = true
        }else {
            
            let pan: XWPanGestureRecognizer? = self.getPanGestureRecognizer()
            if pan != nil {
                self.removeGestureRecognizer(pan!)
            }
        }
        
        UICollectionView.xw_hookHitTest()
        
    }
    

    fileprivate func handlerPanWithTranslation(translation: CGPoint) {
        
        let point = translation
        let lastPoint = self.lastPanTranslation
        let offset: CGPoint = CGPoint(x: point.x - lastPoint.x, y: point.y - lastPoint.y)
        let size = self.frame.size
        var x: CGFloat = self.contentView.frame.origin.x
        var offsetX: CGFloat = offset.x
        let leftViewWidth: CGFloat = self.getOriginWidth(view: self.xw_leftEidtView)
        let rightViewWidth: CGFloat = self.getOriginWidth(view: self.xw_rightEidtView)
        if offset.x >= 0 {
            if leftViewWidth - x <= 0 {
                offsetX = offsetX*0.6 < 6 ? offsetX*0.6 : 6
            }else {
                if x + offset.x > leftViewWidth {
                    x = leftViewWidth
                    offsetX = offsetX*0.6 < 6 ? offsetX*0.6 : 6
                }
            }
            x = x + offsetX
        }else {
            
            let rightMargin: CGFloat = size.width - self.contentView.frame.maxX
            if rightViewWidth - rightMargin <= 0 {
                offsetX = offsetX * 0.6 > -6 ? offsetX*0.6 : -6
            }else {
                if rightMargin + CGFloat(fabsf(Float(offset.x))) > rightViewWidth {
                    x = -rightMargin
                    offsetX = offsetX * 0.6 > -6 ? offsetX*0.6 : -6
                }
            }
            x = x + offsetX
        }
        x = x < leftViewWidth + XWEditMaxBouncesWidth  ? x : leftViewWidth + XWEditMaxBouncesWidth
        x = x > -(rightViewWidth + XWEditMaxBouncesWidth) ? x : -(rightViewWidth + XWEditMaxBouncesWidth)
        handlerViewLayoutWithContentViewX(x: x)
    }
    
    fileprivate func handlerViewLayoutWithContentViewX(x: CGFloat) {
        
        let size: CGSize = self.contentView.frame.size
        self.contentView.frame = CGRect(x: x, y: 0, width: size.width, height: size.height)
        if self.xw_leftEidtView != nil {
            
            let width: CGFloat = self.getOriginWidth(view: self.xw_leftEidtView)
            var adjustWidth: CGFloat = self.contentView.frame.minX
           if (adjustWidth < width){
                adjustWidth = width
            }
            self.xw_leftEidtView?.frame = CGRect(x: 0, y: 0, width: adjustWidth, height: size.height)
        }
        
        if self.xw_rightEidtView != nil {
            
            let width: CGFloat = self.getOriginWidth(view: self.xw_rightEidtView)
            var adjustX: CGFloat = self.contentView.frame.maxX
            if adjustX >= size.width - width {
                adjustX = size.width - width
            }
            self.xw_rightEidtView?.frame = CGRect(x: adjustX, y: 0, width: size.width - adjustX, height: size.height)
        }
        if self.contentView.translatesAutoresizingMaskIntoConstraints == false {
            self.contentView.translatesAutoresizingMaskIntoConstraints = true
        }
        if self.contentView.backgroundColor != self.backgroundColor {
            
            self.backgroundColor = self.contentView.backgroundColor
        }
        
    }
    
    fileprivate func getPanGestureRecognizer() -> XWPanGestureRecognizer? {
        
        for gr in self.gestureRecognizers ?? [] {
            if let xwgr: XWPanGestureRecognizer = gr as? XWPanGestureRecognizer {
                return xwgr
            }
        }
        return nil
    }
    
    fileprivate func getOriginWidth(view: UIView?) -> CGFloat {
        
        if let oriView = view, oriView.xw_originWidth <= 0 {
            
            var width: CGFloat = 0
            if view!.frame.size.width > 0 {
                width = view!.frame.size.width
            }else {
                view!.frame = CGRect(x: 0, y: 0, width: 0, height: self.frame.size.height)
                width = view!.systemLayoutSizeFitting(UILayoutFittingCompressedSize).width
            }
            view?.xw_originWidth = width
            
            return width
        }
        
        return view?.xw_originWidth ?? 0
    }
    
}

extension UICollectionViewCell: XWPanGestureRecognizerDelegate {
    
    
    func gestureRecognizer(gestureRecognizer: XWPanGestureRecognizer, shouldBeginWithVelocity veloctiy: CGPoint) -> Bool {
        
        if (self.xw_leftEidtView == nil && veloctiy.x > 0) || (self.xw_rightEidtView == nil && veloctiy.x < 0) {
            return false
        }
        
        return true
        
    }
    
    
    @objc fileprivate func onPanGestureRecognizer(pan: XWPanGestureRecognizer) {
        
        let point: CGPoint = pan.translation
        if pan.state == .began {
            self.lastPanTranslation = CGPoint.zero
            handlerPanWithTranslation(translation: point)
        }else if pan.state == .changed {
            handlerPanWithTranslation(translation: point)
        }else {
            handlerPanWithTranslation(translation: point)
            let leftViewWidth: CGFloat = self.getOriginWidth(view: self.xw_leftEidtView)
            let rightViewWidth: CGFloat = self.getOriginWidth(view: self.xw_rightEidtView)
            let x: CGFloat = self.contentView.frame.origin.x
            let velocity: CGPoint = pan.velocity
            if velocity.x >= 0 {
                if (velocity.x >= 300 && x > 20) || (x > 50){
                    scrollToLeftView()
                }else {
                    if velocity.x < 300 && self.xw_rightEidtView != nil && x < -rightViewWidth*0.5 {
                        scrollToRightView()
                    }else{
                        scrollToCenter()
                    }
                }
            }else {
                if (velocity.x < -300 && x < -20) || (x < -50){
                    scrollToRightView()
                }else{
                    if velocity.x > -300 && self.xw_leftEidtView != nil && x >= leftViewWidth*0.5 {
                        scrollToLeftView()
                    }else{
                        scrollToCenter()
                    }
                }
            }
            
            
        }
        
        self.lastPanTranslation = point
        
    }
    
    fileprivate func scrollToLeftView() {
        
        let leftViewWidth: CGFloat = self.getOriginWidth(view: self.xw_leftEidtView)
        if leftViewWidth > 0 {
            let x: CGFloat = self.contentView.frame.origin.x
            let length: CGFloat = CGFloat(fabsf(Float(leftViewWidth - x)))
            let minLength: CGFloat = length/leftViewWidth < 1 ? length/leftViewWidth : 1
            UIView.animate(withDuration: TimeInterval(0.15 + 0.2 * minLength)) {
                
                self.handlerViewLayoutWithContentViewX(x: leftViewWidth)
                self.xw_leftEidtView?.layoutIfNeeded()
                self.xw_rightEidtView?.layoutIfNeeded()
            }
        }else{
            
            self.scrollToCenter()
        }
        
    }
    
    fileprivate func scrollToRightView() {
        
        let rightViewWidth: CGFloat = self.getOriginWidth(view: self.xw_rightEidtView)
        if rightViewWidth > 0 {
            let x: CGFloat = self.contentView.frame.origin.x
            let length: CGFloat = CGFloat(fabsf(Float(rightViewWidth + x)))
            let minLength: CGFloat = length/rightViewWidth < 1 ? length/rightViewWidth : 1
            UIView.animate(withDuration: TimeInterval(0.15 + 0.2 * minLength)) {

                self.handlerViewLayoutWithContentViewX(x: -rightViewWidth)
                self.xw_leftEidtView?.layoutIfNeeded()
                self.xw_rightEidtView?.layoutIfNeeded()
            }
        }else{
            
            self.scrollToCenter()
        }
    }
    
    fileprivate func scrollToCenter() {
        
        let x: CGFloat = self.contentView.frame.origin.x
        let length: CGFloat = CGFloat(fabsf(Float(0 - x)))
        let leftViewWidth: CGFloat = self.getOriginWidth(view: self.xw_leftEidtView)
        let rightViewWidth: CGFloat = self.getOriginWidth(view: self.xw_rightEidtView)
        var defaultLength: CGFloat = leftViewWidth > 0 ? leftViewWidth : rightViewWidth
        if defaultLength == 0 {
            defaultLength = XWEditMaxBouncesWidth
        }
        let minLength: CGFloat = length/defaultLength < 1 ? length/defaultLength : 1
        UIView.animate(withDuration: TimeInterval(0.15 + 0.2 * minLength)) {
            self.handlerViewLayoutWithContentViewX(x: 0)
            self.xw_leftEidtView?.layoutIfNeeded()
            self.xw_rightEidtView?.layoutIfNeeded()
        }
        
        
        
    }
}
