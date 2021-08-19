//
//  NoteView.swift
//
//  Created by shout@claudiu.mn on 2021.08.16.

import UIKit

class OvalView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutMask()
    }
    
    private func layoutMask() {
        let mask = ovalMaskLayer()
        if mask.frame != bounds {
            mask.frame = bounds
            let path = CGPath(ellipseIn: bounds, transform: nil)
            mask.path = path
        }
    }

    private func ovalMaskLayer() -> CAShapeLayer {
        if let maskLayer = layer.mask as? CAShapeLayer { return maskLayer }
        
        let maskLayer = CAShapeLayer()
        maskLayer.fillColor = UIColor.black.cgColor
        layer.mask = maskLayer
        
        return maskLayer
    }

}
