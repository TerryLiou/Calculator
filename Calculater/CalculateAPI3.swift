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
    var resultIsPending = false

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
        stringForLabelDisplay += String(format: "%g", digit)
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
                resultIsPending = true
                
            case .unaryOperator(let function):
                
                if let digit = displayDigit {
                    let tmpSign = (sign == "±") ? "-" : sign
                    displayDigit = function(digit)

                    if resultIsPending {

                    } else {
                        stringForLabelDisplay = "\(tmpSign)(\(stringForLabelDisplay))"
                        resultIsPending = false
                    }

                }
                
            case .binaryOperator(let function):
                
                if let digit = displayDigit {
                    if prepareToOperate == nil {
                        prepareToOperate = PrepareToOperate(firstOperand: digit, function: function)
                        resultIsPending = true
                    }else{
                        displayDigit = prepareToOperate?.execute(with: displayDigit!)
                        prepareToOperate = nil
                        resultIsPending = false
                    }
                }
                
            case .equal:
                
                if prepareToOperate != nil && displayDigit != nil {
                    displayDigit = prepareToOperate?.execute(with: displayDigit!)
                    prepareToOperate = nil
                    resultIsPending = false
                }
            }
            
            if resultIsPending {
                stringForLabelDisplay += sign
            }
        }
    }
    
    var result: Double? {
        
        get {
            return displayDigit
        }
    }
}
