//
//  EnvironmentTests.swift
//  LoxTests
//
//  Created by Алексей Якименко on 03.06.2021.
//

import XCTest

final class EnvironmentTests: XCTestCase {
    
    private var sut: Environment!
    private var enclosingEnvironment: EnvironmentMock!
    
    override func setUp() {
        super.setUp()
        
        enclosingEnvironment = EnvironmentMock()
        sut = Environment(enclosingEnvironment)
    }
    
    override func tearDown() {
        enclosingEnvironment = nil
        sut = nil
        
        super.tearDown()
    }
    
    func testGet_whenVariableIsDefined_returnsValue() throws {
        
        // given
        sut.define("age", 23)
        
        // when
        let result = try sut.get(Token(type: .identifier, lexeme: "age", literal: nil, line: 1))
        
        // then
        XCTAssertEqual(result as? Int, 23)
    }
    
    func testGet_whenVariableIsNotDefined_callsEnclosingEnvironmentGet() throws {
        
        // when
        _ = try sut.get(Token(type: .identifier, lexeme: "age", literal: nil, line: 1))
        
        // then
        XCTAssertEqual(
            enclosingEnvironment.getArg,
            Token(type: .identifier, lexeme: "age", literal: nil, line: 1)
        )
    }
    
    func testGet_whenVariableIsNotDefined_returnsEnclosingEnvironmentValue() throws {
        
        // given
        enclosingEnvironment.getReturn = 23
        
        // when
        let result = try sut.get(Token(type: .identifier, lexeme: "age", literal: nil, line: 1))
        
        // then
        XCTAssertEqual(result as? Int, 23)
    }
    
    func testGet_whenEnclosingEnvironmentThrowsError_throwsError() throws {
        
        // given
        enclosingEnvironment.getThrowError = true
           
        // when
        // then
        XCTAssertThrowsError(_ = try sut.get(Token(type: .identifier, lexeme: "age", literal: nil, line: 1)))
    }
    
    func testAssign_whenVariableIsDefined_returnsValue() throws {
        
        // given
        sut.define("age", 23)
        
        // when
        try sut.assign(Token(type: .identifier, lexeme: "age", literal: nil, line: 1), 45)
        
        // then
        let result = try sut.get(Token(type: .identifier, lexeme: "age", literal: nil, line: 1))
        XCTAssertEqual(result as? Int, 45)
    }
    
    func testGet_whenVariableIsNotDefined_callsEnclosingEnvironmentAssign() throws {
        
        // when
        try sut.assign(Token(type: .identifier, lexeme: "age", literal: nil, line: 1), 45)
        
        // then
        XCTAssertEqual(
            enclosingEnvironment.assignArgs?.0,
            Token(type: .identifier, lexeme: "age", literal: nil, line: 1)
        )
        XCTAssertEqual(
            enclosingEnvironment.assignArgs?.1 as? Int,
            45
        )
    }
    
    func testAssign_whenEnclosingEnvironmentThrowsError_throwsError() throws {
        
        // given
        enclosingEnvironment.assignThrowError = true
           
        // when
        // then
        XCTAssertThrowsError(try sut.assign(Token(type: .identifier, lexeme: "age", literal: nil, line: 1), 45))
    }
}
