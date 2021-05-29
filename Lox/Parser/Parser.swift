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
    
    func parse() -> Expr? {
        do {
            return try expression()
        } catch {
            return nil
        }
    }
}

private extension Parser {
    
    func expression() throws -> Expr {
        try equality()
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
        while match(.bang, .minus) {
            let `operator` = previous()
            let right = try unary()
            return Unary(operator: `operator`, right: right)
        }
        return try primary()
    }
    
    func primary() throws -> Expr {
        if match(.true) { return Literal(value: .boolean(true)) }
        if match(.false) { return Literal(value: .boolean(false)) }
        if match(.nil) { return Literal(value: nil) }
        if match(.number, .string) { return Literal(value: previous().literal) }
        if match(.leftParen) {
            let exp = try expression()
            try consume(.rightParen, "Expect ')' after expression.")
            return Grouping(expression: exp)
        }
        
        throw error(peek(), "Expect expression.")
    }
}


private extension Parser {
    
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
