//
//  Extensions.swift
//  Calculator
//
//  Created by Yuta Fujii on 22/01/2025.
//  Copyright © 2025 Yuta Fujii. All rights reserved.
//

import Foundation

/*
 * Useful functions for the manipulation of the strings (values) which we put on the calculator display.
 * Instead of using the NumberFormatter object I preferred to format the strings manually and make a simple exercise
 * on doing some extensions.
 */
 
 public extension String {
    
    // set the max length of the number to display
    func setMaxLength(of maxLength: Int) -> String {
        var tmp = self
        
        if tmp.count > maxLength {
            var numbers = tmp.map({$0})
            
            if numbers[maxLength - 1] == "." {
                numbers.removeSubrange(maxLength+1..<numbers.endIndex)
            } else {
                numbers.removeSubrange(maxLength..<numbers.endIndex)
            }
            
            tmp = String(numbers)
        }
        return tmp
    }
    
    // remove the '.0' when the number is not decimal
    func removeAfterPointIfZero() -> String {
        let token = self.components(separatedBy: ".")
        
        if !token.isEmpty && token.count == 2 {
            switch token[1] {
            case "0", "00", "000", "0000", "00000", "000000":
                return token[0]
            default:
                return self
            }
        }
        return self
    }
}

extension Bool {
    /// 指定した確率で真偽値を返す
    /// - Parameter probability: 真を返す確率（0.0〜1.0）
    /// - Returns: 真または偽
    static func random(probability: Double) -> Bool {
        return Double.random(in: 0...1) < probability
    }
}
