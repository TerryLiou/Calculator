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

        // 用 Notification 來通知 stringForLabelDisplay 已經更新
        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: "stringFormulaNotification"),
                                               object: nil,
                                               queue: nil) { (_) in
                                                self.outputLabel.text = self.brain.stringForLabelDisplay
        }
    }
    
    private var brain = CalculateBrind2()
    var isTypingDigit = false
    var displayDigital: Double { // 呈現在計算機上的計算結果，get 時將 label 轉成 Double
        
        get {

            return Double(displayStringDigit) ?? 0
        }

        set { // 判斷輸出的數字格式是不是有多餘的 0

            outPut.text = newValue.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(newValue)): String(newValue)
        }
    }

    var displayStringDigit: String { // 處理來自 button.currentTitle 的字串資訊

        get {

            return outPut.text ?? "0"
        }
        set {

            if displayStringDigit.contains(".") && (newValue == ".") {  //避免不合法的浮點數
            } else {

                if isTypingDigit {

                    switch newValue {

                    case "←":

                        if self.displayStringDigit.characters.count == 1 {

                            outPut.text = "0"
                            isTypingDigit = false
                        } else {

                            outPut.text = String(self.displayStringDigit.characters.dropLast(1))
                        }

                    case "0":

                        if !(displayStringDigit == "0") {

                            outPut.text = displayStringDigit + newValue
                        }

                    default:
                        
                        outPut.text = displayStringDigit + newValue
                    }
                } else { // 第一次敲擊數字鍵

                    if newValue == "." { // 一開始就按下 "." 將輸出 "0."

                        outPut.text = displayStringDigit + newValue
                        isTypingDigit = true

                    } else if !(newValue == "←") { // 禁止一開始就按下修正鍵

                        outPut.text = newValue
                        isTypingDigit = true
                    }
                }
            }
        }
    }

    //MARK: - IBOutlet

    @IBOutlet weak var outPut: UILabel!
    @IBOutlet weak var outputLabel: UILabel!
    
    //MARK: - IBAction

    //所有數字和小數點的按鈕包括修正鍵
    @IBAction func pressTheButton(_ sender: UIButton) {

        if let digital = sender.currentTitle {

            displayStringDigit = digital
        }
//        brain.modifyingOperand = " \(displayStringDigit)"
    }

    //所有計算符號包括 π 和 C 的按鈕
    @IBAction func operate(_ sender: UIButton) {

        if isTypingDigit || sender.currentTitle == "C" {

            brain.setOperand(displayDigital)


            if let operatorSign = sender.currentTitle {

                brain.preformOperation(by: operatorSign)
            }

            if let result = brain.result {
                
                displayDigital = result
            }
            
            isTypingDigit = false
        }
    }

    deinit {

        NotificationCenter.default.removeObserver(self)
    }
}
