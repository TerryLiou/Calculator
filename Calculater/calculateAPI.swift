//
//  calculateAPI.swift
//  Calculater
//
//  Created by 劉洧熏 on 2017/6/13.
//  Copyright © 2017年 劉洧熏. All rights reserved.
//

import Foundation

func singleOperate(_ sign: String, displayDigital: Double) -> Double {
    
    switch sign {
        
    case "π":
        
        return Double.pi
        
    case "√":
        
        return sqrt(displayDigital)
        
    case "cos":
        
        return cos(displayDigital)
        
    case "±":
        
        return -displayDigital

    default:
        
        return 0
    }
}

func operateBy(_ sign: String, with fristDigital: Double, and secendDigital: Double) -> Double {
    
    switch sign {
        
    case "+":
        
        return fristDigital + secendDigital
        
    case "-":
        
        return fristDigital - secendDigital
        
    case "×":
        
        return fristDigital * secendDigital
        
    case "÷":
        
        return fristDigital / secendDigital
        
    default:
        
        return 0
        
    }
}
