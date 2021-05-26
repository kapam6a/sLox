//
//  Scanner.swift
//  Lox
//
//  Created by Алексей Якименко on 24.05.2021.
//

import Foundation

final class Scanner {
    
    private let keywords: [String: TokenType] = [
        "and": .and,
        "class": .class,
        "else": .else,
        "false": .false,
        "for": .for,
        "fun": .fun,
        "if": .if,
        "nil": .nil,
        "or": .or,
        "print": .print,
        "return": .return,
        "super": .super,
        "this": .this,
        "true": .true,
        "var": .var,
        "while": .while
    ]
    private let sourceCode: [Character]
    private var tokens: [Token] = []
    private var start: Int = 0
    private var current: Int = 0
    private var line: Int = 1
    
    init(_ sourceCode: String) {
        self.sourceCode = Array(sourceCode)
    }
    
    func scanTokens() -> [Token] {
        while !isAtEnd() {
            start = current
            scanToken()
        }
        
        tokens.append(Token(type: .eof, lexeme: "", literal: nil, line: line))
        return tokens
    }
}

private extension Scanner {
    
    func isAtEnd() -> Bool {
        current >= sourceCode.count
    }
    
    func scanToken() {
        let c = advance()
        switch c {
        case "(": addToken(.leftParen)
        case ")": addToken(.rightParen)
        case "{": addToken(.leftBrace)
        case "}": addToken(.rightBrace)
        case ",": addToken(.comma)
        case ".": addToken(.dot)
        case "-": addToken(.minus)
        case "+": addToken(.plus)
        case ";": addToken(.semicolon)
        case "*": addToken(.star)
        case "!": addToken(match("=") ? .bangEqual : .bang)
        case "=": addToken(match("=") ? .equalEqual : .equal)
        case "<": addToken(match("=") ? .lessEqual : .less)
        case ">": addToken(match("=") ? .greaterEqual : .greater)
        case "/": commentOrSlash()
        case " ": break
        case "\r": break
        case "\t": break
        case "\n": line += 1
        case "\"": string()
        case _ where c.isNumber: number()
        case _ where c.isLetter: identifier()
        default: Lox.error(line, "Unexpected character")
        }
    }
    
    func addToken( _ tokenType: TokenType, _ object: Literal? = nil) {
        let string = Array(sourceCode[start..<current])
        tokens.append(Token(type: tokenType, lexeme: String(string), literal: object, line: line))
    }
    
    @discardableResult func advance() -> Character {
        let currentSymbol = sourceCode[current]
        current += 1
        return currentSymbol
    }
    
    func match(_ symbol: Character) ->  Bool {
        if isAtEnd() { return false }
        if sourceCode[current] != symbol { return false }
        current += 1
        return true
    }
    
    func peek() -> Character {
        if isAtEnd() { return "\0" }
        return sourceCode[current]
    }
    
    func peekNext() -> Character {
        if current + 1 >= sourceCode.count { return "\0" }
        return sourceCode[current + 1]
    }
    
    func commentOrSlash() {
        if match("/"){
            comment()
        } else if match("*") {
            blockComment()
        } else {
            addToken(.slash)
        }
    }
    
    func comment() {
        while peek() != "\n" && !isAtEnd() {
            advance()
        }
    }
    
    func blockComment() {
        while peek() != "*" && peekNext() != "/" && !isAtEnd() {
            if peek() == "\n" { line += 1 }
            advance()
        }
        if isAtEnd() {
            return Lox.error(line, "Unterminated '/*' comment.")
        }
        advance()
        advance()
    }
    
    func string() {
        while peek() != "\"" && !isAtEnd() {
            if peek() == "\n" { line += 1 }
            advance()
        }
        
        if isAtEnd() {
            return Lox.error(line, "Unterminated string.")
        }
        
        advance()
        
        let string = Array(sourceCode[start + 1..<current - 1])
        addToken(.string, .string(String(string)))
    }
    
    func number() {
        while peek().isNumber {
            advance()
        }
        
        if peek() == "." && peekNext().isNumber {
            advance()
            while peek().isNumber {
                advance()
            }
        }
        let number = Array(sourceCode[start..<current])
        addToken(.number, .number(Double(String(number))!))
    }
    
    func identifier() {
        while peek().isLetter || peek().isNumber || peek() == "_" { advance() }
        let identifier = Array(sourceCode[start..<current])
        if let type = keywords[String(identifier)] {
            addToken(type)
        } else {
            addToken(.identifier)
        }
    }
}
