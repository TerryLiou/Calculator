//
//  ViewController.swift
//  Calculater
//
//  Created by 劉洧熏 on 2017/6/13.
//  Copyright © 2017年 劉洧熏. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    //MARK: - Property

    private var brain = CalculateBrind()
    var isTyping = false
    var isOperating = false
    var displayDigital: Double {
        
        get {
            if let digital = outPut.text {
                
                return Double(digital) ?? 0
                
            } else {
                
                return 0
            }
        }

        set {
            outPut.text = String(newValue)
        }
    }
    
    @IBOutlet weak var outPut: UILabel!
    
    //MARK: - IBAction

    @IBAction func pressTheButton(_ sender: UIButton) {  // The group of number and "."
        
        var displayNumber =  outPut.text ?? "0"
        
        if isTyping {
            
            if let digital = sender.currentTitle {
                
                if displayNumber.contains(".") && digital == "." {
                    // Avoid extra "." in displsyDigital
                } else {
                    
                    displayNumber += digital
                    outPut.text = displayNumber
                }
            }
        } else {
            
            isTyping = true
            
            if let digital = sender.currentTitle {
                
                if digital == "." {
                    
                    displayNumber += digital
                    
                } else {
                    
                    displayNumber = digital
                }
                
                outPut.text = displayNumber
            }
        }
    }
    
    @IBAction func operate(_ sender: UIButton) {

        if isTyping {

            brain.setOperand(displayDigital)
            isTyping = false
        }
        
        if let operatorSign = sender.currentTitle {

            brain.preformOperation(by: operatorSign)
        }

        if let result = brain.result {

            displayDigital = result
        }
    }
}
