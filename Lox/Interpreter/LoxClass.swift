//
//  LoxClass.swift
//  Lox
//
//  Created by Алексей Якименко on 13.06.2021.
//

import Foundation

final class LoxClass: CustomStringConvertible, Callable {
    
    private let name: String
    private let superclass: LoxClass?
    private let methods: Dictionary<String, LoxFunction>
    
    init(_ name: String,
         _ superclass: LoxClass?,
         _ methods: Dictionary<String, LoxFunction>) {
        self.name = name
        self.superclass = superclass
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
        if methods.keys.contains(name) {
            return methods[name]
        }
        if let superclass = superclass {
            return superclass.findMethod(name)
        }
        return nil
    }
}
