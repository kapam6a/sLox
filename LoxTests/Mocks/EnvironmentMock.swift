//
//  Environment.swift
//  LoxTests
//
//  Created by Алексей Якименко on 02.06.2021.
//

import Foundation

struct EnvironmentMockError: Error {}

final class EnvironmentMock: Environment {
    
    var defineArgs: (String, Any?)?
    override func define(_ name: String, _ value: Any?) {
        defineArgs = (name, value)
    }
    
    var assignArgs: (Token, Any?)?
    var assignThrowError: Bool = false
    override func assign(_ name: Token, _ value: Any?) throws {
        assignArgs = (name, value)
        if assignThrowError { throw EnvironmentMockError() }
    }
    
    var getArg: Token?
    var getReturns: [Any?] = []
    var getThrowError: Bool = false
    override func get(_ name: Token) throws -> Any? {
        getArg = name
        if getThrowError { throw EnvironmentMockError() }
        if getReturns.isEmpty {
            return nil
        } else {
            return getReturns.removeLast()
        }
    }
}
