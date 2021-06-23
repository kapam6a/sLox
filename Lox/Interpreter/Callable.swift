//
//  Callable.swift
//  Lox
//
//  Created by Алексей Якименко on 06.06.2021.
//

protocol Callable {
    
    func arity() -> Int
    @discardableResult func call(_ interpreter: Interpreter, _ arguments: [Any?]) throws -> Any?
}
