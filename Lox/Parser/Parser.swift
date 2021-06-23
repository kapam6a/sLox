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
            if match(.class) { return try classDeclaration() }
            if match(.var) { return try varDeclaration() }
            if match(.fun) { return try function("function") }
            return try statement()
        } catch {
            synchronize()
            return nil
        }
    }
    
    func classDeclaration() throws -> Class {
        let name = try consume(.identifier, "Expect class name.")
        try consume(.leftBrace, "Expect '{' before class body.")
        var methods: [Function] = []
        while !check(.rightBrace) && !isAtEnd() {
            methods.append(try function("method"))
        }
        try consume(.rightBrace, "Expect '}' after class body.")
        return Class(name: name, methods: methods)
    }
    
    func varDeclaration() throws -> Var {
        let name = try consume(.identifier, "Expect variable name.")
        var initializer: Expr?
        if match(.equal) {
            initializer = try expression()
        }
        try consume(.semicolon, "Expect ';' after variable declaration.")
        return Var(name: name, initializer: initializer)
    }
    
    func function(_ kind: String) throws -> Function {
        let name = try consume(.identifier, "Expect " + kind + " name.")
        try consume(.leftParen, "Expect '(' after " + kind + " name.")
        var parameters: [Token] = []
        if (!check(.rightParen)) {
            repeat {
                if parameters.count >= 255 {
                    error(peek(), "Can't have more than 255 parameters.");
                }
                parameters.append(try consume(.identifier, "Expect parameter name."));
            } while match(.comma)
        }
        try consume(.rightParen, "Expect ')' after parameters.")
        try consume(.leftBrace, "Expect '{' before " + kind + " body.")
        let body = try block()
        return Function(name: name, params: parameters, body: body)
     }
    
    func statement() throws -> Stmt {
        if match(.print) { return try printStatement() }
        if match(.leftBrace) { return Block(statements: try block()) }
        if (match(.if)) { return try ifStatement() }
        if (match(.while)) { return try whileStatement() }
        if (match(.for)) { return try forStatement() }
        if match(.return) { return try returnStatement() }
        return try expressionStatement()
    }
    
    func printStatement() throws -> Print {
        let expr = try expression()
        try consume(.semicolon, "Expect ';' after value.")
        return Print(expression: expr)
    }
    
    func returnStatement() throws -> Return {
        let keyword = previous()
        var value: Expr?
        if !check(.semicolon) {
            value = try expression()
        }
        try consume(.semicolon, "Expect ';' after return value.")
        return Return(keyword: keyword, value: value)
    }
    
    func block() throws -> [Stmt] {
        var stmts: [Stmt] = []
        while !check(.rightBrace) && !isAtEnd()  {
            declaration().map { stmts.append($0) }
        }
        try consume(.rightBrace, "Expect '}' after block.")
        return stmts
    }
    
    func ifStatement() throws -> If {
        try consume(.leftParen, "Expect '(' after 'if'.")
        let condition = try expression()
        try consume(.rightParen, "Expect ')' after 'if' condition.")
        let thenBranch = try statement()
        var elseBranch: Stmt?
        if match(.else) {
            elseBranch = try statement()
        }
        return If(condition: condition, thenBranch: thenBranch, elseBranch: elseBranch)
    }
    
    func whileStatement() throws -> While {
        try consume(.leftParen, "Expect '(' after 'while'.")
        let condition = try expression()
        try consume(.rightParen, "Expect ')' after 'while' condition.")
        let body = try statement()
        return While(condition: condition, body: body)
    }
    
    func forStatement() throws -> Stmt {
        try consume(.leftParen, "Expect '(' after 'for'.")
        var initializer: Stmt?
        if match(.var) {
            initializer = try varDeclaration()
        } else if !match(.semicolon) {
            initializer = try expressionStatement()
        }
        var condition: Expr?
        if !check(.semicolon) {
            condition = try expression()
        }
        try consume(.semicolon, "Expect ';' after loop condition.")
        var increment: Expr?
        if !check(.rightParen) {
            increment = try expression();
        }
        try consume(.rightParen, "Expect ')' after 'for' condition.")
        var body = try statement()
        if let increment = increment {
            body = Block(statements: [
                body,
                Expression(expression: increment)
            ])
        }
        if condition == nil {
            condition = Literal(value: .boolean(true))
        }
        body = While(condition: condition!, body: body)
        if let initializer = initializer {
            body = Block(statements: [
                initializer,
                body
            ])
        }
        return body
    }
    
    func expressionStatement() throws -> Expression {
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
        let expr = try or()
        
        if match(.equal) {
            let equals = previous()
            let value = try assignment()
            if let expr = expr as? Variable {
                let name = expr.name
                return Assign(name: name, value: value)
            } else if let get = expr as? Get {
                return LoxSet(object: get.object, name: get.name, value: value)
            }
            _ = error(equals, "Invalid assignment target.")
        }
        
        return expr
    }
    
    func or() throws -> Expr {
        var expr = try and()

        while match(.or) {
            let `operator` = previous()
            let right = try and()
            expr = Logical(left: expr, operator: `operator`, right: right)
        }
        return expr
    }
    
    func and() throws -> Expr {
        var expr = try equality()

        while match(.and) {
            let `operator` = previous()
            let right = try equality()
            expr = Logical(left: expr, operator: `operator`, right: right)
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
        return try call()
    }
    
    func call() throws -> Expr {
        var expr = try primary()
        
        while true {
            if match(.leftParen) {
                expr = try finishCall(expr)
            } else if match(.dot) {
                let name = try consume(.identifier, "Expect property name after '.'.");
                expr = Get(object: expr, name: name)
            } else {
                break
            }
        }
        return expr
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
        if match(.this) { return This(keyword: previous()) }
        if match(.identifier) { return Variable(name: previous()) }
        
        throw error(peek(), "Expect expression.")
    }
}


private extension Parser {
    
    func finishCall(_ calle: Expr) throws -> Expr {
        var args: [Expr] = []
        if !check(.rightParen) {
            repeat {
                if args.count >= 255 {
                    error(peek(), "Can't have more than 255 arguments.");
                }
                args.append(try expression())
            } while match(.comma)
        }
        let paren = try consume(.rightParen, "Expect ')' after arguments.")
        return Call(callee: calle, paren: paren, arguments: args)
    }
    
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
    
    @discardableResult func error(_ token: Token, _ message: String) -> Error {
        Lox.error(token, message)
        return ParserError()
    }
}
