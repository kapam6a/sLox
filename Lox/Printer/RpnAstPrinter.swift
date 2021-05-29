//
//  RpnAstPrinter.swift
//  Lox
//
//  Created by Алексей Якименко on 27.05.2021.
//

import Foundation

final class RpnAstPrinter: Visitor {
    
    func print(_ expr: Expr) -> String {
        expr.accept(visitor: self)
    }
    
    func visitBinaryExpr(_ expr: Binary) -> String {
        format(expr.operator.lexeme, [expr.left, expr.right])
    }
    
    func visitGroupingExpr(_ expr: Grouping) -> String {
        format(nil, expr.expressions)
    }
    
    func visitLiteralExpr(_ expr: Literal) -> String {
        if expr.value == nil { return "nil" }
        return expr.value!.description
    }
    
    func visitUnaryExpr(_ expr: Unary) -> String {
        format(expr.operator.lexeme, [expr.right])
    }
}

private extension RpnAstPrinter {
    
    func format(_ name: String?, _ exprs: [Expr]) -> String {
        var str = ""
        if exprs.count == 1 {
            str.append(exprs[0].accept(visitor: self))
            name.map { str.append(" " + $0) }
        } else {
            exprs.forEach { str.append($0.accept(visitor: self) + " ") }
            name.map { str.append($0) }
        }
        return str
    }
}
