protocol Expr {
	func accept<T>(visitor: Visitor) -> T
}

protocol Visitor {
	func visitBinaryExpr<T>( _ expr: Binary) -> T
	func visitGroupingExpr<T>( _ expr: Grouping) -> T
	func visitLiteralExpr<T>( _ expr: Literal) -> T
	func visitUnaryExpr<T>( _ expr: Unary) -> T
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

	func accept<T>(visitor: Visitor) -> T {
		visitor.visitBinaryExpr(self)
	}
}

final class Grouping: Expr {

	let expression: Expr

	init(expression: Expr) {
		self.expression = expression
	}

	func accept<T>(visitor: Visitor) -> T {
		visitor.visitGroupingExpr(self)
	}
}

final class Literal: Expr {

	let value: Literal

	init(value: Literal) {
		self.value = value
	}

	func accept<T>(visitor: Visitor) -> T {
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

	func accept<T>(visitor: Visitor) -> T {
		visitor.visitUnaryExpr(self)
	}
}

