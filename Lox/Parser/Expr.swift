class Expr {}

final class Binary: Expr {

	let left: Expr
	let `operator`: Token
	let right: Expr

	init(left: Expr, `operator`: Token, right: Expr) {
		self.left = left
		self.`operator` = `operator`
		self.right = right
	}
}

final class Grouping: Expr {

	let expression: Expr

	init(expression: Expr) {
		self.expression = expression
	}
}

final class Literal: Expr {

	let value: Literal

	init(value: Literal) {
		self.value = value
	}
}

final class Unary: Expr {

	let `operator`: Token
	let right: Expr

	init(`operator`: Token, right: Expr) {
		self.`operator` = `operator`
		self.right = right
	}
}

