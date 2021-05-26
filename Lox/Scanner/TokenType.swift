//
//  TokenType.swift
//  Lox
//
//  Created by Алексей Якименко on 24.05.2021.
//

import Foundation

enum TokenType: Equatable {
    
    case leftParen,
         rightParen,
         leftBrace,
         rightBrace,
         comma,
         dot,
         minus,
         plus,
         semicolon,
         slash,
         star
    
    case bang,
         bangEqual,
         equal,
         equalEqual,
         greater,
         greaterEqual,
         less,
         lessEqual
    
    case identifier,
         string,
         number
    
    case and,
         `class`,
         `else`,
         `false`,
         fun,
         `for`,
         `if`,
         `nil`,
         or,
         print,
         `return`,
         `super`,
         this,
         `true`,
         `var`,
         `while`
    
    case eof
}
