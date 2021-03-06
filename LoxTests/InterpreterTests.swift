//
//  InterpreterTests.swift
//  LoxTests
//
//  Created by Алексей Якименко on 30.05.2021.
//

import XCTest

final class InterpreterTests: XCTestCase {
    
    private var errorReporter: ErrorReporterMock!
    private var printer: PrinterMock!
    private var sut: Interpreter!
    private var environment: EnvironmentMock!
    
    override func setUp() {
        super.setUp()
        
        environment = EnvironmentMock()
        printer = PrinterMock()
        sut = Interpreter(printer, environment)
        errorReporter = ErrorReporterMock()
        Lox.hadRuntimeError = false
        Lox.errorReporter = errorReporter
    }
    
    override func tearDown() {
        errorReporter = nil
        sut = nil
        environment = nil
        
        super.tearDown()
    }
    
    func testInterpret_nil_printsOutNil() {
        
        // given
        let expr = [Expression(expression: Literal(value: nil))]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message.first, "nil")
        XCTAssertFalse(Lox.hadRuntimeError)
    }
    
    func testInterpret_string_printsOutString() {
        
        // given
        let expr = [Expression(expression:Literal(value: .string("Moscow city")))]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message.first, "Moscow city")
        XCTAssertFalse(Lox.hadRuntimeError)
    }
    
    func testInterpret_true_printsOutTrue() {
        
        // given
        let expr = [Expression(expression:Literal(value: .boolean(true)))]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message.first, "true")
        XCTAssertFalse(Lox.hadRuntimeError)
    }
    
    func testInterpret_false_printsOutFalse() {
        
        // given
        let expr = [Expression(expression:Literal(value: .boolean(false)))]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message.first, "false")
        XCTAssertFalse(Lox.hadRuntimeError)
    }
    
    func testInterpret_int_printsOutNumberWithoutFractionDigits() {
        
        // given
        let expr = [Expression(expression:Literal(value: .number(33)))]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message.first, "33")
        XCTAssertFalse(Lox.hadRuntimeError)
    }
    
    func testInterpret_double_printsOutNumberWithFractionDigits() {
        
        // given
        let expr = [Expression(expression:Literal(value: .number(33.44)))]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message.first, "33,44")
        XCTAssertFalse(Lox.hadRuntimeError)
    }
    
    func testInterpret_numberWithMinus_printsOutNegativeNumber() {
        
        // given
        let expr = [Expression(
            expression: Unary(
                operator: Token(type: .minus, lexeme: "-", literal: nil, line: 1),
                right: Literal(value: .number(33.44))
            )
        )]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message.first, "-33,44")
        XCTAssertFalse(Lox.hadRuntimeError)
    }
    
    func testInterpret_nilWithExclamationMark_printsOutTrue() {
        
        // given
        let expr = [Expression(
            expression: Unary(
                operator: Token(type: .bang, lexeme: "!", literal: nil, line: 1),
                right: Literal(value: nil)
            )
        )]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message.first, "true")
        XCTAssertFalse(Lox.hadRuntimeError)
    }
    
    func testInterpret_trueWithExclamationMark_printsOutFalse() {
        
        // given
        let expr = [Expression(
            expression:Unary(
                operator: Token(type: .bang, lexeme: "!", literal: nil, line: 1),
                right: Literal(value: .boolean(true))
            )
        )]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message.first, "false")
        XCTAssertFalse(Lox.hadRuntimeError)
    }
    
    func testInterpret_falseWithExclamationMark_printsOutTrue() {
        
        // given
        let expr = [Expression(
            expression:Unary(
                operator: Token(type: .bang, lexeme: "!", literal: nil, line: 1),
                right: Literal(value: .boolean(false))
            )
        )]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message.first, "true")
        XCTAssertFalse(Lox.hadRuntimeError)
    }
    
    func testInterpret_stringWithExclamationMark_printsOutFalse() {
        
        // given
        let expr = [Expression(
            expression: Unary(
                operator: Token(type: .bang, lexeme: "!", literal: nil, line: 1),
                right: Literal(value: .string("Moscow city"))
            )
        )]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message.first, "false")
        XCTAssertFalse(Lox.hadRuntimeError)
    }
    
    func testInterpret_trueWithPlus_printsOutNil() {
        
        // given
        let expr = [Expression(
            expression: Unary(
                operator: Token(type: .plus, lexeme: "+", literal: nil, line: 1),
                right: Literal(value: .boolean(true))
            )
        )]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message.first, "nil")
        XCTAssertFalse(Lox.hadRuntimeError)
    }
    
    func testInterpret_trueWithMinus_reportsRuntimeError() {
        
        // given
        let expr = [Expression(
            expression: Unary(
                operator: Token(type: .minus, lexeme: "-", literal: nil, line: 1),
                right: Literal(value: .boolean(true))
            )
        )]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message, [])
        XCTAssertTrue(Lox.hadRuntimeError)
    }
    
    func testInterpret_twoNumbersAddition_printsOutResult() {
        
        // given
        let expr = [Expression(
            expression:Binary(
                left: Literal(value: .number(4)),
                operator: Token(type: .plus, lexeme: "+", literal: nil, line: 1),
                right: Literal(value: .number(5))
            )
        )]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message.first, "9")
        XCTAssertFalse(Lox.hadRuntimeError)
    }
    
    func testInterpret_twoStringsConcatenation_printsOutCombinedString() {
        
        // given
        let expr = [Expression(
            expression: Binary(
                left: Literal(value: .string("Moscow")),
                operator: Token(type: .plus, lexeme: "+", literal: nil, line: 1),
                right: Literal(value: .string(" city"))
            )
        )]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message.first, "Moscow city")
        XCTAssertFalse(Lox.hadRuntimeError)
    }
    
    func testInterpret_twoBooleansAddition_reportsRuntimeError() {
        
        // given
        let expr = [Expression(
            expression:Binary(
                left: Literal(value: .boolean(false)),
                operator: Token(type: .plus, lexeme: "+", literal: nil, line: 1),
                right: Literal(value: .boolean(true))
            )
        )]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message, [])
        XCTAssertTrue(Lox.hadRuntimeError)
    }
    
    func testInterpret_twoNumbersSubtraction_printsOutResult() {
        
        // given
        let expr = [Expression(
            expression:Binary(
                left: Literal(value: .number(4)),
                operator: Token(type: .minus, lexeme: "-", literal: nil, line: 1),
                right: Literal(value: .number(5))
            )
        )]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message.first, "-1")
        XCTAssertFalse(Lox.hadRuntimeError)
    }
    
    func testInterpret_twoBooleansSubtraction_reportsRuntimeError() {
        
        // given
        let expr = [Expression(
            expression:Binary(
                left: Literal(value: .boolean(false)),
                operator: Token(type: .minus, lexeme: "-", literal: nil, line: 1),
                right: Literal(value: .boolean(true))
            )
        )]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message, [])
        XCTAssertTrue(Lox.hadRuntimeError)
    }
    
    func testInterpret_twoNumbersMultiplication_printsOutResult() {
        
        // given
        let expr = [Expression(
            expression:Binary(
                left: Literal(value: .number(4)),
                operator: Token(type: .star, lexeme: "*", literal: nil, line: 1),
                right: Literal(value: .number(5))
            )
        )]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message.first, "20")
        XCTAssertFalse(Lox.hadRuntimeError)
    }
    
    func testInterpret_twoBooleansMultiplication_reportsRuntimeError() {
        
        // given
        let expr = [Expression(
            expression:Binary(
                left: Literal(value: .boolean(false)),
                operator: Token(type: .star, lexeme: "*", literal: nil, line: 1),
                right: Literal(value: .boolean(true))
            )
        )]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message, [])
        XCTAssertTrue(Lox.hadRuntimeError)
    }
    
    func testInterpret_twoNumbersDivision_printsOutResult() {
        
        // given
        let expr = [Expression(
            expression:Binary(
                left: Literal(value: .number(20)),
                operator: Token(type: .slash, lexeme: "/", literal: nil, line: 1),
                right: Literal(value: .number(5))
            )
        )]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message.first, "4")
        XCTAssertFalse(Lox.hadRuntimeError)
    }
    
    func testInterpret_twoBooleansDivision_reportsRuntimeError() {
        
        // given
        let expr = [Expression(
            expression:Binary(
                left: Literal(value: .boolean(false)),
                operator: Token(type: .slash, lexeme: "/", literal: nil, line: 1),
                right: Literal(value: .boolean(true))
            )
        )]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message, [])
        XCTAssertTrue(Lox.hadRuntimeError)
    }
    
    func testInterpret_oneNumberLessThanAnother_printsOutResult() {
        
        // given
        let expr = [Expression(
            expression:Binary(
                left: Literal(value: .number(20)),
                operator: Token(type: .less, lexeme: "<", literal: nil, line: 1),
                right: Literal(value: .number(5))
            )
        )]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message.first, "false")
        XCTAssertFalse(Lox.hadRuntimeError)
    }
    
    func testInterpret_oneBooleanLessThanAnother_reportsRuntimeError() {
        
        // given
        let expr = [Expression(
            expression:Binary(
                left: Literal(value: .boolean(false)),
                operator: Token(type: .less, lexeme: "<", literal: nil, line: 1),
                right: Literal(value: .boolean(true))
            )
        )]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message, [])
        XCTAssertTrue(Lox.hadRuntimeError)
    }
    
    func testInterpret_oneNumberLessOrEqualThanAnother_printsOutResult() {
        
        // given
        let expr = [Expression(
            expression:Binary(
                left: Literal(value: .number(20)),
                operator: Token(type: .lessEqual, lexeme: "<=", literal: nil, line: 1),
                right: Literal(value: .number(5))
            )
        )]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message.first, "false")
        XCTAssertFalse(Lox.hadRuntimeError)
    }
    
    func testInterpret_oneBooleanLessOrEqualThanAnother_reportsRuntimeError() {
        
        // given
        let expr = [Expression(
            expression:Binary(
                left: Literal(value: .boolean(false)),
                operator: Token(type: .lessEqual, lexeme: "<=", literal: nil, line: 1),
                right: Literal(value: .boolean(true))
            )
        )]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message, [])
        XCTAssertTrue(Lox.hadRuntimeError)
    }
    
    func testInterpret_lessOrEqualTwoIdenticalNumbers_printsOutTrue() {
        
        // given
        let expr = [Expression(
            expression:Binary(
                left: Literal(value: .number(20)),
                operator: Token(type: .lessEqual, lexeme: "<=", literal: nil, line: 1),
                right: Literal(value: .number(20))
            )
        )]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message.first, "true")
        XCTAssertFalse(Lox.hadRuntimeError)
    }
    
    func testInterpret_oneNumberGreaterThanAnother_printsOutResult() {
        
        // given
        let expr = [Expression(
            expression:Binary(
                left: Literal(value: .number(20)),
                operator: Token(type: .greater, lexeme: ">", literal: nil, line: 1),
                right: Literal(value: .number(5))
            )
        )]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message.first, "true")
        XCTAssertFalse(Lox.hadRuntimeError)
    }
    
    func testInterpret_oneBooleanGreaterThanAnother_reportsRuntimeError() {
        
        // given
        let expr = [Expression(
            expression:Binary(
                left: Literal(value: .boolean(false)),
                operator: Token(type: .greater, lexeme: ">", literal: nil, line: 1),
                right: Literal(value: .boolean(true))
            )
        )]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message, [])
        XCTAssertTrue(Lox.hadRuntimeError)
    }
    
    func testInterpret_greaterOrEqualTwoIdenticalNumbers_printsOutTrue() {
        
        // given
        let expr = [Expression(
            expression:Binary(
                left: Literal(value: .number(20)),
                operator: Token(type: .greaterEqual, lexeme: ">=", literal: nil, line: 1),
                right: Literal(value: .number(20))
            )
        )]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message.first, "true")
        XCTAssertFalse(Lox.hadRuntimeError)
    }
    
    func testInterpret_oneBooleanGreaterOrEqualThanAnother_reportsRuntimeError() {
        
        // given
        let expr = [Expression(
            expression:Binary(
                left: Literal(value: .boolean(false)),
                operator: Token(type: .greaterEqual, lexeme: ">=", literal: nil, line: 1),
                right: Literal(value: .boolean(true))
            )
        )]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message, [])
        XCTAssertTrue(Lox.hadRuntimeError)
    }
    
    func testInterpret_twoNilsEquality_printsOutTrue() {
        
        // given
        let expr = [Expression(
            expression:Binary(
                left: Literal(value: nil),
                operator: Token(type: .equalEqual, lexeme: "==", literal: nil, line: 1),
                right: Literal(value: nil)
            )
        )]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message.first, "true")
        XCTAssertFalse(Lox.hadRuntimeError)
    }
    
    func testInterpret_twoNilsInequality_printsOutFalse() {
        
        // given
        let expr = [Expression(
            expression:Binary(
                left: Literal(value: nil),
                operator: Token(type: .bangEqual, lexeme: "!=", literal: nil, line: 1),
                right: Literal(value: nil)
            )
        )]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message.first, "false")
        XCTAssertFalse(Lox.hadRuntimeError)
    }
    
    func testInterpret_equalityNilAndNotNil_printsOutFalse() {
        
        // given
        let expr = [Expression(
            expression:Binary(
                left: Literal(value: nil),
                operator: Token(type: .equalEqual, lexeme: "==", literal: nil, line: 1),
                right: Literal(value: .number(23))
            )
        )]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message.first, "false")
        XCTAssertFalse(Lox.hadRuntimeError)
    }
    
    func testInterpret_inequalityNilAndNotNil_printsOutTrue() {
        
        // given
        let expr = [Expression(
            expression:Binary(
                left: Literal(value: nil),
                operator: Token(type: .bangEqual, lexeme: "!=", literal: nil, line: 1),
                right: Literal(value: .number(23))
            )
        )]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message.first, "true")
        XCTAssertFalse(Lox.hadRuntimeError)
    }
    
    func testInterpret_twoStringsEquality_printsOutResult() {
        
        // given
        let expr = [Expression(
            expression:Binary(
                left: Literal(value: .string("Moscow city")),
                operator: Token(type: .equalEqual, lexeme: "==", literal: nil, line: 1),
                right: Literal(value: .string("Moscow city"))
            )
        )]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message.first, "true")
        XCTAssertFalse(Lox.hadRuntimeError)
    }
    
    func testInterpret_twoStringsInequality_printsOutResult() {
        
        // given
        let expr = [Expression(
            expression:Binary(
                left: Literal(value: .string("Moscow city")),
                operator: Token(type: .bangEqual, lexeme: "!=", literal: nil, line: 1),
                right: Literal(value: .string("Moscow city"))
            )
        )]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message.first, "false")
        XCTAssertFalse(Lox.hadRuntimeError)
    }
    
    func testInterpret_twoBooleansEquality_printsOutResult() {
        
        // given
        let expr = [Expression(
            expression:Binary(
                left: Literal(value: .boolean(true)),
                operator: Token(type: .equalEqual, lexeme: "==", literal: nil, line: 1),
                right: Literal(value: .boolean(true))
            )
        )]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message.first, "true")
        XCTAssertFalse(Lox.hadRuntimeError)
    }
    
    func testInterpret_twoBooleansInequality_printsOutResult() {
        
        // given
        let expr = [Expression(
            expression:Binary(
                left: Literal(value: .boolean(true)),
                operator: Token(type: .bangEqual, lexeme: "!=", literal: nil, line: 1),
                right: Literal(value: .boolean(true))
            )
        )]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message.first, "false")
        XCTAssertFalse(Lox.hadRuntimeError)
    }
    
    func testInterpret_twoNumbersEquality_printsOutResult() {
        
        // given
        let expr = [Expression(
            expression:Binary(
                left: Literal(value: .number(23)),
                operator: Token(type: .equalEqual, lexeme: "==", literal: nil, line: 1),
                right: Literal(value: .number(23))
            )
        )]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message.first, "true")
        XCTAssertFalse(Lox.hadRuntimeError)
    }
    
    func testInterpret_twoNumbersInequality_printsOutResult() {
        
        // given
        let expr = [Expression(
            expression:Binary(
                left: Literal(value: .number(23)),
                operator: Token(type: .bangEqual, lexeme: "!=", literal: nil, line: 1),
                right: Literal(value: .number(23))
            )
        )]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message.first, "false")
        XCTAssertFalse(Lox.hadRuntimeError)
    }
    
    func testInterpret_stringAndNumberEquality_printsOutFalse() {
        
        // given
        let expr = [Expression(
            expression:Binary(
                left: Literal(value: .number(23)),
                operator: Token(type: .equalEqual, lexeme: "==", literal: nil, line: 1),
                right: Literal(value: .string("Moscow city"))
            )
        )]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message.first, "false")
        XCTAssertFalse(Lox.hadRuntimeError)
    }
    
    func testInterpret_stringAndNumberInequality_printsOutTrue() {
        
        // given
        let expr = [Expression(
            expression:Binary(
                left: Literal(value: .number(23)),
                operator: Token(type: .bangEqual, lexeme: "!=", literal: nil, line: 1),
                right: Literal(value: .string("Moscow city"))
            )
        )]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message.first, "true")
        XCTAssertFalse(Lox.hadRuntimeError)
    }
    
    func testInterpret_expressions_printsOutResultOfLastExpression() {
        
        // given
        let expr = [Expression(
            expression:Grouping(
                expressions: [
                    Binary(
                        left: Literal(value: .number(2)),
                        operator: Token(type: .plus, lexeme: "+", literal: nil, line: 1),
                        right: Literal(value: .number(3))
                    ),
                    Binary(
                        left: Literal(value: .number(4)),
                        operator: Token(type: .plus, lexeme: "+", literal: nil, line: 1),
                        right: Literal(value: .number(5))
                    )
                ]
            )
        )]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message.first, "9")
        XCTAssertFalse(Lox.hadRuntimeError)
    }
    
    func testInterpret_oneStringLessThanAnother_printsOutResult() {
        
        // given
        let expr = [Expression(
            expression:Binary(
                left: Literal(value: .string("a")),
                operator: Token(type: .less, lexeme: "<", literal: nil, line: 1),
                right: Literal(value: .string("b"))
            )
        )]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message.first, "true")
        XCTAssertFalse(Lox.hadRuntimeError)
    }
    
    func testInterpret_oneStringLessEqualThanAnother_printsOutResult() {
        
        // given
        let expr = [Expression(
            expression:Binary(
                left: Literal(value: .string("a")),
                operator: Token(type: .lessEqual, lexeme: "<=", literal: nil, line: 1),
                right: Literal(value: .string("b"))
            )
        )]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message.first, "true")
        XCTAssertFalse(Lox.hadRuntimeError)
    }
    
    func testInterpret_oneStringGreateThanAnother_printsOutResult() {
        
        // given
        let expr = [Expression(
            expression:Binary(
                left: Literal(value: .string("a")),
                operator: Token(type: .greater, lexeme: ">", literal: nil, line: 1),
                right: Literal(value: .string("b"))
            )
        )]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message.first, "false")
        XCTAssertFalse(Lox.hadRuntimeError)
    }
    
    func testInterpret_oneStringGreaterOrEqualThanAnother_printsOutResult() {
        
        // given
        let expr = [Expression(
            expression:Binary(
                left: Literal(value: .string("a")),
                operator: Token(type: .greaterEqual, lexeme: ">=", literal: nil, line: 1),
                right: Literal(value: .string("b"))
            )
        )]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message.first, "false")
        XCTAssertFalse(Lox.hadRuntimeError)
    }
    
    func testInterpret_greaterOrEqualTwoIdenticalStrings_printsOutTrue() {
        
        // given
        let expr = [Expression(
            expression:Binary(
                left: Literal(value: .string("a")),
                operator: Token(type: .greaterEqual, lexeme: ">=", literal: nil, line: 1),
                right: Literal(value: .string("a"))
            )
        )]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message.first, "true")
        XCTAssertFalse(Lox.hadRuntimeError)
    }
    
    func testInterpret_lessOrEqualTwoIdenticalStrings_printsOutTrue() {
        
        // given
        let expr = [Expression(
            expression:Binary(
                left: Literal(value: .string("a")),
                operator: Token(type: .lessEqual, lexeme: "<=", literal: nil, line: 1),
                right: Literal(value: .string("a"))
            )
        )]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message.first, "true")
        XCTAssertFalse(Lox.hadRuntimeError)
    }
    
    func testInterpret_concatenateStringAndNumber_printsOutCombinedString() {
        
        // given
        let expr = [Expression(
            expression:Binary(
                left: Literal(value: .string("Moscow")),
                operator: Token(type: .plus, lexeme: "+", literal: nil, line: 1),
                right: Literal(value: .number(4.33))
            )
        )]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message.first, "Moscow4.33")
        XCTAssertFalse(Lox.hadRuntimeError)
    }
    
    func testInterpret_divisionByZero_reportsRuntimeError() {
        
        // given
        let expr = [Expression(
            expression:Binary(
                left: Literal(value: .number(20)),
                operator: Token(type: .slash, lexeme: "/", literal: nil, line: 1),
                right: Literal(value: .number(0))
            )
        )]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message, [])
        XCTAssertTrue(Lox.hadRuntimeError)
    }
}

extension InterpreterTests {
    
    func testInterpret_printNumber_printsOutNumber() {
        
        // given
        let expr = [Print(expression: Literal(value: .number(23)))]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message.first, "23")
        XCTAssertFalse(Lox.hadRuntimeError)
    }
    
    func testInterpret_variableExpression_getsValueFromEnvironment() {
        
        // given
        let expr = [Expression(
            expression: Variable(
                name: Token(type: .identifier, lexeme: "age", literal: nil, line: 1)
            )
        )]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(
            environment.getArg, Token(type: .identifier, lexeme: "age", literal: nil, line: 1)
        )
        XCTAssertFalse(Lox.hadRuntimeError)
    }
    
    func testInterpret_assignExpression_callsEnvironmentAssign() {
        
        // given
        let expr = [Expression(
            expression: Assign(
                name: Token(type: .identifier, lexeme: "age", literal: nil, line: 1),
                value: Literal(value: .number(23))
            )
        )]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(
            environment.assignArgs?.0,
            Token(type: .identifier, lexeme: "age", literal: nil, line: 1)
        )
        XCTAssertEqual(
            environment.assignArgs?.1 as? Double, 23
        )
        XCTAssertFalse(Lox.hadRuntimeError)
    }
    
    func testInterpret_varStatement_callsEnvironmentDefine() {
        
        // given
        let expr = [Var(
            name: Token(type: .identifier, lexeme: "age", literal: nil, line: 1),
            initializer: Literal(value: .number(13))
        )]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(
            environment.defineArgs?.0, "age"
        )
        XCTAssertEqual(
            environment.defineArgs?.1 as? Double, 13
        )
        XCTAssertFalse(Lox.hadRuntimeError)
    }
}

extension InterpreterTests {
    
    func testInterpret_ifWithConiditionIsTrue_executeThenBranch() {
        
        // given
        let expr = [If(
            condition: Literal(value: .boolean(true)),
            thenBranch: Print(expression: Literal(value: .string("then"))),
            elseBranch: Print(expression: Literal(value: .string("else")))
        )]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message.first, "then")
        XCTAssertFalse(Lox.hadRuntimeError)
    }
    
    func testInterpret_ifWithConiditionIsFalse_executeThenBranch() {
        
        // given
        let expr = [If(
            condition: Literal(value: .boolean(false)),
            thenBranch: Print(expression: Literal(value: .string("then"))),
            elseBranch: Print(expression: Literal(value: .string("else")))
        )]
        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message.first, "else")
        XCTAssertFalse(Lox.hadRuntimeError)
    }
    
    func testInterpret_whileWithConditionIsFalse_doesNotExecuteBody() {
        
        // given
        let expr = [While(
            condition: Literal(value: .boolean(false)),
            body: Print(expression: Literal(value: .string("while")))
        )]
                        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message, [])
        XCTAssertFalse(Lox.hadRuntimeError)
    }
    
    func testInterpret_whileWithConditionIsTrue_executeBodyFewTimes() {
        
        // given
        environment.getReturns = [true, true]
        let expr = [
            While(
                condition: Variable(name: Token(type: .identifier, lexeme: "counter", literal: nil, line: 1)),
                body: Print(expression: Literal(value: .string("while")))
        )]
                        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(printer.message, ["while", "while"])
        XCTAssertFalse(Lox.hadRuntimeError)
    }
    
    func testInterpret_function_updatesEnvironment() {
        
        // given
        let expr = [Function(
            name: Token(type: .identifier, lexeme: "get", literal: nil, line: 1),
            params: [],
            body: []
        )]
                        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertEqual(environment.defineArgs?.0, "get")
        XCTAssertTrue(environment.defineArgs?.1 is LoxFunction)
        XCTAssertFalse(Lox.hadRuntimeError)
    }
    
    func testInterpret_call_printsOutResult() {
        
        // given
        environment.getReturns = [
            LoxFunction(
                declaration:
                    Function(
                        name: Token(type: .identifier, lexeme: "get", literal: nil, line: 1),
                        params: [],
                        body: [Expression(expression: Literal(value: .boolean(true)))]
                    ),
                closure: environment)
        ]
        let expr = [Expression(
            expression: Call(
                callee: Variable(
                    name: Token(type: .identifier, lexeme: "get", literal: nil, line: 1)
                ),
                paren: Token(type: .rightParen, lexeme: ")", literal: nil, line: 1),
                arguments: []
            )
        )]
                        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertTrue(printer.message.contains("true"))
        XCTAssertFalse(Lox.hadRuntimeError)
    }
    
    func testInterpret_callWithDifferentNumberOfParametersAndArguments_reportsError() {
        
        // given
        environment.getReturns = [
            LoxFunction(
                declaration:
                    Function(
                        name: Token(type: .identifier, lexeme: "get", literal: nil, line: 1),
                        params: [],
                        body: [Expression(expression: Literal(value: .boolean(true)))]
                    ),
                closure: environment)
        ]
        let expr = [Expression(
            expression: Call(
                callee: Variable(
                    name: Token(type: .identifier, lexeme: "get", literal: nil, line: 1)
                ),
                paren: Token(type: .rightParen, lexeme: ")", literal: nil, line: 1),
                arguments: [Literal(value: .boolean(true))]
            )
        )]
                        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertTrue(Lox.hadRuntimeError)
    }
    
    func testInterpret_callWithNoDeclaration_reportsError() {
        
        // given
        environment.getReturns = []
        let expr = [Expression(
            expression: Call(
                callee: Variable(
                    name: Token(type: .identifier, lexeme: "get", literal: nil, line: 1)
                ),
                paren: Token(type: .rightParen, lexeme: ")", literal: nil, line: 1),
                arguments: []
            )
        )]
                        
        // when
        sut.interpret(expr)
        
        // then
        XCTAssertTrue(Lox.hadRuntimeError)
    }
}
