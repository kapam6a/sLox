//
//  LoxInstance.swift
//  Lox
//
//  Created by Алексей Якименко on 13.06.2021.
//

import Foundation

final class LoxInstance: CustomStringConvertible {
    
    private let `class`: LoxClass
    private var fields: Dictionary<String, Any?> = [:]
    
    init(_ `class`: LoxClass) {
        self.`class` = `class`
    }
    
    var description: String {
        `class`.description + " instance"
    }
    
    func get(_ name: Token) throws -> Any? {
        if let field = fields[name.lexeme] {
            return field
        }
        if let method = `class`.findMethod(name.lexeme) {
            return method.bind(self)
        }
        throw RuntimeError(operator: name, message: "Undefined property '" + name.lexeme + "'.")
    }
    
    func set(_ name: Token, _ value: Any?) {
        fields[name.lexeme] = value
    }
}
