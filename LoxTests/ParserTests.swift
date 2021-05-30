//
//  ParserTests.swift
//  LoxTests
//
//  Created by Алексей Якименко on 29.05.2021.
//

import XCTest

final class ParserTests: XCTestCase {
    
    private var errorReporter: ErrorReporterMock!
    
    override func setUp() {
        super.setUp()
        
        errorReporter = ErrorReporterMock()
        Lox.hadError = false
        Lox.errorReporter = errorReporter
    }
    
    override func tearDown() {
        errorReporter = nil
        
        super.tearDown()
    }
    
    func testParse_number_returnsLiteral() {
        
        // given
        let sut = Parser(
            [Token(type: .number, lexeme: "23", literal: .number(23), line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(result, Literal(value: .number(23)))
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_string_returnsLiteral() {
        
        // given
        let sut = Parser(
            [Token(type: .string, lexeme: "\"Moscow city\"", literal: .string("Moscow city"), line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(result, Literal(value: .string("Moscow city")))
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_true_returnsLiteral() {
        
        // given
        let sut = Parser(
            [Token(type: .true, lexeme: "true", literal: nil, line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(result, Literal(value: .boolean(true)))
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_false_returnsLiteral() {
        
        // given
        let sut = Parser(
            [Token(type: .false, lexeme: "false", literal: nil, line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(result, Literal(value: .boolean(false)))
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_nil_returnsLiteral() {
        
        // given
        let sut = Parser(
            [Token(type: .nil, lexeme: "nil", literal: nil, line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(result, Literal(value: nil))
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_expressionWithParentheses_returnsGrouping() {
        
        // given
        let sut = Parser(
            [Token(type: .leftParen, lexeme: "(", literal: nil, line: 1),
             Token(type: .nil, lexeme: "nil", literal: nil, line: 1),
             Token(type: .rightParen, lexeme: ")", literal: nil, line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(result, Grouping(expressions: [Literal(value: nil)]))
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_numberWithMinus_returnsUnary() {
        
        // given
        let sut = Parser(
            [Token(type: .minus, lexeme: "-", literal: nil, line: 1),
             Token(type: .number, lexeme: "23", literal: .number(23), line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(
            result,
            Unary(
                operator: Token(type: .minus, lexeme: "-", literal: nil, line: 1),
                right: Literal(value: .number(23))
            )
        )
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_numberWithExclamationMark_returnsUnary() {
        
        // given
        let sut = Parser(
            [Token(type: .bang, lexeme: "!", literal: nil, line: 1),
             Token(type: .number, lexeme: "23", literal: .number(23), line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(
            result,
            Unary(
                operator: Token(type: .bang, lexeme: "!", literal: nil, line: 1),
                right: Literal(value: .number(23))
            )
        )
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_numberWithTwoExclamationMarks_returnsUnary() {
        
        // given
        let sut = Parser(
            [Token(type: .bang, lexeme: "!", literal: nil, line: 1),
             Token(type: .bang, lexeme: "!", literal: nil, line: 1),
             Token(type: .number, lexeme: "23", literal: .number(23), line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(
            result,
            Unary(
                operator: Token(type: .bang, lexeme: "!", literal: nil, line: 1),
                right: Unary(
                    operator: Token(type: .bang, lexeme: "!", literal: nil, line: 1),
                    right: Literal(value: .number(23))
                )
            )
        )
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_multiplicationOfTwoNumbers_returnsBinary() {
        
        // given
        let sut = Parser(
            [Token(type: .number, lexeme: "12", literal: .number(12), line: 1),
             Token(type: .star, lexeme: "*", literal: nil, line: 1),
             Token(type: .number, lexeme: "23", literal: .number(23), line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(
            result,
            Binary(
                left: Literal(value: .number(12)),
                operator: Token(type: .star, lexeme: "*", literal: nil, line: 1),
                right: Literal(value: .number(23))
            )
        )
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_divisionOfTwoNumbers_returnsBinary() {
        
        // given
        let sut = Parser(
            [Token(type: .number, lexeme: "12", literal: .number(12), line: 1),
             Token(type: .slash, lexeme: "/", literal: nil, line: 1),
             Token(type: .number, lexeme: "23", literal: .number(23), line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(
            result,
            Binary(
                left: Literal(value: .number(12)),
                operator: Token(type: .slash, lexeme: "/", literal: nil, line: 1),
                right: Literal(value: .number(23))
            )
        )
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_divisionOfThreeNumbers_returnsUnary() {
        
        // given
        let sut = Parser(
            [Token(type: .number, lexeme: "12", literal: .number(12), line: 1),
             Token(type: .slash, lexeme: "/", literal: nil, line: 1),
             Token(type: .number, lexeme: "23", literal: .number(23), line: 1),
             Token(type: .slash, lexeme: "/", literal: nil, line: 1),
             Token(type: .number, lexeme: "13", literal: .number(13), line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(
            result,
            Binary(
                left: Binary(
                    left: Literal(value: .number(12)),
                    operator: Token(type: .slash, lexeme: "/", literal: nil, line: 1),
                    right: Literal(value: .number(23))
                ),
                operator: Token(type: .slash, lexeme: "/", literal: nil, line: 1),
                right: Literal(value: .number(13))
            )
        )
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_additionOfTwoNumbers_returnsBinary() {
        
        // given
        let sut = Parser(
            [Token(type: .number, lexeme: "12", literal: .number(12), line: 1),
             Token(type: .plus, lexeme: "+", literal: nil, line: 1),
             Token(type: .number, lexeme: "23", literal: .number(23), line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(
            result,
            Binary(
                left: Literal(value: .number(12)),
                operator: Token(type: .plus, lexeme: "+", literal: nil, line: 1),
                right: Literal(value: .number(23))
            )
        )
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_subtractionOfTwoNumbers_returnsBinary() {
        
        // given
        let sut = Parser(
            [Token(type: .number, lexeme: "12", literal: .number(12), line: 1),
             Token(type: .minus, lexeme: "-", literal: nil, line: 1),
             Token(type: .number, lexeme: "23", literal: .number(23), line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(
            result,
            Binary(
                left: Literal(value: .number(12)),
                operator: Token(type: .minus, lexeme: "-", literal: nil, line: 1),
                right: Literal(value: .number(23))
            )
        )
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_subtractionOfThreeNumbers_returnsBinary() {
        
        // given
        let sut = Parser(
            [Token(type: .number, lexeme: "12", literal: .number(12), line: 1),
             Token(type: .minus, lexeme: "-", literal: nil, line: 1),
             Token(type: .number, lexeme: "23", literal: .number(23), line: 1),
             Token(type: .minus, lexeme: "-", literal: nil, line: 1),
             Token(type: .number, lexeme: "13", literal: .number(13), line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(
            result,
            Binary(
                left: Binary(
                    left: Literal(value: .number(12)),
                    operator: Token(type: .minus, lexeme: "-", literal: nil, line: 1),
                    right: Literal(value: .number(23))
                ),
                operator: Token(type: .minus, lexeme: "-", literal: nil, line: 1),
                right: Literal(value: .number(13))
            )
        )
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_numberGreaterThanAnother_returnsBinary() {
        
        // given
        let sut = Parser(
            [Token(type: .number, lexeme: "44", literal: .number(44), line: 1),
             Token(type: .greater, lexeme: ">", literal: nil, line: 1),
             Token(type: .number, lexeme: "33", literal: .number(33), line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(
            result,
            Binary(
                left: Literal(value: .number(44)),
                operator: Token(type: .greater, lexeme: ">", literal: nil, line: 1),
                right: Literal(value: .number(33))
            )
        )
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_numberGreaterOrEqualThanAnother_returnsBinary() {
        
        // given
        let sut = Parser(
            [Token(type: .number, lexeme: "44", literal: .number(44), line: 1),
             Token(type: .greaterEqual, lexeme: ">=", literal: nil, line: 1),
             Token(type: .number, lexeme: "33", literal: .number(33), line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(
            result,
            Binary(
                left: Literal(value: .number(44)),
                operator: Token(type: .greaterEqual, lexeme: ">=", literal: nil, line: 1),
                right: Literal(value: .number(33))
            )
        )
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_numberLessThanAnother_returnsBinary() {
        
        // given
        let sut = Parser(
            [Token(type: .number, lexeme: "44", literal: .number(44), line: 1),
             Token(type: .less, lexeme: "<", literal: nil, line: 1),
             Token(type: .number, lexeme: "33", literal: .number(33), line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(
            result,
            Binary(
                left: Literal(value: .number(44)),
                operator: Token(type: .less, lexeme: "<", literal: nil, line: 1),
                right: Literal(value: .number(33))
            )
        )
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_numberLessOrEqualThanAnother_returnsBinary() {
        
        // given
        let sut = Parser(
            [Token(type: .number, lexeme: "44", literal: .number(44), line: 1),
             Token(type: .lessEqual, lexeme: "<=", literal: nil, line: 1),
             Token(type: .number, lexeme: "33", literal: .number(33), line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(
            result,
            Binary(
                left: Literal(value: .number(44)),
                operator: Token(type: .lessEqual, lexeme: "<=", literal: nil, line: 1),
                right: Literal(value: .number(33))
            )
        )
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_numberLessThanAnotherAndLessThanThirdOne_returnsBinary() {
        
        // given
        let sut = Parser(
            [Token(type: .number, lexeme: "44", literal: .number(44), line: 1),
             Token(type: .less, lexeme: "<", literal: nil, line: 1),
             Token(type: .number, lexeme: "33", literal: .number(33), line: 1),
             Token(type: .less, lexeme: "<", literal: nil, line: 1),
             Token(type: .number, lexeme: "55", literal: .number(55), line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(
            result,
            Binary(
                left: Binary(
                    left: Literal(value: .number(44)),
                    operator: Token(type: .less, lexeme: "<", literal: nil, line: 1),
                    right: Literal(value: .number(33))
                ),
                operator: Token(type: .less, lexeme: "<", literal: nil, line: 1),
                right: Literal(value: .number(55))
            )
        )
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_equalOfTwoNumbers_returnsBinary() {
        
        // given
        let sut = Parser(
            [Token(type: .number, lexeme: "44", literal: .number(44), line: 1),
             Token(type: .equalEqual, lexeme: "==", literal: nil, line: 1),
             Token(type: .number, lexeme: "33", literal: .number(33), line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(
            result,
            Binary(
                left: Literal(value: .number(44)),
                operator: Token(type: .equalEqual, lexeme: "==", literal: nil, line: 1),
                right: Literal(value: .number(33))
            )
        )
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_notEqualOfTwoNumbers_returnsBinary() {
        
        // given
        let sut = Parser(
            [Token(type: .number, lexeme: "44", literal: .number(44), line: 1),
             Token(type: .bangEqual, lexeme: "!=", literal: nil, line: 1),
             Token(type: .number, lexeme: "33", literal: .number(33), line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(
            result,
            Binary(
                left: Literal(value: .number(44)),
                operator: Token(type: .bangEqual, lexeme: "!=", literal: nil, line: 1),
                right: Literal(value: .number(33))
            )
        )
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_equalOfThreeNumbers_returnsBinary() {
        
        // given
        let sut = Parser(
            [Token(type: .number, lexeme: "44", literal: .number(44), line: 1),
             Token(type: .equalEqual, lexeme: "==", literal: nil, line: 1),
             Token(type: .number, lexeme: "33", literal: .number(33), line: 1),
             Token(type: .equalEqual, lexeme: "==", literal: nil, line: 1),
             Token(type: .number, lexeme: "55", literal: .number(55), line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(
            result,
            Binary(
                left: Binary(
                    left: Literal(value: .number(44)),
                    operator: Token(type: .equalEqual, lexeme: "==", literal: nil, line: 1),
                    right: Literal(value: .number(33))
                ),
                operator: Token(type: .equalEqual, lexeme: "==", literal: nil, line: 1),
                right: Literal(value: .number(55))
            )
        )
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_complexArithmeticExpression_returnsBinary() {
        
        // given
        let sut = Parser(
            [Token(type: .leftParen, lexeme: "(", literal: nil, line: 1),
             Token(type: .number, lexeme: "44", literal: .number(44), line: 1),
             Token(type: .greater, lexeme: ">", literal: nil, line: 1),
             Token(type: .number, lexeme: "33", literal: .number(33), line: 1),
             Token(type: .plus, lexeme: "+", literal: nil, line: 1),
             Token(type: .number, lexeme: "11", literal: .number(11), line: 1),
             Token(type: .slash, lexeme: "/", literal: nil, line: 1),
             Token(type: .number, lexeme: "22", literal: .number(22), line: 1),
             Token(type: .rightParen, lexeme: ")", literal: nil, line: 1),
             Token(type: .star, lexeme: "*", literal: nil, line: 1),
             Token(type: .number, lexeme: "2", literal: .number(2), line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(
            result,
            Binary(
                left: Grouping(
                    expressions: [
                        Binary(
                            left: Literal(value: .number(44)),
                            operator: Token(type: .greater, lexeme: ">", literal: nil, line: 1),
                            right: Binary(
                                left: Literal(value: .number(33)),
                                operator: Token(type: .plus, lexeme: "+", literal: nil, line: 1),
                                right: Binary(
                                    left: Literal(value: .number(11)),
                                    operator: Token(type: .slash, lexeme: "/", literal: nil, line: 1),
                                    right: Literal(value: .number(22))
                                )
                            )
                        )
                    ]
                ),
                operator: Token(type: .star, lexeme: "*", literal: nil, line: 1),
                right: Literal(value: .number(2))
            )
        )
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_expressionWithLeftParenthesisOnly_reportsError() {
        
        // given
        let sut = Parser(
            [Token(type: .leftParen, lexeme: "(", literal: nil, line: 1),
             Token(type: .nil, lexeme: "nil", literal: nil, line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(result, nil)
        XCTAssertTrue(Lox.hadError)
    }
    
    func testParse_wrongExpression_reportsError() {
        
        // given
        let sut = Parser(
            [Token(type: .leftParen, lexeme: ")", literal: nil, line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(result, nil)
        XCTAssertTrue(Lox.hadError)
    }
    
    func testParse_eofOnly_returnsError() {
        
        // given
        let sut = Parser(
            [Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(result, nil)
        XCTAssertTrue(Lox.hadError)
    }
    
    func testParse_groupOfExpressions_returnsGroup() {
        
        // given
        let sut = Parser(
            [Token(type: .leftParen, lexeme: "(", literal: nil, line: 1),
             Token(type: .number, lexeme: "22", literal: .number(22), line: 1),
             Token(type: .comma, lexeme: ",", literal: nil, line: 1),
             Token(type: .number, lexeme: "33", literal: .number(33), line: 1),
             Token(type: .plus, lexeme: "+", literal: nil, line: 1),
             Token(type: .number, lexeme: "11", literal: .number(11), line: 1),
             Token(type: .rightParen, lexeme: ")", literal: nil, line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(
            result,
            Grouping(
                expressions: [
                    Literal(value: .number(22)),
                    Binary(
                        left: Literal(value: .number(33)),
                        operator: Token(type: .plus, lexeme: "+", literal: nil, line: 1),
                        right: Literal(value: .number(11)))
                ]
            )
        )
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_numberWithPlus_reportsSpecificError() {
        
        // given
        let sut = Parser(
            [Token(type: .plus, lexeme: "+", literal: nil, line: 1),
             Token(type: .number, lexeme: "23", literal: .number(23), line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(result, nil)
        XCTAssertEqual(errorReporter.reportArgs?.2, "Unary ‘+’ expressions are not supported")
    }
}
