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

            guard let digital = outPut.text else { return 0 }

            return Double(digital) ?? 0
        }

        set {

            outPut.text = newValue.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(newValue)): String(newValue)

        }
    }
    
    @IBOutlet weak var outPut: UILabel!
    @IBOutlet weak var outputLabel: UILabel!
    
    //MARK: - IBAction

    @IBAction func pressTheButton(_ sender: UIButton) {  // The group of number and "."

        var displayStringDigit: String {

            get {

                return outPut.text ?? "0"
            }

            set {

                if isTyping {

                    outPut.text = displayStringDigit + newValue

                } else {

                    if newValue == "." {

                        outPut.text = displayStringDigit + newValue

                    } else {

                        isTyping = true
                        outPut.text = newValue
                    }

                }
            }
        }

        if isTyping {

            if let digital = sender.currentTitle {

                switch digital {

                case "0":

                    if !(displayStringDigit == "0") {

                        displayStringDigit = digital

                    }
                case ".":

                    if !displayStringDigit.contains(".") {

                        displayStringDigit = digital
                    }

                default:

                    displayStringDigit = digital
                }
            }

        } else {

            if let digital = sender.currentTitle {

                if !displayStringDigit.contains(".") && !(digital == ".") {

                    displayStringDigit = digital
                }
            }
        }
    }
    
    @IBAction func operate(_ sender: UIButton) {

        if isTyping {

            brain.setOperand(displayDigital)
//            isTyping = false
        }
        
        if let operatorSign = sender.currentTitle {

            brain.preformOperation(by: operatorSign)
        }

        if let result = brain.result {

            displayDigital = result
            isTyping = false
        }
    }
}
