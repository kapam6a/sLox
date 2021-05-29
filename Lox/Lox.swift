//
//  Lox.swift
//  Lox
//
//  Created by Алексей Якименко on 24.05.2021.
//

import Foundation

final class Lox {
    
    static var hadError = false
    
    static var errorReporter: ErrorReporter = StandardErrorReporter()
    
    static func runFile(_ filePath: String) {
        let sourceCode = try! String(contentsOf: URL(fileURLWithPath: filePath))
        Lox.run(sourceCode)
        if hadError { exit(65) }
    }

    static func runPromt() {
        while true {
            print("lox > ")
            guard let sourceCode = readLine() else { break }
            Lox.run(sourceCode)
            hadError = false
        }
    }
    
    static func run(_ sourceCode: String) {
        let scanner = Scanner(sourceCode)
        let tokens = scanner.scanTokens()
        let parser = Parser(tokens)
        let expr = parser.parse()
        expr.map { print(AstPrinter().print($0)) }
    }
    
    static func error(_ line: Int, _ message: String) {
        errorReporter.report(line, "", message)
        hadError = true
    }
    
    static func error(_ token: Token, _ message: String) {
        if token.type == .eof {
            errorReporter.report(token.line, " at end", message)
        } else {
            errorReporter.report(token.line, " at '" + token.lexeme + "'", message)
        }
        hadError = true
    }
}
