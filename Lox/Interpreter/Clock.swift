//
//  Clock.swift
//  Lox
//
//  Created by Алексей Якименко on 06.06.2021.
//

import Foundation

final class Clock: CustomStringConvertible, Callable {
    
    func arity() -> Int {
        0
    }
    
    func call(_ interpreter: Interpreter, _ arguments: [Any?]) -> Any? {
        Date().timeIntervalSinceReferenceDate / 1000.0
    }
    
    var description: String {
        "<native fn>"
    }
}
