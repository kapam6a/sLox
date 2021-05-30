//
//  Interpreter.swift
//  Lox
//
//  Created by Алексей Якименко on 29.05.2021.
//

import Foundation

struct RuntimeError: Error {
    let `operator`: Token
    let message: String
}

final class Interpreter {

    func interpret(_ expr: Expr) {
        do {
            let value = try evaluate(expr)
            print(stringify(value))
        } catch {
            let error = error as! RuntimeError
            Lox.error(error)
        }
    }
}

extension Interpreter: Visitor {
    
    func visitBinaryExpr(_ expr: Binary) throws -> Any? {
        let left = try evaluate(expr.left)
        let right = try evaluate(expr.right)
        
        switch expr.operator.type {
        case .minus:
            try checkNumberOperands(expr.operator, left, right)
            return (left as! Double) - (right as! Double)
        case .slash:
            try checkNumberOperands(expr.operator, left, right)
            return (left as! Double) / (right as! Double)
        case .star:
            try checkNumberOperands(expr.operator, left, right)
            return (left as! Double) * (right as! Double)
        case .plus:
            if let leftStr = left as? String, let rightStr = right as? String {
                return leftStr + rightStr
            } else if let leftNum = left as? Double, let rightNum = right as? Double {
                return leftNum + rightNum
            }
            throw RuntimeError(operator: expr.operator,
                               message: "Operands must be two numbers or two strings.")
        case .greater:
            try checkNumberOperands(expr.operator, left, right)
            return (left as! Double) > (right as! Double)
        case .greaterEqual:
            try checkNumberOperands(expr.operator, left, right)
            return (left as! Double) >= (right as! Double)
        case .less:
            try checkNumberOperands(expr.operator, left, right)
            return (left as! Double) < (right as! Double)
        case .lessEqual:
            try checkNumberOperands(expr.operator, left, right)
            return (left as! Double) <= (right as! Double)
        case .bangEqual:
            return !isEqual(left, right)
        case .equalEqual:
            return isEqual(left, right)
        default: return nil
        }
    }
    
    func visitGroupingExpr(_ expr: Grouping) throws -> Any? {
        try expr.expressions.map(evaluate).last
    }
    
    func visitLiteralExpr(_ expr: Literal) throws -> Any? {
        switch expr.value {
        case .boolean(let boolean): return boolean
        case .number(let number): return number
        case .string(let string): return string
        case .none: return nil
        }
    }
    
    func visitUnaryExpr(_ expr: Unary) throws -> Any? {
        let right = try evaluate(expr)
        switch expr.operator.type {
        case .minus:
            try checkNumberOperand(expr.operator, right)
            return  -(right as! Double)
        case .bang: return !isTruthy(right)
        default: return nil
        }
    }
}

private extension Interpreter {
    
    func evaluate(_ expr: Expr) throws -> Any? {
        try expr.accept(visitor: self)
    }
    
    func isTruthy(_ object: Any?) -> Bool {
        if object == nil { return false }
        if let boolean = object as? Bool { return boolean }
        return true
    }
    
    func stringify(_ object: Any?) -> String {
        switch object {
        case .none: return "nil"
        case .some(let some):
            switch some {
            case let object as Bool:
                return String(object)
            case let object as String:
                return object
            case let object as Double:
                let formatter = NumberFormatter()
                formatter.minimumFractionDigits = 0
                formatter.numberStyle = .decimal
                return formatter.string(from: NSNumber(value: object))!
            default: fatalError()
            }
        }
    }
    
    func isEqual(_ left: Any?, _ right: Any?) -> Bool {
        if left == nil, right == nil { return true }
        if left == nil { return false }
        if let leftStr = left as? String, let rightStr = right as? String {
            return leftStr == rightStr
        }
        if let leftStr = left as? Bool, let rightStr = right as? Bool {
            return leftStr == rightStr
        }
        if let leftStr = left as? Double, let rightStr = right as? Double {
            return leftStr == rightStr
        }
        return false
    }
    
    func checkNumberOperand(_ token: Token, _ object: Any?) throws {
        if object is Double { return }
        throw RuntimeError(operator: token, message: "Operand must be a number.")
    }
    
    func checkNumberOperands(_ token: Token, _ left: Any?, _ right: Any?) throws {
        if left is Double, right is Double  { return }
        throw RuntimeError(operator: token, message: "Operands must be a number.")
    }
}
