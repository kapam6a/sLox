//
//  Function+Callable.swift
//  Lox
//
//  Created by Алексей Якименко on 06.06.2021.
//

import Foundation

final class LoxFunction: CustomStringConvertible, Callable {
    
    private let declaration: Function
    private let closure: Environment
    
    init(declaration: Function, closure: Environment) {
        self.declaration = declaration
        self.closure = closure
    }
        
    func arity() -> Int {
        declaration.params.count
    }
    
    func call(_ interpreter: Interpreter, _ arguments: [Any?]) throws -> Any? {
        let environment = Environment(interpreter.globals)
        for (index, param) in declaration.params.enumerated() {
            environment.define(param.lexeme, arguments[index])
        }
        do {
            try interpreter.executeBlock(declaration.body, environment)
        } catch {
            return (error as? ReturnError).flatMap { $0.value }
        }
        
        return nil
    }
    
    var description: String {
        "<fn " + declaration.name.lexeme + ">"
    }
}
