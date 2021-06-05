//
//  Environment.swift
//  Lox
//
//  Created by Алексей Якименко on 31.05.2021.
//

import Foundation

class Environment {
    
    private let enclosing: Environment?
    private var values: [String : Any?] = [:]
    
    init(_ enclosing: Environment? = nil) {
        self.enclosing = enclosing
    }
    
    func define(_ name: String, _ value: Any?) {
        values[name] = value
    }
    
    func assign(_ name: Token, _ value: Any?) throws {
        if values.keys.contains(name.lexeme) {
            return values[name.lexeme] = value
        }
        if let enclosing = enclosing {
            return try enclosing.assign(name, value)
        }
        throw RuntimeError(operator: name,
                           message: "Undefined variable '" + name.lexeme + "'.")
    }
    
    func get(_ name: Token) throws -> Any? {
        if values.keys.contains(name.lexeme) {
            if let value = values[name.lexeme],
               value != nil {
                return value
            }
            throw RuntimeError(operator: name,
                               message: "Unassigned variable '" + name.lexeme + "'.")
        }
        if let enclosing = enclosing {
            return try enclosing.get(name)
        }
        throw RuntimeError(operator: name,
                           message: "Undefined variable '" + name.lexeme + "'.")
    }
}
