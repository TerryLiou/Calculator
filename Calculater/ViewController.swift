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

    var isTyping = false
    var isOperating = false
    var operatorSign: String = ""
    var fristDigital: Double = 0
    var secendDigital: Double = 0
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
                    secendDigital = Double(displayNumber) ?? 0
                    
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
                secendDigital = Double(displayNumber) ?? 0
            }
        }
    }
    
    @IBAction func operate(_ sender: UIButton) {
        
        isTyping = false
        
        if let operatorSign = sender.currentTitle {
            
            displayDigital = singleOperate(operatorSign, displayDigital: displayDigital)
            
        }
    }
    
    @IBAction func binaryOperate(_ sender: UIButton) {

        isTyping = false

        if let binaryOperator = sender.currentTitle {
            
            switch binaryOperator {
                
            case "=":
                
                displayDigital = operateBy(operatorSign, with: fristDigital, and: secendDigital)
                isOperating = false
                
            default:

                if isOperating {
                 
                    displayDigital = operateBy(operatorSign, with: fristDigital, and: secendDigital)
                    
                }

                fristDigital = displayDigital
                operatorSign = binaryOperator
                isOperating = true
            }
        }
    }
}
