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

    override func viewDidLoad() {

        super.viewDidLoad()

        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: "stringFormulaNotification"),
                                               object: nil,
                                               queue: nil) { (_) in
                                                self.outputLabel.text = self.brain.stringForLabelDisplay
        }

    }
    
    private var brain = CalculateBrind()

    var isTyping = false
    
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

                if displayStringDigit.contains(".") && (newValue == ".") {
                } else {

                    if isTyping {

                        outPut.text = displayStringDigit + newValue

                    } else {

                        if newValue == "." {

                            outPut.text = displayStringDigit + newValue

                        } else {

                            outPut.text = newValue
                        }
                        isTyping = true
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

                displayStringDigit = digital
            }
        }

        brain.modifyingOperand = " \(displayStringDigit)"
    }
    
    @IBAction func operate(_ sender: UIButton) {

        isTyping = false

        brain.setOperand(displayDigital)
        
        if let operatorSign = sender.currentTitle {

            brain.preformOperation(by: operatorSign)
        }
        if let result = brain.result {

            displayDigital = result
        }
    }

    deinit {

        NotificationCenter.default.removeObserver(self)
    }
}
