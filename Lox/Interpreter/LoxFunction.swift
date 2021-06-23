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
    private let isInitializer: Bool
    
    init(declaration: Function,
         closure: Environment,
         isInitializer: Bool) {
        self.declaration = declaration
        self.closure = closure
        self.isInitializer = isInitializer
    }
        
    func arity() -> Int {
        declaration.params.count
    }
    
    @discardableResult func call(_ interpreter: Interpreter, _ arguments: [Any?]) throws -> Any? {
        let environment = Environment(interpreter.globals)
        for (index, param) in declaration.params.enumerated() {
            environment.define(param.lexeme, arguments[index])
        }
        do {
            try interpreter.executeBlock(declaration.body, environment)
        } catch {
            if let returnError = error as? ReturnError {
                if isInitializer { return try closure.get(at: 0, "this") }
                return returnError.value
            }
            throw error
        }
        if isInitializer { return try closure.get(at: 0, "this") }
        
        return nil
    }
    
    func bind(_ instance: LoxInstance) -> LoxFunction {
        let environment = Environment(closure)
        environment.define("this", instance)
        return LoxFunction(declaration: declaration, closure: environment, isInitializer: isInitializer)
     }
    
    var description: String {
        "<fn " + declaration.name.lexeme + ">"
    }
}
