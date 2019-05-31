//
//  ViewController.swift
//  DTPageControl
//
//  Created by Deivi Taka on 05/30/2019.
//  Copyright (c) 2019 Deivi Taka. All rights reserved.
//

import UIKit
import DTPageControl

class ViewController: UIViewController {
    
    @IBOutlet weak var pageControl: DTPageControl!
    
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var stepsStepper: UIStepper!
    
    @IBOutlet weak var zoomSelectedSwitch: UISwitch!
    @IBOutlet weak var zoomEffectSwitch: UISwitch!
    @IBOutlet weak var showTrackSwitch: UISwitch!
    @IBOutlet weak var continuousStepsSwitch: UISwitch!
    @IBOutlet weak var fillUnsteppedSwitch: UISwitch!
    
    @IBOutlet weak var shrinkCoeffSlider: UISlider!
    @IBOutlet weak var lineAlphaSlider: UISlider!
    @IBOutlet weak var lineWidthSlider: UISlider!
    @IBOutlet weak var lineInsetSlider: UISlider!
    @IBOutlet weak var stepSizeSlider: UISlider!
    @IBOutlet weak var stepWidthSlider: UISlider!
    @IBOutlet weak var stepAlphaSlider: UISlider!
    @IBOutlet weak var animationDurationSlider: UISlider!
    
    fileprivate lazy var switches = [zoomSelectedSwitch, zoomEffectSwitch, showTrackSwitch,
                                     continuousStepsSwitch, fillUnsteppedSwitch]
    fileprivate lazy var sliders = [shrinkCoeffSlider, lineAlphaSlider, lineWidthSlider,
                                    lineInsetSlider, stepSizeSlider, stepWidthSlider,
                                    stepAlphaSlider, animationDurationSlider]
    fileprivate lazy var steppers = [stepsStepper]
    fileprivate lazy var buttons = [previousButton, nextButton]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

// MARK:- Private
fileprivate extension ViewController {
    
    func setup() {
        // Buttons
        buttons.forEach {
            $0?.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        }
        
        // Steppers
        let doubleValues = [pageControl.steps]
        for i in 0..<steppers.count {
            steppers[i]?.value = Double(doubleValues[i])
            steppers[i]?.addTarget(self, action: #selector(stepperValueChanged), for: .valueChanged)
        }
        
        // Switches
        let boolValues = [pageControl.zoomSelected, pageControl.zoomEffect, pageControl.showTrack, pageControl.continuousSteps, pageControl.fillUnstepped]
        for i in 0..<switches.count {
            switches[i]?.isOn = boolValues[i]
            switches[i]?.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        }
        
        // Sliders
        let floatValues = [pageControl.shrinkCoefficient, pageControl.lineAlpha, pageControl.lineWidth, pageControl.lineInset, pageControl.indicatorSize, pageControl.stepAlpha, pageControl.stepWidth, CGFloat(pageControl.animationDuration)]
        for i in 0..<sliders.count {
            sliders[i]?.value = Float(floatValues[i])
            sliders[i]?.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        }
    }
    
}

// MARK:- Actions
extension ViewController {
    
    @objc func buttonClicked(_ sender: UIButton) {
        let step: Int
        switch sender {
        case previousButton: step = -1
        case nextButton: step = 1
        default: step = 0
        }
        pageControl.selectedStep += step
    }
    
    @objc func sliderValueChanged(_ sender: UISlider) {
        func set(_ param: inout CGFloat) { param = CGFloat(sender.value) }
        func setDouble(_ param: inout Double) { param = Double(sender.value) }
        
        switch sender {
        case shrinkCoeffSlider: set(&pageControl.shrinkCoefficient)
        case lineAlphaSlider: set(&pageControl.lineAlpha)
        case lineWidthSlider: set(&pageControl.lineWidth)
        case lineInsetSlider: set(&pageControl.lineInset)
        case stepSizeSlider: set(&pageControl.indicatorSize)
        case stepWidthSlider: set(&pageControl.stepWidth)
        case stepAlphaSlider: set(&pageControl.stepAlpha)
        case animationDurationSlider: setDouble(&pageControl.animationDuration)
        default: break
        }
    }
    
    @objc func switchValueChanged(_ sender: UISwitch) {
        let val = sender.isOn
        switch sender {
        case zoomSelectedSwitch: pageControl.zoomSelected = val
        case zoomEffectSwitch: pageControl.zoomEffect = val
        case showTrackSwitch: pageControl.showTrack = val
        case continuousStepsSwitch: pageControl.continuousSteps = val
        case fillUnsteppedSwitch: pageControl.fillUnstepped = val
        default: break
        }
    }
    
    @objc func stepperValueChanged(_ sender: UIStepper) {
        func set(_ param: inout Int) { param = Int(sender.value) }
        
        switch sender {
        case stepsStepper: set(&pageControl.steps)
        default: break
        }
    }
    
}
