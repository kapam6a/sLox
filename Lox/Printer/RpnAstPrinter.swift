//
//  RpnAstPrinter.swift
//  Lox
//
//  Created by Алексей Якименко on 27.05.2021.
//

import Foundation

final class RpnAstPrinter: VisitorExpr {
    
    func print(_ expr: Expr) -> String {
        try! expr.accept(visitor: self)
    }
    
    func visitThisExpr(_ expr: This) throws -> String {
        ""
    }
    
    func visitLoxSetExpr(_ expr: LoxSet) throws -> String {
        ""
    }
    
    func visitGetExpr(_ expr: Get) throws -> String {
        ""
    }
    
    func visitCallExpr(_ expr: Call) throws -> String {
        ""
    }
    
    func visitLogicalExpr(_ expr: Logical) throws -> String {
        ""
    }
    
    func visitAssignExpr(_ expr: Assign) throws -> String {
        ""
    }
    
    func visitVariableExpr(_ expr: Variable) throws -> String {
        ""
    }
    
    func visitBinaryExpr(_ expr: Binary) throws -> String {
        try format(expr.operator.lexeme, [expr.left, expr.right])
    }
    
    func visitGroupingExpr(_ expr: Grouping) throws -> String {
        try format(nil, expr.expressions)
    }
    
    func visitLiteralExpr(_ expr: Literal) throws -> String {
        if expr.value == nil { return "nil" }
        return expr.value!.description
    }
    
    func visitUnaryExpr(_ expr: Unary) throws -> String {
        try format(expr.operator.lexeme, [expr.right])
    }
}

private extension RpnAstPrinter {
    
    func format(_ name: String?, _ exprs: [Expr]) throws -> String {
        var str = ""
        if exprs.count == 1 {
            str.append(try exprs[0].accept(visitor: self))
            name.map { str.append(" " + $0) }
        } else {
            try exprs.forEach {
                let expr = try $0.accept(visitor: self)
                str.append(expr + " ")
            }
            name.map { str.append($0) }
        }
        return str
    }
}
