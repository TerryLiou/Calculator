//
//  calculateAPI.swift
//  Calculater
//
//  Created by 劉洧熏 on 2017/6/13.
//  Copyright © 2017年 劉洧熏. All rights reserved.
//

import Foundation

struct CalculateBrind3 {
    
    private var displayDigit: Double?
    var stringForLabelDisplay = ""
    var isNewDigit = false

    private enum OperationType {
        case constant(Double)
        case unaryOperator((Double) -> Double)
        case binaryOperator((Double, Double) -> Double)
        case equal
    }
    
    private let operatedSign: [String: OperationType] = [
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

    mutating func setOperand(_ digit: Double) {
        displayDigit = digit
        let arrayIndex = (prepareStringFormula.resultIsPending) ? 2: 0
        prepareStringFormula.formulaDescription[arrayIndex] = (prepareStringFormula.resultIsPending) ? String(format: "%g", digit): String(format: "%g", digit)
        stringForLabelDisplay = prepareStringFormula.formulaDescription.joined()
        isNewDigit = true
        prepareStringFormula.resultIsPending = true
//        stringForLabelDisplay = (resultIsPending) ? stringForLabelDisplay + String(format: "%g", digit) : String(format: "%g", digit)
    }
    
    private var prepareToOperate: PrepareToOperate?
    
    private struct PrepareToOperate {
        let firstOperand: Double
        let function: (Double, Double) -> Double
        
        func execute(with secendDigit: Double) -> Double {
            return function(firstOperand, secendDigit)
        }
    }

    var prepareStringFormula = PrepareStringFormula()

    struct PrepareStringFormula {
        var tmpOperand = ""
        var resultIsPending = false
        var isAdditionOrSubtractionAtFirst = false
        var isMultiplyOrDividedAtSecend = false
        var haveParentheses = false
        var formulaDescription = Array.init(repeating: "", count: 3)

        mutating func unaryFormulaCombine(by sign: String, with digit: String) -> String {
            let arrayIndex = (resultIsPending) ? 2: 0
            tmpOperand = (haveParentheses) ? tmpOperand: formulaDescription[0]
            if sign == "-" && haveParentheses {
                formulaDescription[arrayIndex] = (resultIsPending) ? digit: tmpOperand
                haveParentheses = false
            } else if sign == "-" && !haveParentheses {
                formulaDescription[arrayIndex] = (resultIsPending) ? "(-(\(digit)))": "-(\(formulaDescription[0]))"
                haveParentheses = true
            } else {
                formulaDescription[arrayIndex] = (resultIsPending) ? "\(sign)(\(digit))": "\(sign)(\(formulaDescription[0]))"
            }
            return formulaDescription.joined()
        }

        mutating func binaryFormulaCombine(by sign: String) -> String {
            isMultiplyOrDividedAtSecend = (sign == "×" || sign == "÷") ? true: false
            haveParentheses = isMultiplyOrDividedAtSecend && isAdditionOrSubtractionAtFirst
            formulaDescription[1] = sign
            if haveParentheses {
                formulaDescription[0] = "(\(formulaDescription[0]))"
            } else {
                formulaDescription[0] = (formulaDescription[0][formulaDescription[0].endIndex] == ")") ? String(formulaDescription[0].characters.dropLast(1).dropFirst(1)): formulaDescription[0]
            }
            return formulaDescription.joined()
        }

        mutating func commitFormula() {
            formulaDescription[0] = formulaDescription.joined()
            formulaDescription[1] = ""
            formulaDescription[2] = ""
            isAdditionOrSubtractionAtFirst = !isMultiplyOrDividedAtSecend
        }
    }
    
    mutating func preformOperation(by sign: String) {
        if let symbol = operatedSign[sign] {
            
            switch symbol {
                
            case .constant(let digit):
                displayDigit = digit
                let arrayIndex = (prepareStringFormula.resultIsPending) ? 2: 0
                prepareStringFormula.formulaDescription[arrayIndex] = (prepareStringFormula.resultIsPending) ? sign: sign
                stringForLabelDisplay = prepareStringFormula.formulaDescription.joined()
//                stringForLabelDisplay = (resultIsPending) ? stringForLabelDisplay + sign: sign
                prepareStringFormula.resultIsPending = true
                
            case .unaryOperator(let function):
                
                if let digit = displayDigit {
                    let tmpSign = (sign == "±") ? "-" : sign
                    displayDigit = function(digit)
//                    if prepareStringFormula.resultIsPending {
//                        stringForLabelDisplay = String(stringForLabelDisplay.characters.dropLast(String(format: "%g", digit).characters.count)) + "\(tmpSign)(\(String(format: "%g", digit)))"
//                    } else {
//                        stringForLabelDisplay = "\(tmpSign)(\(stringForLabelDisplay))"
//                    }
                    stringForLabelDisplay = prepareStringFormula.unaryFormulaCombine(by: tmpSign,
                                                                                     with: String(format: "%g", digit))
//                    prepareStringFormula.resultIsPending = false
                }
                
            case .binaryOperator(let function):
                
                if let digit = displayDigit {
//                    if stringForLabelDisplay != "" {
//                        if prepareToOperate == nil {
//                            prepareToOperate = PrepareToOperate(firstOperand: digit, function: function)
//                            prepareStringFormula.resultIsPending = true
//                        }else{
//                            displayDigit = prepareToOperate?.execute(with: displayDigit!)
//                            prepareToOperate = PrepareToOperate(firstOperand: displayDigit!, function: function)
//                        }
//
//                        if prepareStringFormula.resultIsPending {
//                            stringForLabelDisplay += sign
//                        }
//                    }

                    if isNewDigit {                     // 表示按運算符號前有輸入數字
                        if prepareToOperate == nil {    // 還沒有公式的情況
                            prepareToOperate = PrepareToOperate(firstOperand: digit, function: function)
                            stringForLabelDisplay = prepareStringFormula.binaryFormulaCombine(by: sign)
                        } else {
                            displayDigit = prepareToOperate?.execute(with: digit)
                            prepareToOperate = PrepareToOperate(firstOperand: displayDigit!, function: function)
                            prepareStringFormula.commitFormula()
                            stringForLabelDisplay = prepareStringFormula.binaryFormulaCombine(by: sign)
                        }
                        isNewDigit = false
                    } else if stringForLabelDisplay != "0" {
                        prepareToOperate = PrepareToOperate(firstOperand: displayDigit!, function: function)
                        stringForLabelDisplay = prepareStringFormula.binaryFormulaCombine(by: sign)
                    }
                    prepareStringFormula.isMultiplyOrDividedAtSecend = (sign == "×" || sign == "÷") ? true: false
                }
//
//                private mutating func executeFomula(by digit: Double) {
//                    displayDigit = prepareToOperate?.execute(with: digit)
//                    displayFormula.commit(wiht: modifyingOperater + modifyingOperand, haveParentheses: haveParentheses)
//                    frontOperattionIsAdditionOrSubtraction = !secnedOperattionIsMultiplyOrDivided
//                }

//                displayFormula.resultIsPending = true
//                if let digit = tmpOperand {
//                    //==============================判斷公式存在於否的計算邏輯============================
//                    if modifyingOperand == "" {
//                        modifyingOperand = " \(modifyDouble(digit))"
//                    }
//
//                    if prepareToOperate != nil {
//                        executeFomula(by: digit)
//                        prepareToOperate = PrepareToOperate(firstOperand: displayDigit!, function: function)
//                    } else {
//                        prepareToOperate = PrepareToOperate(firstOperand: digit, function: function)
//                        displayFormula.commit(wiht: modifyingOperand, haveParentheses: false)
//                    }
//                    modifyingOperater = " \(sign)"
//                    tmpOperand = nil
//
//                } else if stringForLabelDisplay != "0" {
//                    modifyingOperater = " \(sign)"
//                    prepareToOperate = PrepareToOperate(firstOperand: displayDigit!, function: function)
//                }
//                // =======================產生顯示公式字串的邏輯=====================================
//
//                secnedOperattionIsMultiplyOrDivided = (modifyingOperater == " ×" || modifyingOperater == " ÷") ? true: false
//                stringForLabelDisplay = displayFormula.displayFormulaSubmit(modifyingOperater,haveParentheses: haveParentheses)
//                modifyingOperand = ""
            case .equal:
                
                if prepareToOperate != nil && displayDigit != nil {
                    displayDigit = prepareToOperate?.execute(with: displayDigit!)
                    prepareToOperate = nil
                    prepareStringFormula.resultIsPending = false
                }
            }
        }
    }

    var result: Double? {
        
        get {
            return displayDigit
        }
    }
}
