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
    private var brain = CalculateBrind3()
    var isTypingDigit = false
    var displayDigital: Double { // 呈現在計算機上的計算結果，get 時將 label 轉成 Double
        
        get {
            return Double(outPut.text!) ?? 0
        }

        set { // 判斷輸出的數字格式是不是有多餘的 0
            outPut.text = newValue.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(newValue)): String(newValue)
        }
    }
    //MARK: - IBOutlet
    @IBOutlet weak var outPut: UILabel!
    @IBOutlet weak var outputLabel: UILabel!
    //MARK: - IBAction
    @IBAction func deleteButton(_ sender: UIButton) {
        brain = CalculateBrind3()
        outPut.text = "0"
        outputLabel.text = "0"
        isTypingDigit = false
    }
    //所有數字和小數點的按鈕包括修正鍵
    @IBAction func pressTheButton(_ sender: UIButton) {

        if let digital = sender.currentTitle {
            let displayStringDigit = outPut.text!

            if displayStringDigit.contains(".") && (digital == ".") { return }

            if digital == "←" {
                outPut.text = (outPut.text?.characters.count == 1) ? "0" : String(displayStringDigit.characters.dropLast(1))
                isTypingDigit = (outPut.text == "0") ? false: true
                return
            }

            if isTypingDigit {
                outPut.text = displayStringDigit + digital
            } else {
                if digital == "0" && outPut.text == "0" { return }
                outPut.text = (digital == ".") ? displayStringDigit + digital : digital
                isTypingDigit = true
            }
        }
    }
    //所有計算符號包括 π 和 C 的按鈕
    @IBAction func operate(_ sender: UIButton) {

        if isTypingDigit {
            brain.setOperand(displayDigital)
        }

        if let operatorSign = sender.currentTitle {
            brain.preformOperation(by: operatorSign)
        }

        if let result = brain.result {
            displayDigital = result
        }

        outputLabel.text = (brain.prepareStringFormula.resultIsPending) ? brain.stringForLabelDisplay + " ..." : brain.stringForLabelDisplay + " ="
        isTypingDigit = false
    }
}
