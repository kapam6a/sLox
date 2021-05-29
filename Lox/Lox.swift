//
//  Lox.swift
//  Lox
//
//  Created by Алексей Якименко on 24.05.2021.
//

import Foundation

final class Lox {
    
    static var hadError = false
    
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
        report(line, "", message)
        hadError = true
    }
    
    static func error(_ token: Token, _ message: String) {
        if token.type == .eof {
            report(token.line, " at end", message)
        } else {
            report(token.line, " at '" + token.lexeme + "'", message)
        }
    }
}

extension Lox {
    
    static func report(_ line: Int, _ where: String, _ message: String) {
        let data = "[line \(line) ] Error \(`where`): \(message)".data(using: .ascii)
        FileHandle.standardError.write(data!)
    }
}
