//
//  Token.swift
//  Lox
//
//  Created by Алексей Якименко on 24.05.2021.
//

import Foundation

enum LiteralType: Equatable, CustomStringConvertible {
    case string(String)
    case number(Double)
    
    var description: String {
        switch self {
        case .string(let string): return string
        case .number(let number): return String(number)
        }
    }
}

struct Token: Equatable, CustomStringConvertible {
    
    let type: TokenType
    let lexeme: String
    let literal: LiteralType?
    let line: Int
    
    var description: String {
        "type:\(type) lexeme:\(lexeme) literal:\(String(describing: literal))"
    }
    
    static func == (lhs: Token, rhs: Token) -> Bool {
        lhs.type == rhs.type &&
            lhs.lexeme == rhs.lexeme &&
            lhs.line == rhs.line &&
            lhs.literal == rhs.literal
    }
}
