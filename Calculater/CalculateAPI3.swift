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

    struct PrepareStringFormula {                                                           // 處理字串顯示的 struct
        var tmpOperand = ""
        var resultIsPending = false
        var isAdditionOrSubtractionAtFirst = false
        var isMultiplyOrDividedAtSecend = false
        var haveParentheses = false
        var formulaDescription = Array.init(repeating: "", count: 3)

        mutating func unaryFormulaCombine(by sign: String) -> String {                      // 處理一元運算子的 func
            let arrayIndex = (resultIsPending) ? 2: 0
            tmpOperand = (haveParentheses) ? tmpOperand: formulaDescription[arrayIndex]     // 趁運算數未被括號處理前存起來

            if sign == "-" && haveParentheses {              // 當字串已經有括號，表示第二次按需要去括號
                formulaDescription[arrayIndex] = tmpOperand
                haveParentheses = false
            } else if sign == "-" && !haveParentheses {      // 變號鍵的特性第一次按一定要加上括號
                formulaDescription[arrayIndex] = (resultIsPending) ? "(-(\(tmpOperand)))": "-(\(tmpOperand))"
                haveParentheses = true
            } else {
                tmpOperand = formulaDescription[arrayIndex]  // 按下其他一元運算子表示正負號已經確定，將暫存更新
                formulaDescription[arrayIndex] = "\(sign)(\(formulaDescription[arrayIndex]))"
                haveParentheses = false
            }

            return formulaDescription.joined()
        }

        mutating func binaryFormulaCombine(by sign: String) -> String {
            let isContainParentheses = formulaDescription[0].characters.last == ")" && formulaDescription[0].characters.first == "(" // 判斷字串是否含有括號
            isMultiplyOrDividedAtSecend = (sign == "×" || sign == "÷") ? true: false
            haveParentheses = isMultiplyOrDividedAtSecend && isAdditionOrSubtractionAtFirst  // 判斷先乘除後加減
            formulaDescription[1] = sign

            if haveParentheses {
                formulaDescription[0] = (isContainParentheses) ? formulaDescription[0]: "(\(formulaDescription[0]))"
            } else {
                formulaDescription[0] = (isContainParentheses) ? String(formulaDescription[0].characters.dropLast(1).dropFirst(1)): formulaDescription[0]
            }

            return formulaDescription.joined()
        }

        mutating func commitFormula() {
            formulaDescription[0] = formulaDescription.joined()
            formulaDescription[1] = ""
            formulaDescription[2] = ""
            isAdditionOrSubtractionAtFirst = !isMultiplyOrDividedAtSecend
        }   // 在確認計算後，從前一次 isMultiplyOrDividedAtSecend 的判斷來確定 isAdditionOrSubtractionAtFirst的值
    }
    
    mutating func preformOperation(by sign: String) {

        if let symbol = operatedSign[sign] {
            switch symbol {
            case .constant(let digit):
                displayDigit = digit
                let arrayIndex = (prepareStringFormula.resultIsPending) ? 2: 0
                prepareStringFormula.formulaDescription[arrayIndex] = (prepareStringFormula.resultIsPending) ? sign: sign
                stringForLabelDisplay = prepareStringFormula.formulaDescription.joined()
                isNewDigit = true
                
            case .unaryOperator(let function):

                if isNewDigit {
                    if let digit = displayDigit {
                        let tmpSign = (sign == "±") ? "-" : sign
                        displayDigit = function(digit)
                        stringForLabelDisplay = prepareStringFormula.unaryFormulaCombine(by: tmpSign)
                    }
                }
                
            case .binaryOperator(let function):

                if let digit = displayDigit {
                    prepareStringFormula.resultIsPending = true
                    if isNewDigit {                     // 表示按運算符號前有輸入數字
                        if prepareToOperate == nil {    // 還沒有公式的情況
                            prepareToOperate = PrepareToOperate(firstOperand: digit, function: function)        // 產生輸入數字和算符的公式
                        } else {
                            displayDigit = prepareToOperate?.execute(with: digit)                               // 先前產生的公式實行運算
                            prepareToOperate = PrepareToOperate(firstOperand: displayDigit!, function: function)// 產生運算結果和算符的公式
                            prepareStringFormula.commitFormula()                                                // 計算完後將字串組合
                        }
                        isNewDigit = false
                    } else if stringForLabelDisplay != "0" {
                        prepareToOperate = PrepareToOperate(firstOperand: displayDigit!, function: function)    // 重複按下二元運算子時重新產生公式
                    }
                    stringForLabelDisplay = prepareStringFormula.binaryFormulaCombine(by: sign)                 // 秀出公式
                    prepareStringFormula.isMultiplyOrDividedAtSecend = (sign == "×" || sign == "÷") ? true: false
                }

            case .equal:
                
                if prepareToOperate != nil && displayDigit != nil {
                    displayDigit = prepareToOperate?.execute(with: displayDigit!)
                    prepareStringFormula.commitFormula()
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
