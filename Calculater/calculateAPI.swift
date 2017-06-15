//
//  calculateAPI.swift
//  Calculater
//
//  Created by 劉洧熏 on 2017/6/13.
//  Copyright © 2017年 劉洧熏. All rights reserved.
//

import Foundation

struct CalculateBrind {

    private var displayDigit: Double?

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

    mutating func setOperand(_ digit: Double) {

        displayDigit = digit
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

                displayDigit = digit

            case .unaryOperator(let function):

                if let digit = displayDigit {

                    displayDigit = function(digit)
                }

            case .binaryOperator(let function):

                if let digit = displayDigit {

                    prepareToOperate = PrepareToOperate(firstOperand: digit, function: function)
                }

            case .equal:

                if prepareToOperate != nil && displayDigit != nil {

                    displayDigit = prepareToOperate?.execute(with: displayDigit!)
                    prepareToOperate = nil
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















