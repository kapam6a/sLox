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
        tokens.forEach { print($0) }
    }
    
    static func error(_ line: Int, _ message: String) {
        report(line, "", message)
        hadError = true
    }
}

extension Lox {
    
    static func report(_ line: Int, _ where: String, _ message: String) {
        let data = "[line \(line) ] Error \(`where`): \(message)".data(using: .ascii)
        FileHandle.standardError.write(data!)
    }
}
