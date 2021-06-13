//
//  Reolver.swift
//  Lox
//
//  Created by Алексей Якименко on 12.06.2021.
//

import Foundation

private enum FunctionType {
   case none
   case function
 }

final class Resolver {
    
    private let interpreter: Interpreter
    private let scopes: Stack<Dictionary<String, Bool>> = Stack()
    private var currentFunction: FunctionType = .none
    
    init(_ interpreter: Interpreter) {
        self.interpreter = interpreter
    }
    
    func resolve(_ statements: [Stmt]) throws {
        try statements.forEach(resolve)
    }
}

extension Resolver: VisitorStmt {
    
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
        if (currentFunction == .none) {
            Lox.error(stmt.keyword, "Can't return from top-level code.");
        }
        if let value = stmt.value {
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
