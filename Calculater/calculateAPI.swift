//
//  calculateAPI.swift
//  Calculater
//
//  Created by 劉洧熏 on 2017/6/13.
//  Copyright © 2017年 劉洧熏. All rights reserved.
//

import Foundation

struct CalculateBrind {

    var stringOperand = ""

    private var nextOperand = ""

    private var mathematicalFormula = ""

    private var displayDigit: Double?

    private var resultIsPending = false

    private var tailString: String {

        return resultIsPending ? " ..." : " ="
    }

    private var stringForLabelDisplay: String?

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

    func modifyDouble(_ digit: Double) -> String {

        return digit.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(digit)): String(digit)
    }

    mutating func setOperand(_ digit: Double) {

//        mathematicalFormula += stringOperand

        displayDigit = digit

//        stringOperand = ""
    }

    private var prepareToOperate: PrepareToOperate?

    private struct PrepareToOperate {

        let firstOperand: Double

        let function: (Double, Double) -> Double

        func execute(with secendDigit: Double) -> Double {

            return function(firstOperand, secendDigit)
        }
    }

    mutating func preformOperation(by sign: String) {

        if let symbol = operatedSign[sign] {

            switch symbol {

            case .constant(let digit):

                switch sign {

                case "π":

                    if resultIsPending {

                        mathematicalFormula += " \(sign)"

                    } else {

                        mathematicalFormula = " \(sign)"
                    }
                    stringForLabelDisplay = mathematicalFormula + tailString

                case "C":

                    displayDigit = nil

                    mathematicalFormula = ""
                    
                default:
                    
                    break
                }
                resultIsPending = false
                
                displayDigit = digit

            case .unaryOperator(let function):

                if let digit = displayDigit {

                    switch sign {

                    case "±":

                        if resultIsPending {

                            stringOperand = " (-( \(modifyDouble(digit))))"

                        } else {

                            mathematicalFormula = " -(\(mathematicalFormula + stringOperand) )"

                            stringForLabelDisplay = mathematicalFormula + tailString

                            stringOperand = ""
                        }
                    default:

                        if resultIsPending {

                            stringOperand = " \(sign)(\(modifyDouble(digit)) )"

                        } else {

                            mathematicalFormula = " \(sign)(\(mathematicalFormula + stringOperand) )"

                            stringForLabelDisplay = mathematicalFormula + tailString

                            stringOperand = ""
                        }
                    }

                    displayDigit = function(digit)
                }

            case .binaryOperator(let function):

                resultIsPending = true

                if let digit = displayDigit {

                    mathematicalFormula += stringOperand + " \(sign)"

                    stringOperand = ""

                    prepareToOperate = PrepareToOperate(firstOperand: digit, function: function)

                    stringForLabelDisplay = mathematicalFormula + tailString
                }

            case .equal:

                if prepareToOperate != nil && displayDigit != nil {

                    resultIsPending = false

                    displayDigit = prepareToOperate?.execute(with: displayDigit!)

                    prepareToOperate = nil

                    mathematicalFormula += stringOperand

                    stringForLabelDisplay = mathematicalFormula + tailString

                    stringOperand = ""
                }
            }

            print(stringForLabelDisplay ?? "nothing to print")
        }
    }

    var result: Double? {

        get {

                return displayDigit
        }
    }
}
