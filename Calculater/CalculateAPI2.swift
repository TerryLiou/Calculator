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

    var modifyingOperand = ""            // 正在輸入中的數字，因為可能會再被編輯 (unaryOperation) 所以先暫存
    var stringForLabelDisplay = "0"      // 將要在 UI 上呈現的算式
    private var isConstant = false
    private var frontOperattionIsAdditionOrSubtraction = false
    private var displayFormula = DisplayFormula()
    private var mathematicalFormula = ""
    private var displayDigit: Double?
    private var binaryOperand: Double?
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
        var resultIsPending = false
        var tailString: String {

            return resultIsPending ? " ..." : " ="
        }
        //
        //        mutating func formulaSubmit(_ operand: String) {
        //
        //            if resultIsPending {
        //
        //                mathematicalFormula += operand
        //            } else {
        //
        //                mathematicalFormula = operand
        //            }
        //        }
        // stringForLabelDisplay 由 mathematicalFormula 和 modifyingOperand 和 tailString 組成
        mutating func displayFormulaSubmit(_ tmpOperand: String?) -> String {

            if tmpOperand == nil {

                return  mathematicalFormula + tailString
            } else {

                mathematicalFormula += tmpOperand!


                return  mathematicalFormula + tailString
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

        return digit.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(digit)): String(digit)
    }

    private mutating func reset() {

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
            modifyingOperand = modifyDouble(digit)
        }

        displayDigit = digit
        binaryOperand = digit
        displayFormula.resultIsPending = true
    }

    // 所有運算符號的判斷
    mutating func preformOperation(by sign: String) {

        if let symbol = operatedSign[sign] {

            switch symbol {

            case .constant(let digit):

                switch sign {

                case "π":

                    if displayFormula.resultIsPending {

                        displayFormula.mathematicalFormula += " \(sign)"
                    } else {

                        prepareToOperate = nil
                        displayFormula.mathematicalFormula = " \(sign)"
                    }
                    stringForLabelDisplay = displayFormula.displayFormulaSubmit(nil)
                    displayFormula.resultIsPending = false
                    isConstant = true

                case "C":

                    reset()
                default:

                    break
                }
                displayDigit = digit

            case .unaryOperator(let function):

                if let digit = displayDigit {

                    switch sign {

                    case "±":

                        if displayFormula.resultIsPending {

                            modifyingOperand = " (-( \(modifyDouble(digit))))"

                        } else {

                            displayFormula.mathematicalFormula = " -(\(displayFormula.mathematicalFormula + modifyingOperand) )"

                            stringForLabelDisplay = displayFormula.displayFormulaSubmit(nil)

                            modifyingOperand = ""
                        }
                    default:

                        if displayFormula.resultIsPending {

                            modifyingOperand = " \(sign)(\(modifyDouble(digit)) )"

                        } else {

                            displayFormula.mathematicalFormula = " \(sign)(\(displayFormula.mathematicalFormula + modifyingOperand) )"

                            stringForLabelDisplay = displayFormula.displayFormulaSubmit(nil)

                            modifyingOperand = ""
                        }
                    }
                    displayDigit = function(digit)
                }

            case .binaryOperator(let function):

                if let digit = binaryOperand {
                    //==============================判斷公式存在於否的計算邏輯============================
                    if prepareToOperate != nil {

                        displayDigit = prepareToOperate?.execute(with: digit)
                        prepareToOperate = PrepareToOperate(firstOperand: displayDigit!, function: function)

                    } else {

                        prepareToOperate = PrepareToOperate(firstOperand: digit, function: function)
                    }
                    // =======================產生顯示公式字串的邏輯=====================================
                    if frontOperattionIsAdditionOrSubtraction && (sign == "×" || sign == "÷") {

                        displayFormula.mathematicalFormula =
                            "( \(displayFormula.mathematicalFormula + modifyingOperand ) )" + " \(sign)"

                    } else {

                        displayFormula.mathematicalFormula += modifyingOperand + " \(sign)"
                    }
                    modifyingOperand = ""
                    stringForLabelDisplay = displayFormula.displayFormulaSubmit(nil)
                    // ==============================================================================
                } else {

                    prepareToOperate = PrepareToOperate(firstOperand: displayDigit!, function: function)
                }
                frontOperattionIsAdditionOrSubtraction = (sign == "+" || sign == "-") ? true: false
                
            case .equal:
                
                if prepareToOperate != nil && displayDigit != nil && displayFormula.resultIsPending == false {
                    
                    displayDigit = prepareToOperate?.execute(with: displayDigit!)
                    prepareToOperate = nil
                    stringForLabelDisplay = displayFormula.displayFormulaSubmit(modifyingOperand)
                    modifyingOperand = ""
                }
            }
            NotificationCenter.default.post(name: Notification.Name(rawValue: "stringFormulaNotification"),
                                            object: nil)
        }
    }
    
    var result: Double? { return displayDigit }
}
