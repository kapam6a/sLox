//
//  LoxTests.swift
//  LoxTests
//
//  Created by Алексей Якименко on 25.05.2021.
//

import XCTest

class ScannerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        Lox.hadError = false
    }
    
    func testScanTokens_withNoString_returnsEofToken() throws {
        
        // given
        let sut = Scanner("")
        
        // when
        let result = sut.scanTokens()
        
        // then
        XCTAssertEqual(result, [Token(type: .eof, lexeme: "", literal: nil, line: 1)])
        XCTAssertFalse(Lox.hadError)
    }

    func testScanTokens_withEmptyString_returnsEofToken() throws {
        
        // given
        let sut = Scanner(" ")
        
        // when
        let result = sut.scanTokens()
        
        // then
        XCTAssertEqual(result, [Token(type: .eof, lexeme: "", literal: nil, line: 1)])
        XCTAssertFalse(Lox.hadError)
    }
    
    func testScanTokens_withTab_returnsEofToken() throws {
        
        // given
        let sut = Scanner("\t")
        
        // when
        let result = sut.scanTokens()
        
        // then
        XCTAssertEqual(result, [Token(type: .eof, lexeme: "", literal: nil, line: 1)])
        XCTAssertFalse(Lox.hadError)
    }
    
    func testScanTokens_withCarriageReturn_returnsEofToken() throws {
        
        // given
        let sut = Scanner("\r")
        
        // when
        let result = sut.scanTokens()
        
        // then
        XCTAssertEqual(result, [Token(type: .eof, lexeme: "", literal: nil, line: 1)])
        XCTAssertFalse(Lox.hadError)
    }
    
    func testScanTokens_withLineFeed_returnsEofTokenWithTwoLines() throws {
        
        // given
        let sut = Scanner("\n")
        
        // when
        let result = sut.scanTokens()
        
        // then
        XCTAssertEqual(result, [Token(type: .eof, lexeme: "", literal: nil, line: 2)])
        XCTAssertFalse(Lox.hadError)
    }
    
    func testScanTokens_withLeftParenthesis_returnsLeftParenToken() throws {
        
        // given
        let sut = Scanner("(")
        
        // when
        let result = sut.scanTokens()
        
        // then
        XCTAssertEqual(result, [Token(type: .leftParen, lexeme: "(", literal: nil, line: 1),
                                Token(type: .eof, lexeme: "", literal: nil, line: 1)])
        XCTAssertFalse(Lox.hadError)
    }
    
    func testScanTokens_withRightParenthesis_returnsRightParenToken() throws {
        
        // given
        let sut = Scanner(")")
        
        // when
        let result = sut.scanTokens()
        
        // then
        XCTAssertEqual(result, [Token(type: .rightParen, lexeme: ")", literal: nil, line: 1),
                                Token(type: .eof, lexeme: "", literal: nil, line: 1)])
        XCTAssertFalse(Lox.hadError)
    }
    
    func testScanTokens_withLeftBrace_returnsLeftBraceToken() throws {
        
        // given
        let sut = Scanner("{")
        
        // when
        let result = sut.scanTokens()
        
        // then
        XCTAssertEqual(result, [Token(type: .leftBrace, lexeme: "{", literal: nil, line: 1),
                                Token(type: .eof, lexeme: "", literal: nil, line: 1)])
        XCTAssertFalse(Lox.hadError)
    }
    
    func testScanTokens_withRightBrace_returnsRightBraceToken() throws {
        
        // given
        let sut = Scanner("}")
        
        // when
        let result = sut.scanTokens()
        
        // then
        XCTAssertEqual(result, [Token(type: .rightBrace, lexeme: "}", literal: nil, line: 1),
                                Token(type: .eof, lexeme: "", literal: nil, line: 1)])
        XCTAssertFalse(Lox.hadError)
    }
    
    func testScanTokens_withComma_returnsCommaToken() throws {
        
        // given
        let sut = Scanner(",")
        
        // when
        let result = sut.scanTokens()
        
        // then
        XCTAssertEqual(result, [Token(type: .comma, lexeme: ",", literal: nil, line: 1),
                                Token(type: .eof, lexeme: "", literal: nil, line: 1)])
        XCTAssertFalse(Lox.hadError)
    }
    
    func testScanTokens_withDot_returnsDotToken() throws {
        
        // given
        let sut = Scanner(".")
        
        // when
        let result = sut.scanTokens()
        
        // then
        XCTAssertEqual(result, [Token(type: .dot, lexeme: ".", literal: nil, line: 1),
                                Token(type: .eof, lexeme: "", literal: nil, line: 1)])
        XCTAssertFalse(Lox.hadError)
    }
    
    func testScanTokens_withMinus_returnsMinusToken() throws {
        
        // given
        let sut = Scanner("-")
        
        // when
        let result = sut.scanTokens()
        
        // then
        XCTAssertEqual(result, [Token(type: .minus, lexeme: "-", literal: nil, line: 1),
                                Token(type: .eof, lexeme: "", literal: nil, line: 1)])
        XCTAssertFalse(Lox.hadError)
    }
    
    func testScanTokens_withPlus_returnsPlusToken() throws {
        
        // given
        let sut = Scanner("+")
        
        // when
        let result = sut.scanTokens()
        
        // then
        XCTAssertEqual(result, [Token(type: .plus, lexeme: "+", literal: nil, line: 1),
                                Token(type: .eof, lexeme: "", literal: nil, line: 1)])
        XCTAssertFalse(Lox.hadError)
    }
    
    func testScanTokens_withSemicolon_returnsSemicolonToken() throws {
        
        // given
        let sut = Scanner(";")
        
        // when
        let result = sut.scanTokens()
        
        // then
        XCTAssertEqual(result, [Token(type: .semicolon, lexeme: ";", literal: nil, line: 1),
                                Token(type: .eof, lexeme: "", literal: nil, line: 1)])
        XCTAssertFalse(Lox.hadError)
    }
    
    func testScanTokens_withStar_returnsStarToken() throws {
        
        // given
        let sut = Scanner("*")
        
        // when
        let result = sut.scanTokens()
        
        // then
        XCTAssertEqual(result, [Token(type: .star, lexeme: "*", literal: nil, line: 1),
                                Token(type: .eof, lexeme: "", literal: nil, line: 1)])
        XCTAssertFalse(Lox.hadError)
    }
    
    func testScanTokens_withExclamationMark_returnsBangToken() throws {
        
        // given
        let sut = Scanner("!")
        
        // when
        let result = sut.scanTokens()
        
        // then
        XCTAssertEqual(result, [Token(type: .bang, lexeme: "!", literal: nil, line: 1),
                                Token(type: .eof, lexeme: "", literal: nil, line: 1)])
        XCTAssertFalse(Lox.hadError)
    }
    
    func testScanTokens_withEqual_returnsEqualToken() throws {
        
        // given
        let sut = Scanner("=")
        
        // when
        let result = sut.scanTokens()
        
        // then
        XCTAssertEqual(result, [Token(type: .equal, lexeme: "=", literal: nil, line: 1),
                                Token(type: .eof, lexeme: "", literal: nil, line: 1)])
        XCTAssertFalse(Lox.hadError)
    }
    
    func testScanTokens_withLess_returnsLessToken() throws {
        
        // given
        let sut = Scanner("<")
        
        // when
        let result = sut.scanTokens()
        
        // then
        XCTAssertEqual(result, [Token(type: .less, lexeme: "<", literal: nil, line: 1),
                                Token(type: .eof, lexeme: "", literal: nil, line: 1)])
        XCTAssertFalse(Lox.hadError)
    }
    
    func testScanTokens_withGreater_returnsGreaterToken() throws {
        
        // given
        let sut = Scanner(">")
        
        // when
        let result = sut.scanTokens()
        
        // then
        XCTAssertEqual(result, [Token(type: .greater, lexeme: ">", literal: nil, line: 1),
                                Token(type: .eof, lexeme: "", literal: nil, line: 1)])
        XCTAssertFalse(Lox.hadError)
    }
    
    func testScanTokens_withSlash_returnsSlashToken() throws {
        
        // given
        let sut = Scanner("/")
        
        // when
        let result = sut.scanTokens()
        
        // then
        XCTAssertEqual(result, [Token(type: .slash, lexeme: "/", literal: nil, line: 1),
                                Token(type: .eof, lexeme: "", literal: nil, line: 1)])
        XCTAssertFalse(Lox.hadError)
    }
    
    func testScanTokens_withExclamationMarkAndEqual_returnsBangToken() throws {
        
        // given
        let sut = Scanner("!=")
        
        // when
        let result = sut.scanTokens()
        
        // then
        XCTAssertEqual(result, [Token(type: .bangEqual, lexeme: "!=", literal: nil, line: 1),
                                Token(type: .eof, lexeme: "", literal: nil, line: 1)])
        XCTAssertFalse(Lox.hadError)
    }
    
    func testScanTokens_withDoubleEqual_returnsEqualEqualToken() throws {
        
        // given
        let sut = Scanner("==")
        
        // when
        let result = sut.scanTokens()
        
        // then
        XCTAssertEqual(result, [Token(type: .equalEqual, lexeme: "==", literal: nil, line: 1),
                                Token(type: .eof, lexeme: "", literal: nil, line: 1)])
        XCTAssertFalse(Lox.hadError)
    }
    
    func testScanTokens_withLessAndEqual_returnsLessEqualToken() throws {
        
        // given
        let sut = Scanner("<=")
        
        // when
        let result = sut.scanTokens()
        
        // then
        XCTAssertEqual(result, [Token(type: .lessEqual, lexeme: "<=", literal: nil, line: 1),
                                Token(type: .eof, lexeme: "", literal: nil, line: 1)])
        XCTAssertFalse(Lox.hadError)
    }
    
    func testScanTokens_withGreaterAndEqual_returnsGreaterEqualToken() throws {
        
        // given
        let sut = Scanner(">=")
        
        // when
        let result = sut.scanTokens()
        
        // then
        XCTAssertEqual(result, [Token(type: .greaterEqual, lexeme: ">=", literal: nil, line: 1),
                                Token(type: .eof, lexeme: "", literal: nil, line: 1)])
        XCTAssertFalse(Lox.hadError)
    }
    
    func testScanTokens_withComment_returnsEofToken() throws {
        
        // given
        let sut = Scanner("// This is a temporary code")
        
        // when
        let result = sut.scanTokens()
        
        // then
        XCTAssertEqual(result, [Token(type: .eof, lexeme: "", literal: nil, line: 1)])
        XCTAssertFalse(Lox.hadError)
    }
    
    func testScanTokens_withStringLiteral_returnsStringToken() throws {
        
        // given
        let sut = Scanner("\"Moscow city\"")
        
        // when
        let result = sut.scanTokens()
        
        // then
        XCTAssertEqual(
            result, [Token(type: .string, lexeme: "\"Moscow city\"", literal: .string("Moscow city"), line: 1),
                     Token(type: .eof, lexeme: "", literal: nil, line: 1)]
        )
        XCTAssertFalse(Lox.hadError)
    }
    
    func testScanTokens_withUnterminatedStringLiteral_sendsErrorToLox() throws {
        
        // given
        let sut = Scanner("\"Moscow city")
        
        // when
        let result = sut.scanTokens()
        
        // then
        XCTAssertEqual(result, [Token(type: .eof, lexeme: "", literal: nil, line: 1)])
        XCTAssertTrue(Lox.hadError)
    }
    
    func testScanTokens_withIntegerLiteral_returnsNumberToken() throws {
        
        // given
        let sut = Scanner("345")
        
        // when
        let result = sut.scanTokens()
        
        // then
        XCTAssertEqual(result, [Token(type: .number, lexeme: "345", literal: .number(345), line: 1),
                                Token(type: .eof, lexeme: "", literal: nil, line: 1)])
        XCTAssertFalse(Lox.hadError)
    }
    
    func testScanTokens_withFloatLiteral_returnsNumberToken() throws {
        
        // given
        let sut = Scanner("345.456")
        
        // when
        let result = sut.scanTokens()
        
        // then
        XCTAssertEqual(result, [Token(type: .number, lexeme: "345.456", literal: .number(345.456), line: 1),
                                Token(type: .eof, lexeme: "", literal: nil, line: 1)])
        XCTAssertFalse(Lox.hadError)
    }
    
    func testScanTokens_withAnd_returnsAndToken() throws {
        
        // given
        let sut = Scanner("and")
        
        // when
        let result = sut.scanTokens()
        
        // then
        XCTAssertEqual(result, [Token(type: .and, lexeme: "and", literal: nil, line: 1),
                                Token(type: .eof, lexeme: "", literal: nil, line: 1)])
        XCTAssertFalse(Lox.hadError)
    }
    
    func testScanTokens_withClass_returnsClassToken() throws {
        
        // given
        let sut = Scanner("class")
        
        // when
        let result = sut.scanTokens()
        
        // then
        XCTAssertEqual(result, [Token(type: .class, lexeme: "class", literal: nil, line: 1),
                                Token(type: .eof, lexeme: "", literal: nil, line: 1)])
        XCTAssertFalse(Lox.hadError)
    }
    
    func testScanTokens_withElse_returnsElseToken() throws {
        
        // given
        let sut = Scanner("else")
        
        // when
        let result = sut.scanTokens()
        
        // then
        XCTAssertEqual(result, [Token(type: .else, lexeme: "else", literal: nil, line: 1),
                                Token(type: .eof, lexeme: "", literal: nil, line: 1)])
        XCTAssertFalse(Lox.hadError)
    }
    
    func testScanTokens_withFalse_returnsFalseToken() throws {
        
        // given
        let sut = Scanner("false")
        
        // when
        let result = sut.scanTokens()
        
        // then
        XCTAssertEqual(result, [Token(type: .false, lexeme: "false", literal: nil, line: 1),
                                Token(type: .eof, lexeme: "", literal: nil, line: 1)])
        XCTAssertFalse(Lox.hadError)
    }
    
    func testScanTokens_withFor_returnsForToken() throws {
        
        // given
        let sut = Scanner("for")
        
        // when
        let result = sut.scanTokens()
        
        // then
        XCTAssertEqual(result, [Token(type: .for, lexeme: "for", literal: nil, line: 1),
                                Token(type: .eof, lexeme: "", literal: nil, line: 1)])
        XCTAssertFalse(Lox.hadError)
    }
    
    func testScanTokens_withFun_returnsFunToken() throws {
        
        // given
        let sut = Scanner("fun")
        
        // when
        let result = sut.scanTokens()
        
        // then
        XCTAssertEqual(result, [Token(type: .fun, lexeme: "fun", literal: nil, line: 1),
                                Token(type: .eof, lexeme: "", literal: nil, line: 1)])
        XCTAssertFalse(Lox.hadError)
    }
    
    func testScanTokens_withIf_returnsIfToken() throws {
        
        // given
        let sut = Scanner("if")
        
        // when
        let result = sut.scanTokens()
        
        // then
        XCTAssertEqual(result, [Token(type: .if, lexeme: "if", literal: nil, line: 1),
                                Token(type: .eof, lexeme: "", literal: nil, line: 1)])
        XCTAssertFalse(Lox.hadError)
    }
    
    func testScanTokens_withNil_returnsNilToken() throws {
        
        // given
        let sut = Scanner("nil")
        
        // when
        let result = sut.scanTokens()
        
        // then
        XCTAssertEqual(result, [Token(type: .nil, lexeme: "nil", literal: nil, line: 1),
                                Token(type: .eof, lexeme: "", literal: nil, line: 1)])
        XCTAssertFalse(Lox.hadError)
    }
    
    func testScanTokens_withOr_returnsOrToken() throws {
        
        // given
        let sut = Scanner("or")
        
        // when
        let result = sut.scanTokens()
        
        // then
        XCTAssertEqual(result, [Token(type: .or, lexeme: "or", literal: nil, line: 1),
                                Token(type: .eof, lexeme: "", literal: nil, line: 1)])
        XCTAssertFalse(Lox.hadError)
    }
    
    func testScanTokens_withPrint_returnsPrintToken() throws {
        
        // given
        let sut = Scanner("print")
        
        // when
        let result = sut.scanTokens()
        
        // then
        XCTAssertEqual(result, [Token(type: .print, lexeme: "print", literal: nil, line: 1),
                                Token(type: .eof, lexeme: "", literal: nil, line: 1)])
        XCTAssertFalse(Lox.hadError)
    }
    
    func testScanTokens_withReturn_returnsReturnToken() throws {
        
        // given
        let sut = Scanner("return")
        
        // when
        let result = sut.scanTokens()
        
        // then
        XCTAssertEqual(result, [Token(type: .return, lexeme: "return", literal: nil, line: 1),
                                Token(type: .eof, lexeme: "", literal: nil, line: 1)])
        XCTAssertFalse(Lox.hadError)
    }
    
    func testScanTokens_withSuper_returnsSuperToken() throws {
        
        // given
        let sut = Scanner("super")
        
        // when
        let result = sut.scanTokens()
        
        // then
        XCTAssertEqual(result, [Token(type: .super, lexeme: "super", literal: nil, line: 1),
                                Token(type: .eof, lexeme: "", literal: nil, line: 1)])
        XCTAssertFalse(Lox.hadError)
    }
    
    func testScanTokens_withThis_returnsThisToken() throws {
        
        // given
        let sut = Scanner("this")
        
        // when
        let result = sut.scanTokens()
        
        // then
        XCTAssertEqual(result, [Token(type: .this, lexeme: "this", literal: nil, line: 1),
                                Token(type: .eof, lexeme: "", literal: nil, line: 1)])
        XCTAssertFalse(Lox.hadError)
    }
    
    func testScanTokens_withTrue_returnsTrueToken() throws {
        
        // given
        let sut = Scanner("true")
        
        // when
        let result = sut.scanTokens()
        
        // then
        XCTAssertEqual(result, [Token(type: .true, lexeme: "true", literal: nil, line: 1),
                                Token(type: .eof, lexeme: "", literal: nil, line: 1)])
        XCTAssertFalse(Lox.hadError)
    }
    
    func testScanTokens_withVar_returnsVarToken() throws {
        
        // given
        let sut = Scanner("var")
        
        // when
        let result = sut.scanTokens()
        
        // then
        XCTAssertEqual(result, [Token(type: .var, lexeme: "var", literal: nil, line: 1),
                                Token(type: .eof, lexeme: "", literal: nil, line: 1)])
        XCTAssertFalse(Lox.hadError)
    }
    
    func testScanTokens_withWhile_returnsWhileToken() throws {
        
        // given
        let sut = Scanner("while")
        
        // when
        let result = sut.scanTokens()
        
        // then
        XCTAssertEqual(result, [Token(type: .while, lexeme: "while", literal: nil, line: 1),
                                Token(type: .eof, lexeme: "", literal: nil, line: 1)])
        XCTAssertFalse(Lox.hadError)
    }
    
    func testScanTokens_withIdentifier_returnsWhileToken() throws {
        
        // given
        let sut = Scanner("orchid")
        
        // when
        let result = sut.scanTokens()
        
        // then
        XCTAssertEqual(result, [Token(type: .identifier, lexeme: "orchid", literal: nil, line: 1),
                                Token(type: .eof, lexeme: "", literal: nil, line: 1)])
        XCTAssertFalse(Lox.hadError)
    }
    
    func testScanTokens_withFewTokens_returnsFewTokens() throws {
        
        // given
        let sut = Scanner("while (x > 5) { x = x + 1 }")
        
        // when
        let result = sut.scanTokens()
        
        // then
        XCTAssertEqual(result, [Token(type: .while, lexeme: "while", literal: nil, line: 1),
                                Token(type: .leftParen, lexeme: "(", literal: nil, line: 1),
                                Token(type: .identifier, lexeme: "x", literal: nil, line: 1),
                                Token(type: .greater, lexeme: ">", literal: nil, line: 1),
                                Token(type: .number, lexeme: "5", literal: .number(5), line: 1),
                                Token(type: .rightParen, lexeme: ")", literal: nil, line: 1),
                                Token(type: .leftBrace, lexeme: "{", literal: nil, line: 1),
                                Token(type: .identifier, lexeme: "x", literal: nil, line: 1),
                                Token(type: .equal, lexeme: "=", literal: nil, line: 1),
                                Token(type: .identifier, lexeme: "x", literal: nil, line: 1),
                                Token(type: .plus, lexeme: "+", literal: nil, line: 1),
                                Token(type: .number, lexeme: "1", literal: .number(1), line: 1),
                                Token(type: .rightBrace, lexeme: "}", literal: nil, line: 1),
                                Token(type: .eof, lexeme: "", literal: nil, line: 1)])
        XCTAssertFalse(Lox.hadError)
    }
        
    func testScanTokens_withBlockComment_returnsEofToken() throws {
        
        // given
        let sut = Scanner("/* This is a temporary code */")
        
        // when
        let result = sut.scanTokens()
        
        // then
        XCTAssertEqual(result, [Token(type: .eof, lexeme: "", literal: nil, line: 1)])
        XCTAssertFalse(Lox.hadError)
    }
    
    func testScanTokens_withFewLinesBlockComment_returnsEofToken() throws {
        
        // given
        let sut = Scanner("/* This is a \n temporary code */")
        
        // when
        let result = sut.scanTokens()
        
        // then
        XCTAssertEqual(result, [Token(type: .eof, lexeme: "", literal: nil, line: 2)])
        XCTAssertFalse(Lox.hadError)
    }
    
    func testScanTokens_withUnterminatedBlockComment_sendsErrorToLox() throws {
        
        // given
        let sut = Scanner("/* This is a temporary code")
        
        // when
        let result = sut.scanTokens()
        
        // then
        XCTAssertEqual(result, [Token(type: .eof, lexeme: "", literal: nil, line: 1)])
        XCTAssertTrue(Lox.hadError)
    }
    
    func testScanTokens_withNotSupportedCaharacter_sendsErrorToLox() throws {
        
        // given
        let sut = Scanner("~")
        
        // when
        let result = sut.scanTokens()
        
        // then
        XCTAssertEqual(result, [Token(type: .eof, lexeme: "", literal: nil, line: 1)])
        XCTAssertTrue(Lox.hadError)
    }
}
