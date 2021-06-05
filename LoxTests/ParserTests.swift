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
             Token(type: .semicolon, lexeme: ";", literal: .number(23), line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(result, [Expression(expression:Literal(value: .number(23)))])
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_string_returnsLiteral() {
        
        // given
        let sut = Parser(
            [Token(type: .string, lexeme: "\"Moscow city\"", literal: .string("Moscow city"), line: 1),
             Token(type: .semicolon, lexeme: ";", literal: .number(23), line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(result, [Expression(expression:Literal(value: .string("Moscow city")))])
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_true_returnsLiteral() {
        
        // given
        let sut = Parser(
            [Token(type: .true, lexeme: "true", literal: nil, line: 1),
             Token(type: .semicolon, lexeme: ";", literal: .number(23), line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(result, [Expression(expression:Literal(value: .boolean(true)))])
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_false_returnsLiteral() {
        
        // given
        let sut = Parser(
            [Token(type: .false, lexeme: "false", literal: nil, line: 1),
             Token(type: .semicolon, lexeme: ";", literal: .number(23), line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(result, [Expression(expression:Literal(value: .boolean(false)))])
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_nil_returnsLiteral() {
        
        // given
        let sut = Parser(
            [Token(type: .nil, lexeme: "nil", literal: nil, line: 1),
             Token(type: .semicolon, lexeme: ";", literal: .number(23), line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(result, [Expression(expression:Literal(value: nil))])
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_expressionWithParentheses_returnsGrouping() {
        
        // given
        let sut = Parser(
            [Token(type: .leftParen, lexeme: "(", literal: nil, line: 1),
             Token(type: .nil, lexeme: "nil", literal: nil, line: 1),
             Token(type: .rightParen, lexeme: ")", literal: nil, line: 1),
             Token(type: .semicolon, lexeme: ";", literal: .number(23), line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(result, [Expression(expression:Grouping(expressions: [Literal(value: nil)]))])
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_numberWithMinus_returnsUnary() {
        
        // given
        let sut = Parser(
            [Token(type: .minus, lexeme: "-", literal: nil, line: 1),
             Token(type: .number, lexeme: "23", literal: .number(23), line: 1),
             Token(type: .semicolon, lexeme: ";", literal: .number(23), line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(
            result,
            [Expression(
                expression:Unary(
                    operator: Token(type: .minus, lexeme: "-", literal: nil, line: 1),
                    right: Literal(value: .number(23))
                )
            )]
        )
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_numberWithExclamationMark_returnsUnary() {
        
        // given
        let sut = Parser(
            [Token(type: .bang, lexeme: "!", literal: nil, line: 1),
             Token(type: .number, lexeme: "23", literal: .number(23), line: 1),
             Token(type: .semicolon, lexeme: ";", literal: .number(23), line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(
            result,
            [Expression(
                expression:Unary(
                    operator: Token(type: .bang, lexeme: "!", literal: nil, line: 1),
                    right: Literal(value: .number(23))
                )
            )]
        )
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_numberWithTwoExclamationMarks_returnsUnary() {
        
        // given
        let sut = Parser(
            [Token(type: .bang, lexeme: "!", literal: nil, line: 1),
             Token(type: .bang, lexeme: "!", literal: nil, line: 1),
             Token(type: .number, lexeme: "23", literal: .number(23), line: 1),
             Token(type: .semicolon, lexeme: ";", literal: .number(23), line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(
            result,
            [Expression(
                expression:Unary(
                    operator: Token(type: .bang, lexeme: "!", literal: nil, line: 1),
                    right: Unary(
                        operator: Token(type: .bang, lexeme: "!", literal: nil, line: 1),
                        right: Literal(value: .number(23))
                    )
                )
            )]
        )
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_multiplicationOfTwoNumbers_returnsBinary() {
        
        // given
        let sut = Parser(
            [Token(type: .number, lexeme: "12", literal: .number(12), line: 1),
             Token(type: .star, lexeme: "*", literal: nil, line: 1),
             Token(type: .number, lexeme: "23", literal: .number(23), line: 1),
             Token(type: .semicolon, lexeme: ";", literal: .number(23), line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(
            result,
            [Expression(
                expression:Binary(
                    left: Literal(value: .number(12)),
                    operator: Token(type: .star, lexeme: "*", literal: nil, line: 1),
                    right: Literal(value: .number(23))
                )
            )]
        )
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_divisionOfTwoNumbers_returnsBinary() {
        
        // given
        let sut = Parser(
            [Token(type: .number, lexeme: "12", literal: .number(12), line: 1),
             Token(type: .slash, lexeme: "/", literal: nil, line: 1),
             Token(type: .number, lexeme: "23", literal: .number(23), line: 1),
             Token(type: .semicolon, lexeme: ";", literal: .number(23), line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(
            result,
            [Expression(
                expression:Binary(
                    left: Literal(value: .number(12)),
                    operator: Token(type: .slash, lexeme: "/", literal: nil, line: 1),
                    right: Literal(value: .number(23))
                )
            )]
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
             Token(type: .semicolon, lexeme: ";", literal: .number(23), line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(
            result,
            [Expression(
                expression:Binary(
                    left: Binary(
                        left: Literal(value: .number(12)),
                        operator: Token(type: .slash, lexeme: "/", literal: nil, line: 1),
                        right: Literal(value: .number(23))
                    ),
                    operator: Token(type: .slash, lexeme: "/", literal: nil, line: 1),
                    right: Literal(value: .number(13))
                )
            )]
        )
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_additionOfTwoNumbers_returnsBinary() {
        
        // given
        let sut = Parser(
            [Token(type: .number, lexeme: "12", literal: .number(12), line: 1),
             Token(type: .plus, lexeme: "+", literal: nil, line: 1),
             Token(type: .number, lexeme: "23", literal: .number(23), line: 1),
             Token(type: .semicolon, lexeme: ";", literal: .number(23), line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(
            result,
            [Expression(
                expression:Binary(
                    left: Literal(value: .number(12)),
                    operator: Token(type: .plus, lexeme: "+", literal: nil, line: 1),
                    right: Literal(value: .number(23))
                )
            )]
        )
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_subtractionOfTwoNumbers_returnsBinary() {
        
        // given
        let sut = Parser(
            [Token(type: .number, lexeme: "12", literal: .number(12), line: 1),
             Token(type: .minus, lexeme: "-", literal: nil, line: 1),
             Token(type: .number, lexeme: "23", literal: .number(23), line: 1),
             Token(type: .semicolon, lexeme: ";", literal: .number(23), line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(
            result,
            [Expression(
                expression:Binary(
                    left: Literal(value: .number(12)),
                    operator: Token(type: .minus, lexeme: "-", literal: nil, line: 1),
                    right: Literal(value: .number(23))
                )
            )]
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
             Token(type: .semicolon, lexeme: ";", literal: .number(23), line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(
            result,
            [Expression(
                expression:Binary(
                    left: Binary(
                        left: Literal(value: .number(12)),
                        operator: Token(type: .minus, lexeme: "-", literal: nil, line: 1),
                        right: Literal(value: .number(23))
                    ),
                    operator: Token(type: .minus, lexeme: "-", literal: nil, line: 1),
                    right: Literal(value: .number(13))
                )
            )]
        )
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_numberGreaterThanAnother_returnsBinary() {
        
        // given
        let sut = Parser(
            [Token(type: .number, lexeme: "44", literal: .number(44), line: 1),
             Token(type: .greater, lexeme: ">", literal: nil, line: 1),
             Token(type: .number, lexeme: "33", literal: .number(33), line: 1),
             Token(type: .semicolon, lexeme: ";", literal: .number(23), line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(
            result,
            [Expression(
                expression:Binary(
                    left: Literal(value: .number(44)),
                    operator: Token(type: .greater, lexeme: ">", literal: nil, line: 1),
                    right: Literal(value: .number(33))
                )
            )]
        )
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_numberGreaterOrEqualThanAnother_returnsBinary() {
        
        // given
        let sut = Parser(
            [Token(type: .number, lexeme: "44", literal: .number(44), line: 1),
             Token(type: .greaterEqual, lexeme: ">=", literal: nil, line: 1),
             Token(type: .number, lexeme: "33", literal: .number(33), line: 1),
             Token(type: .semicolon, lexeme: ";", literal: .number(23), line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(
            result,
            [Expression(
                expression:Binary(
                    left: Literal(value: .number(44)),
                    operator: Token(type: .greaterEqual, lexeme: ">=", literal: nil, line: 1),
                    right: Literal(value: .number(33))
                )
            )]
        )
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_numberLessThanAnother_returnsBinary() {
        
        // given
        let sut = Parser(
            [Token(type: .number, lexeme: "44", literal: .number(44), line: 1),
             Token(type: .less, lexeme: "<", literal: nil, line: 1),
             Token(type: .number, lexeme: "33", literal: .number(33), line: 1),
             Token(type: .semicolon, lexeme: ";", literal: .number(23), line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(
            result,
            [Expression(
                expression:Binary(
                    left: Literal(value: .number(44)),
                    operator: Token(type: .less, lexeme: "<", literal: nil, line: 1),
                    right: Literal(value: .number(33))
                )
            )]
        )
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_numberLessOrEqualThanAnother_returnsBinary() {
        
        // given
        let sut = Parser(
            [Token(type: .number, lexeme: "44", literal: .number(44), line: 1),
             Token(type: .lessEqual, lexeme: "<=", literal: nil, line: 1),
             Token(type: .number, lexeme: "33", literal: .number(33), line: 1),
             Token(type: .semicolon, lexeme: ";", literal: .number(23), line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(
            result,
            [Expression(
                expression:Binary(
                    left: Literal(value: .number(44)),
                    operator: Token(type: .lessEqual, lexeme: "<=", literal: nil, line: 1),
                    right: Literal(value: .number(33))
                )
            )]
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
             Token(type: .semicolon, lexeme: ";", literal: .number(23), line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(
            result,
            [Expression(
                expression:Binary(
                    left: Binary(
                        left: Literal(value: .number(44)),
                        operator: Token(type: .less, lexeme: "<", literal: nil, line: 1),
                        right: Literal(value: .number(33))
                    ),
                    operator: Token(type: .less, lexeme: "<", literal: nil, line: 1),
                    right: Literal(value: .number(55))
                )
            )]
        )
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_equalOfTwoNumbers_returnsBinary() {
        
        // given
        let sut = Parser(
            [Token(type: .number, lexeme: "44", literal: .number(44), line: 1),
             Token(type: .equalEqual, lexeme: "==", literal: nil, line: 1),
             Token(type: .number, lexeme: "33", literal: .number(33), line: 1),
             Token(type: .semicolon, lexeme: ";", literal: .number(23), line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(
            result,
            [Expression(
                expression:Binary(
                    left: Literal(value: .number(44)),
                    operator: Token(type: .equalEqual, lexeme: "==", literal: nil, line: 1),
                    right: Literal(value: .number(33))
                )
            )]
        )
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_notEqualOfTwoNumbers_returnsBinary() {
        
        // given
        let sut = Parser(
            [Token(type: .number, lexeme: "44", literal: .number(44), line: 1),
             Token(type: .bangEqual, lexeme: "!=", literal: nil, line: 1),
             Token(type: .number, lexeme: "33", literal: .number(33), line: 1),
             Token(type: .semicolon, lexeme: ";", literal: .number(23), line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(
            result,
            [Expression(
                expression:Binary(
                    left: Literal(value: .number(44)),
                    operator: Token(type: .bangEqual, lexeme: "!=", literal: nil, line: 1),
                    right: Literal(value: .number(33))
                )
            )]
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
             Token(type: .semicolon, lexeme: ";", literal: .number(23), line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(
            result,
            [Expression(
                expression:Binary(
                    left: Binary(
                        left: Literal(value: .number(44)),
                        operator: Token(type: .equalEqual, lexeme: "==", literal: nil, line: 1),
                        right: Literal(value: .number(33))
                    ),
                    operator: Token(type: .equalEqual, lexeme: "==", literal: nil, line: 1),
                    right: Literal(value: .number(55))
                )
            )]
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
             Token(type: .semicolon, lexeme: ";", literal: .number(23), line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(
            result,
            [Expression(
                expression:Binary(
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
            )]
        )
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_expressionWithLeftParenthesisOnly_reportsError() {
        
        // given
        let sut = Parser(
            [Token(type: .leftParen, lexeme: "(", literal: nil, line: 1),
             Token(type: .nil, lexeme: "nil", literal: nil, line: 1),
             Token(type: .semicolon, lexeme: ";", literal: .number(23), line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        _ = sut.parse()
        
        // then
        XCTAssertTrue(Lox.hadError)
    }
    
    func testParse_wrongExpression_reportsError() {
        
        // given
        let sut = Parser(
            [Token(type: .leftParen, lexeme: ")", literal: nil, line: 1),
             Token(type: .semicolon, lexeme: ";", literal: .number(23), line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        _ = sut.parse()
        
        // then
        XCTAssertTrue(Lox.hadError)
    }
    
    func testParse_eofOnly_returnsNothing() {
        
        // given
        let sut = Parser(
            [Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(result, [])
        XCTAssertFalse(Lox.hadError)
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
             Token(type: .semicolon, lexeme: ";", literal: .number(23), line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(
            result,
            [Expression(
                expression:Grouping(
                    expressions: [
                        Literal(value: .number(22)),
                        Binary(
                            left: Literal(value: .number(33)),
                            operator: Token(type: .plus, lexeme: "+", literal: nil, line: 1),
                            right: Literal(value: .number(11)))
                    ]
                )
            )]
        )
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_numberWithPlus_reportsSpecificError() {
        
        // given
        let sut = Parser(
            [Token(type: .plus, lexeme: "+", literal: nil, line: 1),
             Token(type: .number, lexeme: "23", literal: .number(23), line: 1),
             Token(type: .semicolon, lexeme: ";", literal: .number(23), line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(result, [])
        XCTAssertEqual(errorReporter.reportArgs?.2, "Unary ‘+’ expressions are not supported")
    }
}

extension ParserTests {
    
    func testParse_identifierEqualToNumber_retunsAssign() {
        
        // given
        let sut = Parser(
            [Token(type: .identifier, lexeme: "age", literal: nil, line: 1),
             Token(type: .equal, lexeme: "=", literal: nil, line: 1),
             Token(type: .number, lexeme: "23", literal: .number(23), line: 1),
             Token(type: .semicolon, lexeme: ";", literal: nil, line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(
            result,
            [Expression(
                expression: Assign(
                    name: Token(type: .identifier, lexeme: "age", literal: nil, line: 1),
                    value: Literal(value: .number(23))
                )
            )]
        )
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_numberEqualToNumber_reportsError() {
        
        // given
        let sut = Parser(
            [Token(type: .number, lexeme: "13", literal: .number(13), line: 1),
             Token(type: .equal, lexeme: "=", literal: nil, line: 1),
             Token(type: .number, lexeme: "23", literal: .number(23), line: 1),
             Token(type: .semicolon, lexeme: ";", literal: nil, line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        _ = sut.parse()
        
        // then
        XCTAssertTrue(Lox.hadError)
    }
    
    func testParse_numberEqualToNothing_reportsError() {
        
        // given
        let sut = Parser(
            [Token(type: .number, lexeme: "13", literal: .number(13), line: 1),
             Token(type: .equal, lexeme: "=", literal: nil, line: 1),
             Token(type: .semicolon, lexeme: ";", literal: nil, line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        _ = sut.parse()
        
        // then
        XCTAssertTrue(Lox.hadError)
    }
    
    func testParse_identifierEqualToNumberWithoutSemicolon_reportsError() {

        // given
        let sut = Parser(
            [Token(type: .identifier, lexeme: "age", literal: nil, line: 1),
             Token(type: .equal, lexeme: "=", literal: nil, line: 1),
             Token(type: .number, lexeme: "23", literal: .number(23), line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )

        // when
        _ = sut.parse()

        // then
        XCTAssertTrue(Lox.hadError)
    }
    
    func testParse_printWithNumber_retunsPrint() {
        
        // given
        let sut = Parser(
            [Token(type: .print, lexeme: "print", literal: nil, line: 1),
             Token(type: .number, lexeme: "23", literal: .number(23), line: 1),
             Token(type: .semicolon, lexeme: ";", literal: nil, line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(result, [Print(expression:Literal(value: .number(23)))])
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_printWithNumberWithoutSemicolon_reportsError() {
        
        // given
        let sut = Parser(
            [Token(type: .print, lexeme: "print", literal: nil, line: 1),
             Token(type: .number, lexeme: "23", literal: .number(23), line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        _ = sut.parse()
        
        // then
        XCTAssertTrue(Lox.hadError)
    }
    
    func testParse_varWithoutInitializer_retunsVar() {
        
        // given
        let sut = Parser(
            [Token(type: .var, lexeme: "var", literal: nil, line: 1),
             Token(type: .identifier, lexeme: "age", literal: nil, line: 1),
             Token(type: .semicolon, lexeme: ";", literal: nil, line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(
            result,
            [Var(
                name: Token(type: .identifier, lexeme: "age", literal: nil, line: 1),
                initializer: nil
            )]
        )
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_varWithInitializer_retunsVar() {
        
        // given
        let sut = Parser(
            [Token(type: .var, lexeme: "var", literal: nil, line: 1),
             Token(type: .identifier, lexeme: "age", literal: nil, line: 1),
             Token(type: .equal, lexeme: "=", literal: nil, line: 1),
             Token(type: .number, lexeme: "23", literal: .number(23), line: 1),
             Token(type: .semicolon, lexeme: ";", literal: nil, line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(
            result,
            [Var(
                name: Token(type: .identifier, lexeme: "age", literal: nil, line: 1),
                initializer: Literal(value: .number(23))
            )]
        )
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_varWithoutSemicolon_reportsError() {
        
        // given
        let sut = Parser(
            [Token(type: .var, lexeme: "var", literal: nil, line: 1),
             Token(type: .identifier, lexeme: "age", literal: nil, line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        _ = sut.parse()
        
        // then
        XCTAssertTrue(Lox.hadError)
    }
    
    func testParse_varWithNumber_reportsError() {
        
        // given
        let sut = Parser(
            [Token(type: .var, lexeme: "var", literal: nil, line: 1),
             Token(type: .number, lexeme: "23", literal: .number(23), line: 1),
             Token(type: .semicolon, lexeme: ";", literal: nil, line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        _ = sut.parse()
        
        // then
        XCTAssertTrue(Lox.hadError)
    }
    
    func testParse_blockWithoutStatements_retunsBlock() {
        
        // given
        let sut = Parser(
            [Token(type: .leftBrace, lexeme: "{", literal: nil, line: 1),
             Token(type: .rightBrace, lexeme: "}", literal: nil, line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(result, [Block(statements: [])])
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_blockWithSemicolon_reportsError() {
        
        // given
        let sut = Parser(
            [Token(type: .leftBrace, lexeme: "{", literal: nil, line: 1),
             Token(type: .rightBrace, lexeme: "}", literal: nil, line: 1),
             Token(type: .semicolon, lexeme: ";", literal: nil, line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        _ = sut.parse()
        
        // then
        XCTAssertTrue(Lox.hadError)
    }
    
    func testParse_blockWithStatements_retunsBlock() {
        
        // given
        let sut = Parser(
            [Token(type: .leftBrace, lexeme: "{", literal: nil, line: 1),
             Token(type: .var, lexeme: "var", literal: nil, line: 1),
             Token(type: .identifier, lexeme: "age", literal: nil, line: 1),
             Token(type: .equal, lexeme: "=", literal: nil, line: 1),
             Token(type: .number, lexeme: "23", literal: .number(23), line: 1),
             Token(type: .semicolon, lexeme: ";", literal: nil, line: 1),
             Token(type: .rightBrace, lexeme: "}", literal: nil, line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(
            result,
            [Block(
                statements: [
                    Var(
                        name: Token(type: .identifier, lexeme: "age", literal: nil, line: 1),
                        initializer: Literal(value: .number(23))
                    )
                ]
            )]
        )
        XCTAssertFalse(Lox.hadError)
    }
}

extension ParserTests {

    func testParse_if_returnsIf() {
        
        // given
        let sut = Parser(
            [Token(type: .if, lexeme: "if", literal: nil, line: 1),
             Token(type: .leftParen, lexeme: "(", literal: nil, line: 1),
             Token(type: .`true`, lexeme: "true", literal: .boolean(true), line: 1),
             Token(type: .rightParen, lexeme: ")", literal: nil, line: 1),
             Token(type: .number, lexeme: "23", literal: .number(23), line: 1),
             Token(type: .semicolon, lexeme: ";", literal: nil, line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(
            result,
            [If(
                condition: Literal(value: .boolean(true)),
                thenBranch: Expression(expression: Literal(value: .number(23))),
                elseBranch: nil
            )]
        )
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_ifWithNoLeftParen_reportsError() {
        
        // given
        let sut = Parser(
            [Token(type: .if, lexeme: "if", literal: nil, line: 1),
             Token(type: .`true`, lexeme: "true", literal: .boolean(true), line: 1),
             Token(type: .rightParen, lexeme: ")", literal: nil, line: 1),
             Token(type: .number, lexeme: "23", literal: .number(23), line: 1),
             Token(type: .semicolon, lexeme: ";", literal: nil, line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        _ = sut.parse()
        
        // then
        XCTAssertTrue(Lox.hadError)
    }
    
    func testParse_ifWithNoRightParen_reportsError() {
        
        // given
        let sut = Parser(
            [Token(type: .if, lexeme: "if", literal: nil, line: 1),
             Token(type: .leftParen, lexeme: "(", literal: nil, line: 1),
             Token(type: .`true`, lexeme: "true", literal: .boolean(true), line: 1),
             Token(type: .number, lexeme: "23", literal: .number(23), line: 1),
             Token(type: .semicolon, lexeme: ";", literal: nil, line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        _ = sut.parse()
        
        // then
        XCTAssertTrue(Lox.hadError)
    }
    
    func testParse_ifWithElse_returnsIf() {
        
        // given
        let sut = Parser(
            [Token(type: .if, lexeme: "if", literal: nil, line: 1),
             Token(type: .leftParen, lexeme: "(", literal: nil, line: 1),
             Token(type: .`true`, lexeme: "true", literal: .boolean(true), line: 1),
             Token(type: .rightParen, lexeme: ")", literal: nil, line: 1),
             Token(type: .number, lexeme: "23", literal: .number(23), line: 1),
             Token(type: .semicolon, lexeme: ";", literal: nil, line: 1),
             Token(type: .else, lexeme: "else", literal: nil, line: 1),
             Token(type: .number, lexeme: "11", literal: .number(11), line: 1),
             Token(type: .semicolon, lexeme: ";", literal: nil, line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(
            result,
            [If(
                condition: Literal(value: .boolean(true)),
                thenBranch: Expression(expression: Literal(value: .number(23))),
                elseBranch: Expression(expression: Literal(value: .number(11)))
            )]
        )
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_while_returnsWhile() {
        
        // given
        let sut = Parser(
            [Token(type: .while, lexeme: "while", literal: nil, line: 1),
             Token(type: .leftParen, lexeme: "(", literal: nil, line: 1),
             Token(type: .`true`, lexeme: "true", literal: .boolean(true), line: 1),
             Token(type: .rightParen, lexeme: ")", literal: nil, line: 1),
             Token(type: .number, lexeme: "23", literal: .number(23), line: 1),
             Token(type: .semicolon, lexeme: ";", literal: nil, line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(
            result,
            [While(
                condition: Literal(value: .boolean(true)),
                body: Expression(expression: Literal(value: .number(23)))
            )]
        )
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_whileWithNoRightParen_reportsError() {
        
        // given
        let sut = Parser(
            [Token(type: .while, lexeme: "while", literal: nil, line: 1),
             Token(type: .leftParen, lexeme: "(", literal: nil, line: 1),
             Token(type: .`true`, lexeme: "true", literal: .boolean(true), line: 1),
             Token(type: .number, lexeme: "23", literal: .number(23), line: 1),
             Token(type: .semicolon, lexeme: ";", literal: nil, line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        _ = sut.parse()
        
        // then
        XCTAssertTrue(Lox.hadError)
    }
    
    func testParse_whileWithNoLeftParen_reportsError() {
        
        // given
        let sut = Parser(
            [Token(type: .while, lexeme: "while", literal: nil, line: 1),
             Token(type: .`true`, lexeme: "true", literal: .boolean(true), line: 1),
             Token(type: .rightParen, lexeme: ")", literal: nil, line: 1),
             Token(type: .number, lexeme: "23", literal: .number(23), line: 1),
             Token(type: .semicolon, lexeme: ";", literal: nil, line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        _ = sut.parse()
        
        // then
        XCTAssertTrue(Lox.hadError)
    }
    
    func testParse_for_returnsWhile() {
        
        // given
        let sut = Parser(
            [Token(type: .for, lexeme: "for", literal: nil, line: 1),
             Token(type: .leftParen, lexeme: "(", literal: nil, line: 1),
             Token(type: .semicolon, lexeme: ";", literal: nil, line: 1),
             Token(type: .semicolon, lexeme: ";", literal: nil, line: 1),
             Token(type: .rightParen, lexeme: ")", literal: nil, line: 1),
             Token(type: .number, lexeme: "23", literal: .number(23), line: 1),
             Token(type: .semicolon, lexeme: ";", literal: nil, line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(
            result,
            [While(
                condition: Literal(value: .boolean(true)),
                body: Expression(expression: Literal(value: .number(23)))
            )]
        )
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_forWithInitializerAsVarDeclaration_returnsBlockWithVarAndWhile() {
        
        // given
        let sut = Parser(
            [Token(type: .for, lexeme: "for", literal: nil, line: 1),
             Token(type: .leftParen, lexeme: "(", literal: nil, line: 1),
             Token(type: .var, lexeme: "var", literal: nil, line: 1),
             Token(type: .identifier, lexeme: "age", literal: nil, line: 1),
             Token(type: .semicolon, lexeme: ";", literal: nil, line: 1),
             Token(type: .semicolon, lexeme: ";", literal: nil, line: 1),
             Token(type: .rightParen, lexeme: ")", literal: nil, line: 1),
             Token(type: .number, lexeme: "23", literal: .number(23), line: 1),
             Token(type: .semicolon, lexeme: ";", literal: nil, line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(
            result,
            [Block(
                statements: [
                    Var(name: Token(type: .identifier, lexeme: "age", literal: nil, line: 1),
                        initializer: nil),
                    While(
                        condition: Literal(value: .boolean(true)),
                        body: Expression(expression: Literal(value: .number(23)))
                    )
                ]
            )]
        )
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_forWithInitializerAsExpression_returnsBlockWithExpressionAndWhile() {
        
        // given
        let sut = Parser(
            [Token(type: .for, lexeme: "for", literal: nil, line: 1),
             Token(type: .leftParen, lexeme: "(", literal: nil, line: 1),
             Token(type: .number, lexeme: "11", literal: .number(11), line: 1),
             Token(type: .semicolon, lexeme: ";", literal: nil, line: 1),
             Token(type: .semicolon, lexeme: ";", literal: nil, line: 1),
             Token(type: .rightParen, lexeme: ")", literal: nil, line: 1),
             Token(type: .number, lexeme: "23", literal: .number(23), line: 1),
             Token(type: .semicolon, lexeme: ";", literal: nil, line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(
            result,
            [Block(
                statements: [
                    Expression(expression: Literal(value: .number(11))),
                    While(
                        condition: Literal(value: .boolean(true)),
                        body: Expression(expression: Literal(value: .number(23)))
                    )
                ]
            )]
        )
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_forWithCondition_returnsWhile() {
        
        // given
        let sut = Parser(
            [Token(type: .for, lexeme: "for", literal: nil, line: 1),
             Token(type: .leftParen, lexeme: "(", literal: nil, line: 1),
             Token(type: .semicolon, lexeme: ";", literal: nil, line: 1),
             Token(type: .number, lexeme: "11", literal: .number(11), line: 1),
             Token(type: .semicolon, lexeme: ";", literal: nil, line: 1),
             Token(type: .rightParen, lexeme: ")", literal: nil, line: 1),
             Token(type: .number, lexeme: "23", literal: .number(23), line: 1),
             Token(type: .semicolon, lexeme: ";", literal: nil, line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(
            result,
            [While(
                condition: Literal(value: .number(11)),
                body: Expression(expression: Literal(value: .number(23)))
            )]
        )
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_forWithIncrement_returnsWhileWithBlock() {
        
        // given
        let sut = Parser(
            [Token(type: .for, lexeme: "for", literal: nil, line: 1),
             Token(type: .leftParen, lexeme: "(", literal: nil, line: 1),
             Token(type: .semicolon, lexeme: ";", literal: nil, line: 1),
             Token(type: .semicolon, lexeme: ";", literal: nil, line: 1),
             Token(type: .number, lexeme: "11", literal: .number(11), line: 1),
             Token(type: .rightParen, lexeme: ")", literal: nil, line: 1),
             Token(type: .number, lexeme: "23", literal: .number(23), line: 1),
             Token(type: .semicolon, lexeme: ";", literal: nil, line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        let result = sut.parse()
        
        // then
        XCTAssertEqual(
            result,
            [While(
                condition: Literal(value: .boolean(true)),
                body: Block(statements: [
                    Expression(expression: Literal(value: .number(23))),
                    Expression(expression: Literal(value: .number(11)))
                ])
                    
            )]
        )
        XCTAssertFalse(Lox.hadError)
    }
    
    func testParse_forWithNoLeftParen_reportsError() {
        
        // given
        let sut = Parser(
            [Token(type: .for, lexeme: "for", literal: nil, line: 1),
             Token(type: .semicolon, lexeme: ";", literal: nil, line: 1),
             Token(type: .semicolon, lexeme: ";", literal: nil, line: 1),
             Token(type: .rightParen, lexeme: ")", literal: nil, line: 1),
             Token(type: .number, lexeme: "23", literal: .number(23), line: 1),
             Token(type: .semicolon, lexeme: ";", literal: nil, line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        _ = sut.parse()
        
        // then
        XCTAssertTrue(Lox.hadError)
    }
    
    func testParse_forWithNoRightParen_reportsError() {
        
        // given
        let sut = Parser(
            [Token(type: .for, lexeme: "for", literal: nil, line: 1),
             Token(type: .leftParen, lexeme: "(", literal: nil, line: 1),
             Token(type: .semicolon, lexeme: ";", literal: nil, line: 1),
             Token(type: .semicolon, lexeme: ";", literal: nil, line: 1),
             Token(type: .number, lexeme: "23", literal: .number(23), line: 1),
             Token(type: .semicolon, lexeme: ";", literal: nil, line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        _ = sut.parse()
        
        // then
        XCTAssertTrue(Lox.hadError)
    }
    
    func testParse_forWithSingleSemicolons_reportsError() {
        
        // given
        let sut = Parser(
            [Token(type: .for, lexeme: "for", literal: nil, line: 1),
             Token(type: .leftParen, lexeme: "(", literal: nil, line: 1),
             Token(type: .semicolon, lexeme: ";", literal: nil, line: 1),
             Token(type: .rightParen, lexeme: ")", literal: nil, line: 1),
             Token(type: .number, lexeme: "23", literal: .number(23), line: 1),
             Token(type: .semicolon, lexeme: ";", literal: nil, line: 1),
             Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        
        // when
        _ = sut.parse()
        
        // then
        XCTAssertTrue(Lox.hadError)
    }
}
