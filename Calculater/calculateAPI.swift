//
//  calculateAPI.swift
//  Calculater
//
//  Created by 劉洧熏 on 2017/6/13.
//  Copyright © 2017年 劉洧熏. All rights reserved.
//

import Foundation

struct CalculateBrind {

    //MARK: - Property

    var modifyingOperand = ""   //正在輸入中的數字，因為可能會再被編輯 (unaryOperation) 所以先暫存
    var stringForLabelDisplay = "0"
    private var frontOperattionIsAdditionOrSubtraction = false
    private var displayFormula = DisplayFormula()
    private var mathematicalFormula = ""
    private var displayDigit: Double?
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

        var mathematicalFormula = ""
        var resultIsPending = true
        var tailString: String {

            return resultIsPending ? " ..." : " ="
        }

        mutating func formulaSubmit(_ operand: String) {

            if resultIsPending {

                mathematicalFormula += operand
            } else {

                mathematicalFormula = operand
            }
        }

        mutating func displayFormulaSubmit(_ modifyingOperand: String?) -> String {

            if modifyingOperand == nil {

                return  mathematicalFormula + tailString
            } else {

                mathematicalFormula += modifyingOperand!

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
    }

    // 將待運算數字或是運算結果傳來
    mutating func setOperand(_ digit: Double) {

        displayDigit = digit
        displayFormula.resultIsPending = false
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
                        
                        displayFormula.mathematicalFormula = " \(sign)"
                    }
                    stringForLabelDisplay = displayFormula.displayFormulaSubmit(nil)
                    displayFormula.resultIsPending = false

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

                if displayFormula.resultIsPending == false {

                    displayFormula.resultIsPending = true

                    if let digit = displayDigit {

                        if frontOperattionIsAdditionOrSubtraction && (sign == "×" || sign == "÷") {

                            displayFormula.mathematicalFormula =
                                "( \(displayFormula.mathematicalFormula + modifyingOperand ) )" + " \(sign)"

                        } else {

                            displayFormula.mathematicalFormula += modifyingOperand + " \(sign)"
                        }
                        modifyingOperand = ""

                        prepareToOperate = PrepareToOperate(firstOperand: digit, function: function)
                        
                        stringForLabelDisplay = displayFormula.displayFormulaSubmit(nil)
                    }
                    frontOperattionIsAdditionOrSubtraction = (sign == "+" || sign == "-") ? true: false
                }

            case .equal:

                if prepareToOperate != nil && displayDigit != nil {

                    displayFormula.resultIsPending = false
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
