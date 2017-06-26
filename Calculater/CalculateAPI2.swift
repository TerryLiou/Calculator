//
//  CalculateAPI2.swift
//  Calculater
//
//  Created by 劉洧熏 on 2017/6/21.
//  Copyright © 2017年 劉洧熏. All rights reserved.
//

import Foundation

struct CalculateBrind2 {

    //MARK: - Property

    private var modifyingOperater = ""           // 運算符號的站暫存
    private var modifyingOperand = ""            // 正在輸入中的數字，因為可能會再被編輯 (unaryOperation) 所以先暫存
    var stringForLabelDisplay = "0"              // 將要在 UI 上呈現的算式
    private var frontOperattionIsAdditionOrSubtraction = false
    private var secnedOperattionIsMultiplyOrDivided = false
    private var haveParentheses: Bool{
        return frontOperattionIsAdditionOrSubtraction && secnedOperattionIsMultiplyOrDivided
    }
    private var displayFormula = DisplayFormula()
    private var displayDigit: Double?            // 計算結果
    private var tmpOperand: Double?              // 暫存輸入計算元
    private var prepareToOperate: PrepareToOperate?

    // 處理二元運算子
    private struct PrepareToOperate {

        let firstOperand: Double
        let function: (Double, Double) -> Double

        func execute(with secendDigit: Double) -> Double {

            return function(firstOperand, secendDigit)
        }
    }
    // 處理字串算式
    private struct DisplayFormula {

        var mathematicalFormula = ""    // 已確定執行的公式

//        var tailString: String {
//
//            return resultIsPending ? " ..." : " ="
//        }

        var tailString: String = ""

        var resultIsPending = false {
            didSet {
                tailString = resultIsPending ? "..." : " ="
            }
        }

        mutating func commit(wiht modifyOperand: String, haveParentheses: Bool) {

            if haveParentheses {
                mathematicalFormula = "(\(mathematicalFormula)) \(modifyOperand)"
            } else {
                mathematicalFormula += modifyOperand
            }
        }

        mutating func displayFormulaSubmit(_ tmp: String?, haveParentheses: Bool) -> String {

            if tmp == nil {

                return  mathematicalFormula + tailString
            } else {

                if haveParentheses {

                    return "(\(mathematicalFormula))" + tmp! + tailString
                } else {

                    return mathematicalFormula + tmp! + tailString
                }
            }
        }
    }

    private enum OperationType {

        case constant(Double)
        case unaryOperator((Double) -> Double)
        case binaryOperator((Double, Double) -> Double)
        case equal
    }

    private let operatedSign: [String: OperationType] = [

        "C": OperationType.constant(0),
        "π": OperationType.constant(Double.pi),
        "cos": OperationType.unaryOperator(cos),
        "√": OperationType.unaryOperator(sqrt),
        "±": OperationType.unaryOperator({-$0}),
        "×": OperationType.binaryOperator({$0 * $1}),
        "÷": OperationType.binaryOperator({$0 / $1}),
        "+": OperationType.binaryOperator({$0 + $1}),
        "-": OperationType.binaryOperator({$0 - $1}),
        "=": OperationType.equal
    ]

    //MARK: - Functions

    // 將 Double 後方的無效數字消除 ex: 2.30 -> 2.3
    func modifyDouble(_ digit: Double) -> String {

        if digit / Double.pi == 1 {

            return "π"
        } else {

            return digit.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(digit)): String(digit)
        }
    }

    private mutating func executeFomula(by digit: Double) {

        displayDigit = prepareToOperate?.execute(with: digit)
        displayFormula.commit(wiht: modifyingOperater + modifyingOperand, haveParentheses: haveParentheses)
        frontOperattionIsAdditionOrSubtraction = !secnedOperattionIsMultiplyOrDivided
    }

    private mutating func reset() {

        modifyingOperater = ""
        modifyingOperand = ""
        frontOperattionIsAdditionOrSubtraction = false
        displayDigit = nil
        stringForLabelDisplay = "0"
        displayFormula = DisplayFormula()
        prepareToOperate = nil
    }
    // 將待運算數字或是運算結果傳來
    mutating func setOperand(_ digit: Double) {
        // 當不在運算式當中輸入新的數字時，判斷為新的算式，將 displayFormula 重置
        if !displayFormula.resultIsPending {

            displayFormula = DisplayFormula()
            displayFormula.resultIsPending = true
        }
        displayDigit = digit
        tmpOperand = digit
    }

    // 所有運算符號的判斷
    mutating func preformOperation(by sign: String) {

        if let symbol = operatedSign[sign] {

            switch symbol {

            case .constant(let digit):

                if !displayFormula.resultIsPending {

                    displayFormula = DisplayFormula()
                    displayFormula.resultIsPending = true
                }
                switch sign {

                case "π":

                    modifyingOperand = " \(sign)"
                    stringForLabelDisplay = displayFormula.displayFormulaSubmit("\(modifyingOperater) \(sign)", haveParentheses: false)
                case "C":

                    reset()
                default:

                    break
                }
                displayDigit = digit
                tmpOperand = digit

            case .unaryOperator(let function):

                if let digit = displayDigit {

                    switch sign {

                    case "±":
                        // =======================產生顯示公式字串的邏輯=====================================
                        if let digit = tmpOperand {

                            modifyingOperand = modifyingOperand.contains("(-(") ?  " \(modifyDouble(digit))": " (-( \(modifyDouble(digit))))"
                            stringForLabelDisplay = displayFormula.displayFormulaSubmit(modifyingOperater + modifyingOperand, haveParentheses: haveParentheses)
                            tmpOperand = function(digit)
                        } else {

                            displayFormula.mathematicalFormula = "-( \(displayFormula.mathematicalFormula) )"
                            stringForLabelDisplay =
                                displayFormula.displayFormulaSubmit(modifyingOperater, haveParentheses: haveParentheses)
                        }
                    default:
                        
                        if let digit = tmpOperand {

                            modifyingOperand =
                                modifyingOperand == "" ? " \(sign)(\(modifyDouble(digit)) )" : " \(sign)(\(modifyingOperand))"
                            stringForLabelDisplay = displayFormula.displayFormulaSubmit(modifyingOperater + modifyingOperand, haveParentheses: haveParentheses)
                            tmpOperand = function(digit)
                        } else {

                            displayFormula.mathematicalFormula = " \(sign)(\(displayFormula.mathematicalFormula))"
                            stringForLabelDisplay =
                                displayFormula.displayFormulaSubmit(modifyingOperater, haveParentheses: haveParentheses)
                        }
                    }
                    // ==============================================================================
                    displayDigit = function(digit)
                }
            case .binaryOperator(let function):

                displayFormula.resultIsPending = true
                if let digit = tmpOperand {
                    //==============================判斷公式存在於否的計算邏輯============================
                    if modifyingOperand == "" {

                        modifyingOperand = " \(modifyDouble(digit))"
                    }

                    if prepareToOperate != nil {

                        executeFomula(by: digit)
                        prepareToOperate = PrepareToOperate(firstOperand: displayDigit!, function: function)
                    } else {

                        prepareToOperate = PrepareToOperate(firstOperand: digit, function: function)
                        displayFormula.commit(wiht: modifyingOperand, haveParentheses: false)
                    }
                    modifyingOperater = " \(sign)"
                    tmpOperand = nil

                } else if stringForLabelDisplay != "0" {
                    modifyingOperater = " \(sign)"
                    prepareToOperate = PrepareToOperate(firstOperand: displayDigit!, function: function)
                }
                    // =======================產生顯示公式字串的邏輯=====================================

                secnedOperattionIsMultiplyOrDivided = (modifyingOperater == " ×" || modifyingOperater == " ÷") ? true: false
                stringForLabelDisplay = displayFormula.displayFormulaSubmit(modifyingOperater,haveParentheses: haveParentheses)
                modifyingOperand = ""
                    // ==============================================================================
            case .equal:

                if prepareToOperate != nil && displayDigit != nil && displayFormula.resultIsPending == true && tmpOperand != nil{

                    if modifyingOperand == "" {

                        modifyingOperand = " \(modifyDouble(displayDigit!))"
                    }
                    displayFormula.resultIsPending = false
                    executeFomula(by: displayDigit!)
                    modifyingOperand = ""
                    modifyingOperater = ""
                    stringForLabelDisplay = displayFormula.displayFormulaSubmit(nil, haveParentheses: haveParentheses)
                    prepareToOperate = nil
                    tmpOperand = nil
                }
            }
            NotificationCenter.default.post(name: Notification.Name(rawValue: "stringFormulaNotification"),
                                            object: nil)
        }
    }
    var result: Double? { return displayDigit }
}
