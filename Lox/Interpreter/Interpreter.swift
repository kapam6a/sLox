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

class Interpreter {
    
    private let printer: Printer
    private var environment: Environment
    private var locals: Dictionary<Expr, Int> = [:]
    let globals: Environment
    
    init(_ printer: Printer = StandardPrinter(),
         _ environment: Environment = Environment()) {
        self.printer = printer
        self.globals = environment
        self.environment = globals
        
        globals.define("clock", Clock())
    }

    func interpret(_ stmts: [Stmt]) {
        do {
            try stmts.forEach { try execute($0) }
        } catch {
            Lox.error(error as! RuntimeError)
        }
    }
    
    func resolve(_ expr: Expr, _ depth: Int) {
        locals[expr] = depth
    }
}

extension Interpreter: VisitorStmt {
    
    func visitClassStmt(_ stmt: Class) throws -> () {
        var superclass: LoxClass?
        if let superclassVar = stmt.superclass {
            superclass = try evaluate(superclassVar) as? LoxClass
            if superclass == nil {
                throw RuntimeError(operator: superclassVar.name, message: "Superclass must be a class.")
            }
        }
        environment.define(stmt.name.lexeme, nil)
        if stmt.superclass != nil {
            environment = Environment(environment);
            environment.define("super", superclass)
        }
        var methods: Dictionary<String, LoxFunction> = [:]
        for  method in stmt.methods {
            let function = LoxFunction(declaration: method,
                                       closure: environment,
                                       isInitializer: method.name.lexeme == "init")
            methods[method.name.lexeme] = function
        }
        
        let `class` = LoxClass(stmt.name.lexeme, superclass, methods)
        
        if superclass != nil {
            environment = environment.enclosing!
        }
        try environment.assign(stmt.name, `class`)
    }
    
    func visitFunctionStmt(_ stmt: Function) throws -> Void {
        let function = LoxFunction(declaration: stmt,
                                   closure: environment,
                                   isInitializer: false)
        environment.define(stmt.name.lexeme, function)
    }
    
    func visitIfStmt(_ stmt: If) throws -> Void {
        if isTruthy(try evaluate(stmt.condition)) {
            try execute(stmt.thenBranch)
        } else if let elseBranch = stmt.elseBranch {
            try execute(elseBranch)
        }
    }
    
    func visitBlockStmt(_ stmt: Block) throws -> Void {
        try executeBlock(stmt.statements, Environment())
    }
    
    func visitVarStmt(_ stmt: Var) throws -> Void {
        var value: Any?
        if stmt.initializer != nil {
            value = try evaluate(stmt.initializer!)
        }
        environment.define(stmt.name.lexeme, value)
        printer.print(stringify(value))
    }
    
    func visitExpressionStmt( _ stmt: Expression) throws -> Void {
        let value = try evaluate(stmt.expression)
        printer.print(stringify(value))
    }
    
    func visitPrintStmt( _ stmt: Print) throws -> Void {
        let value = try evaluate(stmt.expression)
        printer.print(stringify(value))
    }
    
    func visitReturnStmt(_ stmt: Return) throws -> Void {
        let value = try stmt.value.flatMap { try evaluate($0) }
        throw ReturnError(value)
    }
    
    func visitWhileStmt(_ stmt: While) throws -> Void {
        while (isTruthy((try evaluate(stmt.condition)))) {
            try execute(stmt.body)
        }
    }
}

extension Interpreter {
    
    func execute(_ stmt: Stmt) throws {
        try stmt.accept(visitor: self)
    }
    
    func executeBlock(_ stmts: [Stmt], _ environment: Environment) throws {
        let previous = self.environment
        defer {
            self.environment = previous
        }
        self.environment = environment
        try stmts.forEach { try execute($0) }
    }
}

extension Interpreter: VisitorExpr {
    
    func visitSuperExpr(_ expr: Super) throws -> Any? {
        let distance = locals[expr]
        let superclass = try environment.get(at: distance!, "super") as? LoxClass
        let object = try environment.get(at: distance! - 1, "this") as? LoxInstance
        if let method = superclass?.findMethod(expr.method.lexeme) {
            return method.bind(object!)
        }
        throw RuntimeError(operator: expr.method, message: "Undefined property '" + expr.method.lexeme + "'.")
    }
    
    func visitThisExpr(_ expr: This) throws -> Any? {
        try lookUpVariable(expr.keyword, expr)
    }
    
    
    func visitLoxSetExpr(_ expr: LoxSet) throws -> Any? {
        let object = try evaluate(expr.object)
        guard let instance = object as? LoxInstance else {
            throw RuntimeError(operator: expr.name, message: "Only instances have fields.")
        }
        let value = try evaluate(expr.value)
        instance.set(expr.name, value)
        return value
    }
    
    func visitGetExpr(_ expr: Get) throws -> Any? {
        let object = try evaluate(expr.object)
        if let object = object as? LoxInstance {
            return try object.get(expr.name)
        }
        throw RuntimeError(operator: expr.name, message: "Only instances have properties.");
    }
    
    func visitAssignExpr(_ expr: Assign) throws -> Any? {
        let value = try evaluate(expr.value)
        let distance = locals[expr]
        if let distance = distance {
            environment.assign(at: distance, expr.name, value)
        } else {
            try globals.assign(expr.name, value)
        }
        return value
    }
    
    func visitVariableExpr(_ expr: Variable) throws -> Any? {
        try lookUpVariable(expr.name, expr)
    }
    
    func visitBinaryExpr(_ expr: Binary) throws -> Any? {
        let left = try evaluate(expr.left)
        let right = try evaluate(expr.right)
        
        switch expr.operator.type {
        case .minus:
            try checkNumberOperands(expr.operator, left, right)
            return (left as! Double) - (right as! Double)
        case .slash:
            try checkDivisionOperands(expr.operator, left, right)
            return (left as! Double) / (right as! Double)
        case .star:
            try checkNumberOperands(expr.operator, left, right)
            return (left as! Double) * (right as! Double)
        case .plus:
            return try addOperands(expr.operator, left, right)
        case .greater:
            return try compareOperands(expr.operator, left, right)
        case .greaterEqual:
            return try compareOperands(expr.operator, left, right)
        case .less:
            return try compareOperands(expr.operator, left, right)
        case .lessEqual:
            return try compareOperands(expr.operator, left, right)
        case .bangEqual:
            return !isEqual(left, right)
        case .equalEqual:
            return isEqual(left, right)
        default: return nil
        }
    }
    
    func visitCallExpr(_ expr: Call) throws -> Any? {
        guard let function = try evaluate(expr.callee) as? Callable else {
            throw RuntimeError(operator: expr.paren, message: "Can only call functions and classes.")
        }
        let args = try expr.arguments.map { try evaluate($0) }
        if args.count != function.arity() {
            throw RuntimeError(operator: expr.paren,
                               message: "Expected \(function.arity()) arguments but got \(args.count).")
        }
        return try function.call(self, args)
    }
    
    func visitGroupingExpr(_ expr: Grouping) throws -> Any? {
        try expr.expressions.map { try evaluate($0) as Any }.last
    }
    
    func visitLiteralExpr(_ expr: Literal) throws -> Any? {
        switch expr.value {
        case .boolean(let boolean): return boolean
        case .number(let number): return number
        case .string(let string): return string
        case .none: return nil
        }
    }
    
    func visitLogicalExpr(_ expr: Logical) throws -> Any? {
        let left = try evaluate(expr.left)
        if expr.operator.type == .or {
            if isTruthy(left) { return left }
        } else {
            if !isTruthy(left) { return left }
        }
        return try evaluate(expr.left)
    }
    
    func visitUnaryExpr(_ expr: Unary) throws -> Any? {
        let right = try evaluate(expr.right)
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
    
    func lookUpVariable(_ name: Token, _ expr: Expr) throws -> Any? {
        let distance = locals[expr]
        if let distance = distance {
            return try environment.get(at: distance, name.lexeme)
        } else {
          return try globals.get(name)
        }
      }
    
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
        switch (left, right) {
        case (nil, nil): return true
        case (nil, _): return false
        case (let left as String, let right as String): return left == right
        case (let left as Bool, let right as Bool): return left == right
        case (let left as Double, let right as Double): return left == right
        default: return false
        }
    }
    
    func addOperands(_ token: Token, _ left: Any?, _ right: Any?) throws -> Any {
        switch (left, right) {
        case (let l as Double, let r as Double): return l + r
        case (let l as String, let r as CustomStringConvertible): return l + r.description
        case (let l as CustomStringConvertible, let r as String): return l.description + r
        default: throw RuntimeError(operator: token,
                                    message: "Operands must be two numbers or two strings.")
        }
    }
    
    func compareOperands(_ token: Token, _ left: Any?, _ right: Any?) throws -> Bool {
        switch (left, right) {
        case (let left as String, let right as String):
            return compareOperands(token, left, right)
        case (let left as Double, let right as Double):
            return compareOperands(token, left, right)
        default: throw RuntimeError(operator: token,
                                    message: "Operands must be a number or string.")
        }
    }
    
    func checkNumberOperand(_ token: Token, _ object: Any?) throws {
        if object is Double { return }
        throw RuntimeError(operator: token, message: "Operand must be a number.")
    }
    
    func checkDivisionOperands(_ token: Token, _ left: Any?, _ right: Any?) throws {
        if left is Double, let right = right as? Double  {
            if right != 0 { return }
            throw RuntimeError(operator: token, message: "Division by zero is prohibited.")
        }
        throw RuntimeError(operator: token, message: "Operands must be a number.")
    }
    
    func checkNumberOperands(_ token: Token, _ left: Any?, _ right: Any?) throws {
        if left is Double, right is Double  { return }
        throw RuntimeError(operator: token, message: "Operands must be a number.")
    }
    
    func compareOperands<T: Comparable>(_ token: Token, _ left: T, _ right: T) -> Bool  {
        switch token.type {
        case .less: return left < right
        case .lessEqual: return left <= right
        case .greater: return left > right
        case .greaterEqual: return left >= right
        default: fatalError()
        }
    }
}
