//
//  Environment.swift
//  LoxTests
//
//  Created by Алексей Якименко on 02.06.2021.
//

import Foundation

final class EnvironmentMock: Environment {
    
    var defineArgs: (String, Any)?
    override func define(_ name: String, _ value: Any?) {
        defineArgs = (name, value)
    }
    
    var assignArgs: (Token, Any?)?
    override func assign(_ name: Token, _ value: Any?) throws {
        assignArgs = (name, value)
    }
    
    var getArg: Token?
    var getReturn: Any?
    override func get(_ name: Token) throws -> Any? {
        getArg = name
        return getReturn
    }
}
