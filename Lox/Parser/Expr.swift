protocol Expr {
	func accept<V: Visitor, T>(visitor: V) -> T where T == V.T
}

protocol Visitor {

	associatedtype T

	func visitBinaryExpr( _ expr: Binary) -> T
	func visitGroupingExpr( _ expr: Grouping) -> T
	func visitLiteralExpr( _ expr: Literal) -> T
	func visitUnaryExpr( _ expr: Unary) -> T
}

final class Binary: Expr {

	let left: Expr
	let `operator`: Token
	let right: Expr

	init(left: Expr, `operator`: Token, right: Expr) {
		self.left = left
		self.`operator` = `operator`
		self.right = right
	}

	func accept<V: Visitor, T>(visitor: V) -> T where T == V.T {
		visitor.visitBinaryExpr(self)
	}
}

final class Grouping: Expr {

	let expression: Expr

	init(expression: Expr) {
		self.expression = expression
	}

	func accept<V: Visitor, T>(visitor: V) -> T where T == V.T {
		visitor.visitGroupingExpr(self)
	}
}

final class Literal: Expr {

	let value: LiteralType?

	init(value: LiteralType?) {
		self.value = value
	}

	func accept<V: Visitor, T>(visitor: V) -> T where T == V.T {
		visitor.visitLiteralExpr(self)
	}
}

final class Unary: Expr {

	let `operator`: Token
	let right: Expr

	init(`operator`: Token, right: Expr) {
		self.`operator` = `operator`
		self.right = right
	}

	func accept<V: Visitor, T>(visitor: V) -> T where T == V.T {
		visitor.visitUnaryExpr(self)
	}
}

