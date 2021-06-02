//
//  Parser.swift
//  Lox
//
//  Created by Алексей Якименко on 28.05.2021.
//

import Foundation

struct ParserError: Error {}

final class Parser {
    
    private let tokens: [Token]
    private var current: Int = 0
    
    init(_ tokens: [Token]) {
        self.tokens = tokens
    }
    
    func parse() -> [Stmt] {
        var statements: [Stmt] = []
        while (!isAtEnd()) {
            declaration().map { statements.append($0) }
        }
        return statements
    }
}

private extension Parser {
    
    func declaration() -> Stmt? {
        do {
            if match(.var) { return try varDeclaration() }
            return try statement()
        } catch {
            synchronize()
            return nil
        }
    }
    
    func varDeclaration() throws -> Stmt {
        let name = try consume(.identifier, "Expect variable name.")
        var initializer: Expr?
        if match(.equal) {
            initializer = try expression()
        }
        try consume(.semicolon, "Expect ';' after variable declaration.")
        return Var(name: name, initializer: initializer)
    }
    
    func statement() throws -> Stmt {
        if match(.print) { return try printStatement() }
        if match(.leftBrace) { return Block(statements: try block()) }
        return try expressionStatement()
    }
    
    func printStatement() throws -> Stmt {
        let expr = try expression()
        try consume(.semicolon, "Expect ';' after value.")
        return Print(expression: expr)
    }
    
    func block() throws -> [Stmt] {
        var stmts: [Stmt] = []
        while !check(.rightBrace) && !isAtEnd()  {
            stmts.append(try statement())
        }
        try consume(.rightBrace, "Expect '}' after block.")
        return stmts
    }
    
    func expressionStatement() throws -> Stmt {
        let expr = try expression()
        try consume(.semicolon, "Expect ';' after value.")
        return Expression(expression: expr)
    }
}

private extension Parser {
    
    func expression() throws -> Expr {
        try assignment()
    }
    
    func assignment() throws -> Expr {
        let expr = try equality()
        
        if match(.equal) {
            let equals = previous()
            let value = try assignment()
            if let expr = expr as? Variable {
                let name = expr.name
                return Assign(name: name, value: value)
            }
            _ = error(equals, "Invalid assignment target.")
        }
        
        return expr
    }
    
    func equality() throws -> Expr {
        var exp = try comparison()
        
        while match(.bangEqual, .equalEqual) {
            let `operator` = previous()
            let right = try comparison()
            exp = Binary(left: exp, operator: `operator`, right: right)
        }
        return exp
    }
    
    func comparison() throws -> Expr {
        var exp = try term()
        
        while match(.greater, .greaterEqual, .less, .lessEqual) {
            let `operator` = previous()
            let right = try term()
            exp = Binary(left: exp, operator: `operator`, right: right)
        }
        return exp
    }
    
    func term() throws -> Expr {
        var exp = try factor()
        
        while match(.minus, .plus) {
            let `operator` = previous()
            let right = try factor()
            exp = Binary(left: exp, operator: `operator`, right: right)
        }
        return exp
    }
    
    func factor() throws -> Expr {
        var exp = try unary()
        
        while match(.slash, .star) {
            let `operator` = previous()
            let right = try unary()
            exp = Binary(left: exp, operator: `operator`, right: right)
        }
        return exp
    }
    
    func unary() throws -> Expr {
        while match(.bang, .minus, .plus) {
            let `operator` = previous()
            let right = try unary()
            switch `operator`.type {
            case .plus: throw error(`operator`, "Unary ‘+’ expressions are not supported")
            default: return Unary(operator: `operator`, right: right)
            }
        }
        return try primary()
    }
    
    func primary() throws -> Expr {
        if match(.true) { return Literal(value: .boolean(true)) }
        if match(.false) { return Literal(value: .boolean(false)) }
        if match(.nil) { return Literal(value: nil) }
        if match(.number, .string) { return Literal(value: previous().literal) }
        if match(.leftParen) {
            var exps = [try expression()]
            while match(.comma) {
                exps.append(try expression())
            }
            try consume(.rightParen, "Expect ')' after expression.")
            return Grouping(expressions: exps)
        }
        if match(.identifier) { return Variable(name: previous()) }
        
        throw error(peek(), "Expect expression.")
    }
}


private extension Parser {
    
    func synchronize() {
        _ = advance()
        
        while !isAtEnd() {
            if previous().type == .semicolon { return }
            switch peek().type {
            case .class,
                 .fun,
                 .var,
                 .for,
                 .if,
                 .while,
                 .print,
                 .return: return
            default: break
            }
            _ = advance()
        }
    }
    
    func match(_ tokenTypes: TokenType...) -> Bool {
        for type in tokenTypes {
            if check(type) {
                advance()
                return true
            }
        }
        return false
    }
    
    @discardableResult func consume(_ tokenType: TokenType, _ message: String) throws -> Token {
        if (check(tokenType)) { return advance() }
        throw error(peek(), message)
    }
    
    @discardableResult func advance() -> Token {
        if (!isAtEnd()) { current += 1 }
        return previous()
    }
    
    func check(_ tokenType: TokenType) -> Bool {
        if (isAtEnd()) { return false }
        return peek().type == tokenType
    }
    
    func isAtEnd() -> Bool {
        peek().type == .eof
    }
    
    func peek() -> Token {
        tokens[current]
    }
    
    func previous() -> Token {
        tokens[current - 1]
    }
    
    func error(_ token: Token, _ message: String) -> Error {
        Lox.error(token, message)
        return ParserError()
    }
}
