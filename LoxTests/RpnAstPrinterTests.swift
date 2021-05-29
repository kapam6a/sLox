//
//  RpnAstPrinter.swift
//  LoxTests
//
//  Created by Алексей Якименко on 27.05.2021.
//

import XCTest

final class RpnAstPrinterTests: XCTestCase {
    
    private var sut: RpnAstPrinter!
    
    override func setUp() {
        super.setUp()
        
        sut = RpnAstPrinter()
    }
    
    override func tearDown() {
        sut = nil

        super.tearDown()
    }
    
    func testPrint_withBinaryExpr_returnsRpnString() {
        
        // given
        let exp = Binary(
            left: Binary(
                left: Grouping(expressions: [Literal(value: .number(1))]),
                operator: Token(type: .plus, lexeme: "+", literal: nil, line: 1),
                right: Grouping(expressions: [Literal(value: .number(2))])
            ),
            operator: Token(type: .star, lexeme: "*", literal: nil, line: 1),
            right: Binary(
                left: Grouping(expressions: [Literal(value: .number(4))]),
                operator: Token(type: .minus, lexeme: "-", literal: nil, line: 1),
                right: Grouping(expressions: [Literal(value: .number(3))])
            )
        )
        
        // when
        let result = sut.print(exp)
        
        // then
        XCTAssertEqual(result, "1 2 + 4 3 - *")
    }
}
