//
//  SimpleKeyboardView.swift
//
//  Created by shout@claudiu.mn on 2021.08.16.

import UIKit

protocol KeyboardViewDelegate: AnyObject {
    func didPressKey(at index: UInt, in keyboardView: SimpleKeyboardView)
    func didReleaseKey(at index: UInt, in keyboardView: SimpleKeyboardView)
}

struct KeyColors {
    let background: UIColor
    let stroke: UIColor
    let overlay: UIColor
}

class SimpleKeyboardView: UIView {
    weak var delegate: KeyboardViewDelegate?
    
    var naturalColors: KeyColors = KeyColors(background: .white,
                                                             stroke: .black,
                                                             overlay: .black) {
        didSet {
            let sharpCount = Int(range.sharpCount)
            let naturalCount = Int(range.length) + 1
            
            guard subviews.count == sharpCount + naturalCount else { return }
            
            styleViewsAsNatural(from: 0, counting: naturalCount)
        }
    }
    
    var accidentalColors: KeyColors = KeyColors(background: .black,
                                                          stroke: .black,
                                                          overlay: .white) {
        didSet {
            let sharpCount = Int(range.sharpCount)
            let naturalCount = Int(range.length) + 1
            
            guard subviews.count == sharpCount + naturalCount else { return }
            
            let sharpStartIndex = naturalCount
            let sharpEndIndex = sharpStartIndex + sharpCount
            
            styleViewsAsAccidental(from: sharpStartIndex,
                                   counting: sharpEndIndex)
        }
    }
    
    var enabled: Bool = true {
        didSet {
            isUserInteractionEnabled = enabled
            for key in subviews {
                key.subviews.first?.alpha = enabled ? 0 : 0.5
            }
        }
    }
    
    var range: NaturalRange = NaturalRange(start: .c, length: 7) {
        didSet {
            setUpViews()
            arrangeViews()
        }
    }
    
    private var hitKeys: [UITouch : UIView] = [:]
    
    private func setUpViews() {
        for sub in subviews { sub.removeFromSuperview() }
        
        var whiteLength = 0
        while whiteLength <= range.length {
            let whiteView = UIView()
            whiteView.translatesAutoresizingMaskIntoConstraints = false
            let overlay = UIView()
            overlay.isUserInteractionEnabled = false
            overlay.translatesAutoresizingMaskIntoConstraints = false
            overlay.alpha = 0
            whiteView.addSubview(overlay)
            addSubview(whiteView)
            whiteLength += 1
            styleViewAsNatural(whiteView)
        }
        
        for _ in 0..<range.sharpCount {
            let blackView = UIView()
            blackView.translatesAutoresizingMaskIntoConstraints = false
            let overlay = UIView()
            overlay.isUserInteractionEnabled = false
            overlay.translatesAutoresizingMaskIntoConstraints = false
            overlay.alpha = 0
            blackView.addSubview(overlay)
            addSubview(blackView)
            styleViewAsAccidental(blackView)
        }
    }
    
    private func arrangeViews() {
        let whiteWidth = bounds.width / CGFloat(range.length + 1)
        let blackWidth = whiteWidth * 0.6
        let strokeWidth = blackWidth * 0.06
        for i in 0...Int(range.length) {
            let view = subviews[i]
            view.layer.borderWidth = strokeWidth
            view.frame = CGRect(x: CGFloat(i) * whiteWidth,
                                y: 0,
                                width: whiteWidth,
                                height: bounds.height)
            view.subviews.first!.frame = view.bounds
        }
        
        var sharpViewIndex = Int(range.length + 1)
        let sharpDistribution = range.sharpDistribution
        var centerX = whiteWidth
        for i in 0..<sharpDistribution.count {
            let hasSharp = sharpDistribution[i]
            if hasSharp {
                let sharpView = subviews[sharpViewIndex]
                sharpView.layer.borderWidth = strokeWidth
                sharpView.frame = CGRect(x: centerX - blackWidth * 0.5,
                                         y: 0,
                                         width: blackWidth,
                                         height: bounds.height * 0.65)
                sharpView.subviews.first!.frame = sharpView.bounds
                sharpViewIndex += 1
            }
            centerX += whiteWidth
        }
        
        let sorted = subviews.sorted(by: { $0.frame.minX < $1.frame.minX })
        for i in 0..<sorted.count {
            let view = sorted[i]
            view.tag = i
        }
    }
    
    private func styleViewsAsNatural(from startIndex: Int,
                                     counting endIndex: Int) {
        for i in startIndex..<endIndex {
            let natural = subviews[i]
            styleViewAsNatural(natural)
        }
    }
    
    private func styleViewAsNatural(_ view: UIView) {
        view.backgroundColor = naturalColors.background
        view.layer.borderColor = naturalColors.stroke.cgColor
        view.subviews.first!.backgroundColor = naturalColors.overlay
    }
    
    private func styleViewsAsAccidental(from startIndex: Int,
                                        counting endIndex: Int) {
        for i in startIndex..<endIndex {
            let accidental = subviews[i]
            styleViewAsAccidental(accidental)
        }
    }
    
    private func styleViewAsAccidental(_ view: UIView) {
        view.backgroundColor = accidentalColors.background
        view.layer.borderColor = accidentalColors.stroke.cgColor
        view.subviews.first!.backgroundColor = accidentalColors.overlay
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        arrangeViews()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.reversed().first!
        
//        for touch in touches {
            guard let view = hitTest(touch.location(in: self),
                                     with: event) else { return }
        
            let previousKey = hitKeys[touch]
            if previousKey != view {
                hitKeys[touch] = view
                let index = view.tag //arrangedViews.firstIndex(of: view)!
                view.subviews.first!.alpha = 0.5
                if let previousKey = previousKey {
                    previousKey.subviews.first!.alpha = 0
                    delegate?.didReleaseKey(at: UInt(previousKey.tag),
                                            in: self)
                }
                delegate?.didPressKey(at: UInt(index), in: self)
            }
//        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.reversed().first!
        
//        for touch in touches {
            guard let view = hitTest(touch.location(in: self),
                                     with: event) else { return }
            
            let previousKey = hitKeys[touch]
            if previousKey != view {
                hitKeys[touch] = view
                let index = view.tag// arrangedViews.firstIndex(of: view)!
                view.subviews.first!.alpha = 0.5
                if let previousKey = previousKey {
                    previousKey.subviews.first!.alpha = 0
                    delegate?.didReleaseKey(at: UInt(previousKey.tag),
                                            in: self)
                }
                delegate?.didPressKey(at: UInt(index), in: self)
            }
//        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.reversed().first!
        
//        for touch in touches {
            if let previousKey = hitKeys[touch] {
                previousKey.subviews.first!.alpha = 0
                hitKeys.removeValue(forKey: touch)
                previousKey.subviews.first!.alpha = 0
                delegate?.didReleaseKey(at: UInt(previousKey.tag),
                                        in: self)
            }
//        }
    }
}
