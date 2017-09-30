//
//  CalcBrain.swift
//  calk
//
//  Created by Kam Lotfull on 02.01.17.
//  Copyright © 2017 Kam Lotfull. All rights reserved.
//

import Foundation

enum Optional<T> {
    case None
    case Some(T)
}

/*func multiply(op1: Double, op2: Double) -> Double {
 return op1 * op2
 }*/
func factorial(op1: Double) -> Double {
    var answer: Double = 1;
    var i: Double = op1
    if op1 > 1 {
        while i > 1 {
            answer *= i
            i -= 1
        }
    }
    return answer
}

class CalcBrain {
    
    var isPartialResult: Bool {
        get {
            return pending != nil
        }
    }
    
    func addUnaryOperation(symbol: String, _ operation: @escaping (Double) -> Double) {
        operations[symbol] = OperationType.UnaryOperation(operation, {"\(symbol)(" + $0 + ")"})
    }
    
    private var accumulator: Double = 0
    
    private var internalProgram = [AnyObject]()
    
    var description: String {
        get {
            if pending == nil { // если не ожидается второй аргумент "1 + ...)
                return descriptionAccumulator
            } else {// вывести оператор операции или если он уже выведен - вывести ничего
                return pending!.descriptionFunction(pending!.descriptionOperand,
                                                    pending!.descriptionOperand != descriptionAccumulator ? descriptionAccumulator : "")
            }
        }
    }
    
    private var descriptionAccumulator = "0" {
        didSet {
            if pending == nil {
                currentPrority = Int.max
            }
        }
    }
    
    func setOperand(_ operand: Double) {
        accumulator = operand
        internalProgram.append(operand as AnyObject)
        descriptionAccumulator = String(format: "%g", operand)
    }
    
    private var operations: [String : OperationType] = [
        "π" : OperationType.Constant(Double.pi),
        "e" : OperationType.Constant(M_E),
        "rand" : OperationType.Random({return drand48()}),
        //"C" : OperationType.UnaryOperation( {_ in return 0} ),
        "√x" : OperationType.UnaryOperation(sqrt, {"√(" + $0 + ")"}),
        "±" : OperationType.UnaryOperation( {-$0}, {"-(" + $0 + ")"}),
        "cos": OperationType.UnaryOperation(cos, {"cos(" + $0 + ")"}),
        "sin": OperationType.UnaryOperation(sin, {"sin(" + $0 + ")"}),
        "tan": OperationType.UnaryOperation(tan, {"tan(" + $0 + ")"}),
        "ln": OperationType.UnaryOperation(log10, {"ln(" + $0 + ")"}),
        "x!": OperationType.UnaryOperation(factorial, {"(" + $0 + ")!"}),
        "x²": OperationType.UnaryOperation( {pow($0, 2)}, {"(" + $0 + ")²"}),
        "1/x": OperationType.UnaryOperation( {1 / $0}, {"1/(" + $0 + ")"} ),
        "xʸ": OperationType.BinaryOperation({pow($0, $1)}, { $0 + "^" + $1 }, 2),
        "×": OperationType.BinaryOperation( {$0 * $1} , {$0 + "×" + $1}, 1),
        "÷": OperationType.BinaryOperation( {$0 / $1} , {$0 + "÷" + $1}, 1),
        "+": OperationType.BinaryOperation( {$0 + $1} , {$0 + "+" + $1}, 0),
        "−": OperationType.BinaryOperation( {$0 - $1} , {$0 + "−" + $1}, 0),
        "=": OperationType.Equals
    ]
    
    private enum OperationType {
        case Constant(Double)
        case UnaryOperation((Double) -> Double, (String) -> String)
        case BinaryOperation((Double, Double) -> Double, (String, String) -> String, Int)
        case Equals
        case Random(() -> Double)
    }
    
    private var currentPrority = Int.max
    
    func performOperation(_ symbol: String) {
        internalProgram.append(symbol as AnyObject)
        if let operation = operations[symbol] {
            switch operation {
            case OperationType.Constant(let Value):
                accumulator = Value
                descriptionAccumulator = symbol
            case .UnaryOperation(let Function, let descriptionFunction):
                accumulator = Function(accumulator)
                descriptionAccumulator = descriptionFunction(descriptionAccumulator)
            case .BinaryOperation(let Function, let descriptionFunction, let priority):
                executePendingBinaryOperation()
                if currentPrority < priority {
                    descriptionAccumulator = "(" + descriptionAccumulator + ")"
                }
                currentPrority = priority
                pending = PendingBinaryOperationInfo(binaryFunction: Function, firstOperand: accumulator, descriptionFunction: descriptionFunction, descriptionOperand: descriptionAccumulator)
            case .Equals:
                executePendingBinaryOperation()
            case .Random(let Function):
                let random = Function()
                accumulator = Double(round(100000*random)/100000);
                descriptionAccumulator = String(format: "%6g", random)
            }
        }
    }
    
    private func executePendingBinaryOperation() {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            descriptionAccumulator = pending!.descriptionFunction(pending!.descriptionOperand, descriptionAccumulator)
            pending = nil
            
        }
    }
    
    private var pending: PendingBinaryOperationInfo?
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
        var descriptionFunction: (String, String) -> String
        var descriptionOperand: String
    }
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList {
        get {
            return internalProgram as CalcBrain.PropertyList
        }
        set {
            clear()
            if let arrayOfOperands = newValue as? [AnyObject] {
                for oper in arrayOfOperands {
                    if let operand = oper as? Double {
                        setOperand(operand)
                    } else if let operation = oper as? String {
                        performOperation(operation)
                    }
                }
            }
        }
    }
    
    func clear() {
        accumulator = 0.0
        pending = nil
        internalProgram.removeAll()
    }
    
    var result: Double {
        get {
            return accumulator
        }
        
    }
}






















