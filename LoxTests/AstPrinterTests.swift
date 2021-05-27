//
//  AstPrinterTests.swift
//  LoxTests
//
//  Created by Алексей Якименко on 27.05.2021.
//

import XCTest

final class AstPrinterTests: XCTestCase {
    
    private var sut: AstPrinter!
    
    override func setUp() {
        super.setUp()
        
        sut = AstPrinter()
    }
    
    override func tearDown() {
        sut = nil

        super.tearDown()
    }
    
    func testPrint_withBinaryExpr_returnsNpnString() throws {
        
        // given
        let expr = Binary(
            left: Unary(
                operator: Token(type: .minus, lexeme: "-", literal: nil, line: 1),
                right: Literal(value: .number(123))),
            operator: Token(type: .star, lexeme: "*", literal: nil, line: 1),
            right: Grouping(
                expression: Literal(value: .number(45.67))
            )
        )
        
        // when
        let result = sut.print(expr)
        
        // then
        XCTAssertEqual(result, "(* (- 123) (group 45,67))")
    }
}
