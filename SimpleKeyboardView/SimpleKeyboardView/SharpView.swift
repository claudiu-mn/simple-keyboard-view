//
//  SharpView.swift
//
//  Created by shout@claudiu.mn on 2021.08.16.

import UIKit

class SharpView: UIView {
    override func tintColorDidChange() {
        super.tintColorDidChange()
        (layer.sublayers!.first as! CAShapeLayer).fillColor = tintColor.cgColor
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layer = layer.sublayers!.first! as! CAShapeLayer
        let path = sharpPath()
        let transform = CGAffineTransform.identity.scaledBy(x: bounds.width,
                                                            y: bounds.height)
        layer.fillColor = tintColor.cgColor
        path.apply(transform)
        layer.path = path.cgPath
    }
    
    func setup() {
        let shapeLayer = CAShapeLayer()
        layer.addSublayer(shapeLayer)
    }
    
    func sharpPath() -> UIBezierPath {
        let path = UIBezierPath()
        
        let ySkew: CGFloat = 0.06
        let vWidth: CGFloat = 0.1
        let hWidth: CGFloat = 0.1
        
        let xFraction: CGFloat = 0.3
        let yFraction: CGFloat = 0.3
        
        path.move(to: CGPoint(x: xFraction - vWidth / 2, y: ySkew))
        path.addLine(to: CGPoint(x: xFraction + vWidth / 2, y: ySkew))
        path.addLine(to: CGPoint(x: xFraction + vWidth / 2, y: 1))
        path.addLine(to: CGPoint(x: xFraction - vWidth / 2, y: 1))
        path.addLine(to: CGPoint(x: xFraction - vWidth / 2, y: ySkew))
        
        path.move(to: CGPoint(x: 1 - xFraction - vWidth / 2, y: 0))
        path.addLine(to: CGPoint(x: 1 - xFraction + vWidth / 2, y: 0))
        path.addLine(to: CGPoint(x: 1 - xFraction + vWidth / 2, y: 1 - ySkew))
        path.addLine(to: CGPoint(x: 1 - xFraction - vWidth / 2, y: 1 - ySkew))
        path.addLine(to: CGPoint(x: 1 - xFraction - vWidth / 2, y: 0))
        
        path.move(to: CGPoint(x: 0, y: yFraction + ySkew - hWidth / 2))
        path.addLine(to: CGPoint(x: 1, y: yFraction - ySkew - hWidth / 2))
        path.addLine(to: CGPoint(x: 1, y: yFraction - ySkew + hWidth / 2))
        path.addLine(to: CGPoint(x: 0, y: yFraction + ySkew + hWidth / 2))
        path.addLine(to: CGPoint(x: 0, y: yFraction + ySkew - hWidth / 2))
        
        path.move(to: CGPoint(x: 0, y: 1 - yFraction + ySkew - hWidth / 2))
        path.addLine(to: CGPoint(x: 1, y: 1 - yFraction - ySkew - hWidth / 2))
        path.addLine(to: CGPoint(x: 1, y: 1 - yFraction - ySkew + hWidth / 2))
        path.addLine(to: CGPoint(x: 0, y: 1 - yFraction + ySkew + hWidth / 2))
        path.addLine(to: CGPoint(x: 0, y: 1 - yFraction + ySkew - hWidth / 2))
        
//        path.move(to: CGPoint(x: 0, y: 0.33 + ySkew))
//        path.addLine(to: CGPoint(x: 1, y: 0.33 - ySkew))
        
//        path.move(to: CGPoint(x: 0, y: 0.66 + ySkew))
//        path.addLine(to: CGPoint(x: 1, y: 0.66 - ySkew))

        return path
    }
}
