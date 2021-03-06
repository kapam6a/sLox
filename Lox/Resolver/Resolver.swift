//
//  Reolver.swift
//  Lox
//
//  Created by Алексей Якименко on 12.06.2021.
//

import Foundation

private enum ClassType {
    case none
    case `class`
    case subclass
}

private enum FunctionType {
    case none
    case function
    case method
    case initializer
 }

final class Resolver {
    
    private let interpreter: Interpreter
    private let scopes: Stack<Dictionary<String, Bool>> = Stack()
    private var currentFunction: FunctionType = .none
    private var currentClass: ClassType = .none

    init(_ interpreter: Interpreter) {
        self.interpreter = interpreter
    }
    
    func resolve(_ statements: [Stmt]) throws {
        try statements.forEach(resolve)
    }
}

extension Resolver: VisitorStmt {
    
    func visitClassStmt(_ stmt: Class) throws -> () {
        let enclosingClass = currentClass
        currentClass = .class
        declare(stmt.name)
        define(stmt.name)
        if let superclass = stmt.superclass {
            if superclass.name == stmt.name {
                Lox.error(superclass.name, "A class can't inherit from itself.")
            }
            currentClass = .subclass
            try resolve(superclass)
        }
        if stmt.superclass != nil {
            beginScope()
            var scope = scopes.pop()!
            scope["super"] = true
            scopes.push(scope)
        }

        beginScope()
        var scope = scopes.pop()!
        scope["this"] = true
        scopes.push(scope)
        for method in stmt.methods {
            var declaration: FunctionType = .method
            if method.name.lexeme == "init" {
                declaration = .initializer
            }
            try resolveFunction(method, declaration)
        }
        endScope()
        if stmt.superclass != nil {
            endScope()
        }
        currentClass = enclosingClass
    }
    
    func visitBlockStmt(_ stmt: Block) throws -> Void {
        beginScope()
        try resolve(stmt.statements)
        endScope()
    }
    
    func visitExpressionStmt(_ stmt: Expression) throws -> Void {
        try resolve(stmt.expression)
    }
    
    func visitFunctionStmt(_ stmt: Function) throws -> Void {
        declare(stmt.name)
        define(stmt.name)
        try resolveFunction(stmt, .function)
    }
    
    func visitIfStmt(_ stmt: If) throws -> Void {
        try resolve(stmt.condition)
        try resolve(stmt.thenBranch)
        if let elseBranch = stmt.elseBranch {
            try resolve(elseBranch)
        }
    }
    
    func visitPrintStmt(_ stmt: Print) throws -> Void {
        try resolve(stmt.expression)
    }
    
    func visitReturnStmt(_ stmt: Return) throws -> Void {
        if currentFunction == .none {
            Lox.error(stmt.keyword, "Can't return from top-level code.");
        }
        if let value = stmt.value {
            if currentFunction == .initializer {
                Lox.error(stmt.keyword, "Can't return a value from an initializer.")
            }
            try resolve(value)
        }
    }
    
    func visitVarStmt(_ stmt: Var) throws -> Void {
        declare(stmt.name)
        if let initializer = stmt.initializer {
            try resolve(initializer)
        }
        define(stmt.name)
    }
    
    func visitWhileStmt(_ stmt: While) throws -> Void {
        try resolve(stmt.condition)
        try resolve(stmt.body)
    }
}

extension Resolver: VisitorExpr {
    
    func visitSuperExpr(_ expr: Super) throws -> Void {
        if currentClass == .none {
            Lox.error(expr.keyword, "Can't use 'super' outside of a class.");
        } else if currentClass != .subclass {
            Lox.error(expr.keyword, "Can't use 'super' in a class with no superclass.");
        }
        try resolveLocal(expr, expr.keyword)
    }
    
    func visitThisExpr(_ expr: This) throws -> Void {
        if currentClass == .none {
            Lox.error(expr.keyword, "Can't use 'this' outside of a class.")
        }
        try resolveLocal(expr, expr.keyword)
    }
    
    
    func visitLoxSetExpr(_ expr: LoxSet) throws -> Void {
        try resolve(expr.value)
        try resolve(expr.object)
    }
    
    func visitGetExpr(_ expr: Get) throws -> Void {
        try resolve(expr.object)
    }
    
    func visitAssignExpr(_ expr: Assign) throws -> Void {
        try resolve(expr.value)
        try resolveLocal(expr, expr.name)
    }
    
    func visitBinaryExpr(_ expr: Binary) throws -> Void {
        try resolve(expr.left)
        try resolve(expr.right)
    }
    
    func visitCallExpr(_ expr: Call) throws -> Void {
        try resolve(expr.callee)
        for argument in expr.arguments {
            try resolve(argument)
        }
    }
    
    func visitGroupingExpr(_ expr: Grouping) throws -> Void {
        try resolve(expr.expressions)
    }
    
    func visitLiteralExpr(_ expr: Literal) throws -> Void {}
    
    func visitLogicalExpr(_ expr: Logical) throws -> Void {
        try resolve(expr.left)
        try resolve(expr.right)
    }
    
    func visitUnaryExpr(_ expr: Unary) throws -> Void {
        try resolve(expr.right)
    }
    
    func visitVariableExpr(_ expr: Variable) throws -> Void {
        if scopes.hasNext(),
           scopes.peek()?[expr.name.lexeme] != true {
              Lox.error(expr.name, "Can't read local variable in its own initializer.");
        }
        try resolveLocal(expr, expr.name)
    }
}

private extension Resolver {
    
    func beginScope() {
        scopes.push(Dictionary<String, Bool>())
    }
    
    func endScope() {
        scopes.pop()
    }
    
    func resolve(_ statement: Stmt) throws {
        try statement.accept(visitor: self)
    }
    func resolve(_ exprs: [Expr]) throws {
        try exprs.forEach(resolve)
    }
    
    func resolve(_ expr: Expr) throws {
        try expr.accept(visitor: self)
    }
    
    func declare(_ name: Token) {
        guard scopes.hasNext() else { return }
        var scope = scopes.pop()!
        if scope.keys.contains(name.lexeme) {
            Lox.error(name, "Already variable with this name in this scope.");
        }
        scope[name.lexeme] = false
        scopes.push(scope)
    }
    
    func define(_ name: Token) {
        guard scopes.hasNext() else { return }
        var scope = scopes.pop()!
        scope[name.lexeme] = true
        scopes.push(scope)
    }
    
    func resolveLocal(_ expr: Expr, _ name: Token) throws {
        for (index, scope) in scopes.reversed().enumerated() {
            if scope.keys.contains(name.lexeme) {
                interpreter.resolve(expr, index)
                return
            }
        }
    }
    
    func resolveFunction(_ function: Function, _ type: FunctionType) throws {
        let enclosingFunction = currentFunction
        currentFunction = type
        beginScope()
        for param in function.params {
            declare(param)
            define(param)
        }
        try resolve(function.body)
        endScope()
        currentFunction = enclosingFunction
    }
}
