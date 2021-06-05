//
//  AstPrinter.swift
//  Lox
//
//  Created by Алексей Якименко on 26.05.2021.
//

import Foundation

final class AstPrinter: VisitorExpr {
    
    func print(_ expr: Expr) -> String {
        try! expr.accept(visitor: self)
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
        try parenthesize(expr.operator.lexeme, [expr.left, expr.right])
    }
    
    func visitGroupingExpr(_ expr: Grouping) throws -> String {
        try parenthesize("group", expr.expressions)
    }
    
    func visitLiteralExpr(_ expr: Literal) throws -> String {
        if expr.value == nil { return "nil" }
        return expr.value!.description
    }
    
    func visitUnaryExpr(_ expr: Unary) throws -> String {
        try parenthesize(expr.operator.lexeme, [expr.right])
    }
}

private extension AstPrinter {
    
    func parenthesize(_ name: String , _ exprs: [Expr]) throws -> String {
        var str = "(" + name
        try exprs.forEach {
            let exprStr = try $0.accept(visitor: self)
            str.append(" " + exprStr)
        }
        str.append(")")
        return str
    }
}
