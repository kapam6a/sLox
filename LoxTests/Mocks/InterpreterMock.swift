//
//  InterpreterMock.swift
//  LoxTests
//
//  Created by Алексей Якименко on 13.06.2021.
//

import Foundation

final class InterpreterMock: Interpreter {

    var resolveArgs: (Expr, Int)?
    override func resolve(_ expr: Expr, _ depth: Int) {
        resolveArgs = (expr, depth)
    }
}

