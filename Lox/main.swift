//
//  main.swift
//  Lox
//
//  Created by Алексей Якименко on 24.05.2021.
//

import Foundation

if CommandLine.arguments.count > 2 {
    print("Usage: lox [script]")
    exit(64)
} else if CommandLine.arguments.count == 2 {
    Lox.runFile(CommandLine.arguments[1])
} else {
    Lox.runPromt()
}
