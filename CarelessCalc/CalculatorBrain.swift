//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Yuta Fujii on 22/01/2025.
//  Copyright © 2025 Yuta Fujii. All rights reserved.
//

import Foundation
import AVFoundation

struct CalculatorBrain {

    //MARK: Variables

    private var accumulator: Double?
    private var pendingBinaryOperation: PendingBinaryOperation?
    private var resultIsPending = false
    private var player: AVAudioPlayer?

    var description = ""
    var result: Double? { get { return accumulator } }
    var alertType: AlertType = .correct

    enum AlertType {
        case mistake
        case _2143
        case correct
    }

    //MARK: Enumerations

    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case result
    }

    private var operations: Dictionary<String, Operation> = [
        "＋" : .binaryOperation({ $0 + $1 }),
        "﹣" : .binaryOperation({ $0 - $1 }),
         "×" : .binaryOperation({ $0 * $1 }),
         "÷" : .binaryOperation({ $0 / $1 }),
         "√" : .unaryOperation({ sqrt($0) }),
         "±" : .unaryOperation({ -$0 }),
         "﹪" : .unaryOperation({ $0 / 100 }),
         "AC": .constant(0),
         "=" : .result
    ]

    //MARK: Embedded struct

    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        var hasMistake = false

        mutating func perform(with secondOperand: Double) -> Double {
            let baseResult = function(firstOperand, secondOperand) // 通常の演算結果を計算
            // 30%の確率でエラーを発生させる
            if Bool.random(probability: 0.3) {
                self.hasMistake = true
                return introduceError(to: baseResult) // 結果にエラーを導入
            }
            self.hasMistake = false
            return baseResult // 通常の演算結果を返す
        }

        /// 結果にランダムなエラーを加える
        /// - Parameter value: 元の演算結果
        /// - Returns: エラーが加えられた新しい値
        private func introduceError(to value: Double) -> Double {
            // ±5の範囲でランダムな誤差を生成
            let errorRange = -10.0...10.0
            let missValue = Int(Double.random(in: errorRange))
            return value + Double(missValue)
        }
    }

    //MARK: Functions

    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator != nil {
            accumulator = pendingBinaryOperation?.perform(with: accumulator!)
            if accumulator == 2143 {
                alertType = ._2143
            } else if pendingBinaryOperation?.hasMistake ?? false {
                alertType = .mistake
            } else {
                alertType = .correct
            }
            pendingBinaryOperation = nil
            resultIsPending = false
        }
    }

    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
                case .constant(let value):
                    accumulator = value
                    description = ""
                    alertType = .correct
                case .unaryOperation(let function):
                    if accumulator != nil {
                        let value = String(describing: accumulator!).removeAfterPointIfZero()
                        description = symbol + "(" + value.setMaxLength(of: 5) + ")" + "="
                        accumulator = function(accumulator!)
                    }
                case .binaryOperation(let function):
                    performPendingBinaryOperation()

                    if accumulator != nil {
                        if description.last == "=" {
                            description = String(describing: accumulator!).removeAfterPointIfZero().setMaxLength(of: 5) + symbol
                        } else {
                            description += symbol
                        }

                        pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!)
                        resultIsPending = true
                        accumulator = nil
                    }
                case .result:
                    performPendingBinaryOperation()

                    if !resultIsPending {
                        description += "="
                    }
            }
        }
    }

    mutating func setOperand(_ operand: Double?) {
        accumulator = operand ?? 0.0
        if !resultIsPending {
            description = String(describing: operand!).removeAfterPointIfZero().setMaxLength(of: 5)
        } else {
            description += String(describing: operand!).removeAfterPointIfZero().setMaxLength(of: 5)
        }
    }

}
