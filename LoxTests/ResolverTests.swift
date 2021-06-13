//
//  Resolver.swift
//  LoxTests
//
//  Created by Алексей Якименко on 13.06.2021.
//

import XCTest

final class ResolverTests: XCTestCase {
    
    private var sut: Resolver!
    private var interpreter: InterpreterMock!
    
    override func setUp() {
        super.setUp()
        
        interpreter = InterpreterMock()
        sut = Resolver(interpreter)
        Lox.hadError = false
    }
    
    override func tearDown() {
        interpreter = nil
        sut = nil
        
        super.tearDown()
    }
    
    func testResolve_returnInFunctionScope_doesNotReportError() throws {
        
        // given
        let stmt = [
            Function(name:Token(type: .identifier, lexeme: "get", literal: nil, line: 1),
                     params: [],
                     body: [
                        Return(
                            keyword: Token(type: .return, lexeme: "return", literal: nil, line: 1),
                            value: nil
                        )
                     ]
            )]
        
        // when
        try sut.resolve(stmt)
        
        // then
        XCTAssertFalse(Lox.hadError)
    }
    
    func testResolve_returnOutOfFunctionScope_reportsError() throws {
        
        // given
        let stmt = [
            Return(
                keyword: Token(type: .return, lexeme: "return", literal: nil, line: 1),
                value: nil)
        ]
        
        // when
        try sut.resolve(stmt)
        
        // then
        XCTAssertTrue(Lox.hadError)
    }

    func testResolve_globalVariableExpressionWithoutDeclaration_doesNotReportError() throws {
        
        // given
        let stmt = [
            Expression(
                expression:
                    Variable(name: Token(type: .identifier, lexeme: "name", literal: nil, line: 1)
                )
            )
            
        ]
        
        // when
        try sut.resolve(stmt)
        
        // then
        XCTAssertFalse(Lox.hadError)
    }
    
    func testResolve_localVariableExpressionWithoutDeclaration_reportsError() throws {
        
        // given
        let stmt = [
            Function(name:Token(type: .identifier, lexeme: "get", literal: nil, line: 1),
                     params: [],
                     body: [
                        Expression(
                            expression:
                                Variable(name: Token(type: .identifier, lexeme: "name", literal: nil, line: 1)
                            )
                        )
                     ]
            )]
        
        // when
        try sut.resolve(stmt)
        
        // then
        XCTAssertTrue(Lox.hadError)
    }
    
    func testResolve_localVariableExpressionWithDeclaration_doesNotReportError() throws {
        
        // given
        let stmt = [
            Function(name:Token(type: .identifier, lexeme: "get", literal: nil, line: 1),
                     params: [],
                     body: [
                        Var(name: Token(type: .identifier, lexeme: "name", literal: nil, line: 1),
                            initializer: nil),
                        Expression(
                            expression:
                                Variable(
                                    name: Token(type: .identifier, lexeme: "name", literal: nil, line: 1)
                                )
                        )
                     ]
            )]
        
        // when
        try sut.resolve(stmt)
        
        // then
        XCTAssertFalse(Lox.hadError)
    }
    
    func testResolve_repeatedVariableDecalration_reportsError() throws {
        
        // given
        let stmt = [
            Function(name:Token(type: .identifier, lexeme: "get", literal: nil, line: 1),
                     params: [],
                     body: [
                        Var(name: Token(type: .identifier, lexeme: "name", literal: nil, line: 1),
                            initializer: nil),
                        Var(name: Token(type: .identifier, lexeme: "name", literal: nil, line: 1),
                            initializer: nil),
                     ]
            )]
        
        // when
        try sut.resolve(stmt)
        
        // then
        XCTAssertTrue(Lox.hadError)
    }
    
    func testResolve_variableDeclarationAndAssignInSameScope_callsInterpreterResolveWithDepthIsZero() throws {
        
        // given
        let stmt = [
            Function(name:Token(type: .identifier, lexeme: "get", literal: nil, line: 1),
                     params: [],
                     body: [
                        Function(name:Token(type: .identifier, lexeme: "nested", literal: nil, line: 1),
                                 params: [],
                                 body: [
                                    Var(name: Token(type: .identifier, lexeme: "name", literal: nil, line: 1),
                                        initializer: nil),
                                    Expression(
                                        expression:
                                            Assign(
                                                name: Token(type: .identifier, lexeme: "name", literal: nil, line: 1),
                                                value: Literal(value: nil)
                                            )
                                    )
                                 ]
                        )
                     ]
            )]
        
        // when
        try sut.resolve(stmt)
        
        // then
        XCTAssertEqual(interpreter.resolveArgs?.1, 0)
        XCTAssertFalse(Lox.hadError)
    }
    
    func testResolve_variableDeclarationAndAssignInNeighboringScopes_callsInterpreterResolveWithDepthIsOne() throws {
        
        // given
        let stmt = [
            Function(name:Token(type: .identifier, lexeme: "get", literal: nil, line: 1),
                     params: [],
                     body: [
                        Var(name: Token(type: .identifier, lexeme: "name", literal: nil, line: 1),
                            initializer: nil),
                        Function(name:Token(type: .identifier, lexeme: "nested", literal: nil, line: 1),
                                 params: [],
                                 body: [
                                    Expression(
                                        expression:
                                            Assign(
                                                name: Token(type: .identifier, lexeme: "name", literal: nil, line: 1),
                                                value: Literal(value: nil)
                                            )
                                    )
                                 ]
                        )
                     ]
            )]
        
        // when
        try sut.resolve(stmt)
        
        // then
        XCTAssertEqual(interpreter.resolveArgs?.1, 1)
        XCTAssertFalse(Lox.hadError)
    }
}
