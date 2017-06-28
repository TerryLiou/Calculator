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
        if prepareStringFormula.resultIsPending {
            prepareStringFormula.formulaDescription[2] = String(format: "%g", digit)
        } else {
            prepareStringFormula.formulaDescription[0] = String(format: "%g", digit)
        }
        stringForLabelDisplay = prepareStringFormula.formulaDescription.joined()
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
        var resultIsPending = false
        var isAdditionOrSubtractionAtFirst = false
        var isMultiplyOrDividedAtSecend = false
        var haveParentheses = false
        var formulaDescription = Array.init(repeating: "", count: 3)

        func removeParentheses(_ digit: String) -> String {
            return digit.replacingOccurrences(of: "(-(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: "-(", with: "").replacingOccurrences(of: "(", with: "")
        }

        mutating func unaryFormulaCombine(by sign: String, with digit: String) -> String {
            let arrayIndex = (resultIsPending) ? 2: 0
            if sign == "-" && haveParentheses {
                formulaDescription[arrayIndex] = (resultIsPending) ? digit: removeParentheses(formulaDescription[arrayIndex])
                haveParentheses = false
            } else if sign == "-" && !haveParentheses {
                formulaDescription[arrayIndex] = (resultIsPending) ? "(-(\(digit)))": "-(\(formulaDescription[0]))"
                haveParentheses = true
            } else {
                formulaDescription[arrayIndex] = (resultIsPending) ? "\(sign)(\(digit))": "\(sign)(\(formulaDescription[0]))"
            }
            return formulaDescription.joined()
        }
    }
    
    mutating func preformOperation(by sign: String) {
        
        if let symbol = operatedSign[sign] {
            
            switch symbol {
                
            case .constant(let digit):
                displayDigit = digit

                if prepareStringFormula.resultIsPending {
                    prepareStringFormula.formulaDescription[2] = sign
                } else {
                    prepareStringFormula.formulaDescription[0] = sign
                }

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
                    prepareStringFormula.resultIsPending = false
                }
                
            case .binaryOperator(let function):
                
                if let digit = displayDigit {
                    if stringForLabelDisplay != "" {
                        if prepareToOperate == nil {
                            prepareToOperate = PrepareToOperate(firstOperand: digit, function: function)
                            prepareStringFormula.resultIsPending = true
                        }else{
                            displayDigit = prepareToOperate?.execute(with: displayDigit!)
                            prepareToOperate = PrepareToOperate(firstOperand: displayDigit!, function: function)
                        }
                        if prepareStringFormula.resultIsPending {
                            stringForLabelDisplay += sign
                        }
                    }
                }
                
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
