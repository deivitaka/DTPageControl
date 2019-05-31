//
//  DTPageControl.swift
//  EasyPay
//
//  Created by Deivi Taka on 29/05/2019.
//  Copyright © 2019 EasyPay shpk. All rights reserved.
//

import UIKit

@IBDesignable
public class DTPageControl: UIControl {
    
    //MARK: Properties
    // Zoom
    @IBInspectable public var zoomSelected: Bool = true { didSet { setup() } }
    @IBInspectable public var zoomEffect: Bool = false { didSet { setup() } }
    @IBInspectable public var shrinkCoefficient: CGFloat = 0.6 { didSet { setup() } }
    // Line
    @IBInspectable public var showTrack: Bool = false { didSet { setup() } }
    @IBInspectable public var lineAlpha: CGFloat = 0.3 { didSet { setup() } }
    @IBInspectable public var lineWidth: CGFloat = 1.0 { didSet { setup() } }
    @IBInspectable public var lineInset: CGFloat = 0 { didSet { setup() } }
    // Indicator
    @IBInspectable public var continuousSteps: Bool = true { didSet { setup() } }
    @IBInspectable public var fillUnstepped: Bool = true { didSet { setup() } }
    @IBInspectable public var steps: Int = 3 { didSet { setup() } }
    @IBInspectable public var selectedStep: Int = 0 { didSet {
        selectedStep = max(0, min(selectedStep, steps-1))
        animatePaths()
        } }
    @IBInspectable public var indicatorSize: CGFloat = 7.0 { didSet {
        indicatorSize = max(0, min(indicatorSize, frame.height))
        setup()
        } }
    @IBInspectable public var stepWidth: CGFloat = 1.0 { didSet { setup() } }
    @IBInspectable public var stepAlpha: CGFloat = 0.3 { didSet { setup() } }
    
    public var animationDuration: Double = 0.3
    
    fileprivate var indicators = [CAShapeLayer]()
    fileprivate var lines = [CAShapeLayer]()
    
    //MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)!
        setup()
    }
    
}

fileprivate extension DTPageControl {
    
    func setup() {
        setupPaths()
        updatePaths()
    }
    
    func setupPaths() {
        indicators.removeAll()
        lines.removeAll()
        
        if showTrack {
            for step in 0..<steps-1 { lines.append(linePath(for: step)) }
        }
        
        for step in 0..<steps { indicators.append(indicatorPath(for: step)) }
    }
    
    func updatePaths() {
        layer.sublayers?.forEach({ $0.removeFromSuperlayer() })
        if showTrack {
            for step in 0..<lines.count { layer.addSublayer(lines[step]) }
        }
        for step in 0..<indicators.count { layer.addSublayer(indicators[step]) }
    }
    
    func animatePaths() {
        func anim(_ key: String?) -> CABasicAnimation {
            let animation = CABasicAnimation(keyPath: key)
            animation.duration = animationDuration
            animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
            animation.fillMode = .forwards
            animation.isRemovedOnCompletion = false
            return animation
        }
        
        for step in 0..<indicators.count {
            let pathAnim = anim("path")
            pathAnim.toValue = indicatorPath(for: step).path
            let lineAnim = anim("lineWidth")
            lineAnim.toValue = indicatorLineWidth(for: step)
            let fillAnim = anim("fillColor")
            fillAnim.toValue = indicatorFillColor(for: step)
            
            let anims = [pathAnim, lineAnim, fillAnim]
            anims.forEach({ indicators[step].add($0, forKey: nil) })
        }
        
        for step in 0..<lines.count {
            let pathAnim = anim("path")
            pathAnim.toValue = linePath(for: step).path
            let fillAnim = anim("fillColor")
            fillAnim.toValue = lineFillColor(for: step)
            let anims = [pathAnim, fillAnim]
            anims.forEach({ lines[step].add($0, forKey: nil) })
        }
    }
}

//MARK:- Indicator
fileprivate extension DTPageControl {
    
    func isStepped(_ step: Int) -> Bool {
        if continuousSteps { return step <= selectedStep }
        return step == selectedStep
    }
    
    func indicatorCenter(for step: Int) -> CGPoint {
        let step = CGFloat(step)
        let steps = CGFloat(self.steps)
        guard step >= 0 && step < steps else { return .zero }
        
        let indicatorsWidth = indicatorSize*steps
        let lineWidth = (frame.width - indicatorsWidth) / (steps-1)
        let x = step * (indicatorSize + lineWidth) + indicatorSize/2
        let y = frame.height/2
        return CGPoint(x: x, y: y)
    }
    
    func indicatorSize(for step: Int) -> CGSize {
        var size: CGFloat
        if zoomSelected && continuousSteps && step == selectedStep
        { size = self.indicatorSize * (2-shrinkCoefficient) }
        else if isStepped(step) { size = self.indicatorSize }
        else { size = self.indicatorSize * shrinkCoefficient }
        
        if zoomEffect {
            let maxAffectedSteps: CGFloat = 3
            let coeffDiff = (1-shrinkCoefficient) / maxAffectedSteps
            let stepDiff = min(maxAffectedSteps, CGFloat(abs(step - selectedStep)))
            size = (1 - coeffDiff*stepDiff) * self.indicatorSize
        }
        
        return CGSize(width: size, height: size)
    }
    
    func indicatorRect(for step: Int) -> CGRect {
        let center = indicatorCenter(for: step)
        let size = indicatorSize(for: step)
        return CGRect(origin: center, size: size)
            .offsetBy(dx: -size.width/2, dy: -size.height/2)
    }
    
    func indicatorLineWidth(for step: Int) -> CGFloat {
        return (isStepped(step) || fillUnstepped) ? 0 : (stepWidth * shrinkCoefficient)
    }
    
    func indicatorFillColor(for step: Int) -> CGColor {
        let color = isStepped(step) ? tintColor :
            (fillUnstepped ? tintColor.withAlphaComponent(stepAlpha) : .clear)
        return color!.cgColor
    }
    
    func indicatorPath(for step: Int) -> CAShapeLayer {
        let width = indicatorLineWidth(for: step)
        let rect = indicatorRect(for: step).insetBy(dx: width/2, dy: width/2)
        let path = UIBezierPath(ovalIn: rect)
        
        let layer = CAShapeLayer()
        layer.strokeColor = tintColor.withAlphaComponent(stepAlpha).cgColor
        layer.lineWidth = width
        layer.fillColor = indicatorFillColor(for: step)
        layer.path = path.cgPath
        return layer
    }
    
}

//MARK: Line
fileprivate extension DTPageControl {
    
    func isLineStepped(_ step: Int) -> Bool {
        if continuousSteps { return step < selectedStep }
        return step < selectedStep || step > selectedStep
    }
    
    func lineFillColor(for step: Int) -> CGColor {
        return isLineStepped(step) && continuousSteps ? tintColor.cgColor : tintColor.withAlphaComponent(lineAlpha).cgColor
    }
    
    func lineHeight(for step: Int) -> CGFloat {
        return (isLineStepped(step) || !continuousSteps)
            ? lineWidth : lineWidth * shrinkCoefficient
    }
    
    func lineRect(for step: Int) -> CGRect {
        let prevRect = indicatorRect(for: step)
        let nextRect = indicatorRect(for: step+1)
        let height = lineHeight(for: step)
        let tolerance: CGFloat = height * 0.1
        let minX = prevRect.maxX - tolerance + lineInset/2
        let width = nextRect.minX - minX + 2*tolerance - lineInset
        let minY = (frame.height-height)/2
        return CGRect(x: minX, y: minY, width: width, height: height)
    }
    
    func linePath(for step: Int) -> CAShapeLayer {
        let rect = lineRect(for: step)
        let path = UIBezierPath(rect: rect)
        
        let layer = CAShapeLayer()
        layer.fillColor = lineFillColor(for: step)
        layer.path = path.cgPath
        
        return layer
    }
    
}
