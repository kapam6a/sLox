//
//  AstPrinter.swift
//  Lox
//
//  Created by Алексей Якименко on 26.05.2021.
//

import Foundation

final class AstPrinter: Visitor {
    
    func print(_ expr: Expr) -> String {
        expr.accept(visitor: self)
    }
    
    func visitBinaryExpr(_ expr: Binary) -> String {
        parenthesize(expr.operator.lexeme, expr.left, expr.right)
    }
    
    func visitGroupingExpr(_ expr: Grouping) -> String {
        parenthesize("group", expr.expression)
    }
    
    func visitLiteralExpr(_ expr: Literal) -> String {
        if expr.value == nil { return "nil" }
        return expr.value!.description
    }
    
    func visitUnaryExpr(_ expr: Unary) -> String {
        parenthesize(expr.operator.lexeme, expr.right)
    }
}

private extension AstPrinter {
    
    func parenthesize(_ name: String , _ exprs: Expr...) -> String {
        var str = "(" + name
        exprs.forEach {
            str.append(" " + $0.accept(visitor: self))
        }
        str.append(")")
        return str
    }
}
