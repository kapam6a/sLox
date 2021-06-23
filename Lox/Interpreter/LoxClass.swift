//
//  LoxClass.swift
//  Lox
//
//  Created by Алексей Якименко on 13.06.2021.
//

import Foundation

final class LoxClass: CustomStringConvertible, Callable {
    
    private let name: String
    private let methods: Dictionary<String, LoxFunction>
    
    init(_ name: String,
         _ methods: Dictionary<String, LoxFunction>) {
        self.name = name
        self.methods = methods
    }
    
    func arity() -> Int {
        if let initializer = findMethod("init") {
            return initializer.arity()
        } else {
            return 0
        }        
    }
    
    func call(_ interpreter: Interpreter, _ arguments: [Any?]) throws -> Any? {
        let instance = LoxInstance(self)
        if let initializer = findMethod("init") {
            try initializer.bind(instance).call(interpreter, arguments)
        }
        return instance
    }
    
    var description: String {
        name
    }
    
    func findMethod(_ name: String) -> LoxFunction? {
        methods[name]
    }
}
