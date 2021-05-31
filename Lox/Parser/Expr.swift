class Expr: Equatable {
	func accept<V: VisitorExpr, T>(visitor: V) throws -> T where T == V.ExprReturn {
		fatalError()
	}

	static func == (lhs: Expr, rhs: Expr) -> Bool {
		lhs.isEqual(to: rhs)
	}

	func isEqual(to other: Expr) -> Bool {
		fatalError()
	}
}

protocol VisitorExpr{

	associatedtype ExprReturn

	func visitBinaryExpr( _ expr: Binary) throws -> ExprReturn
	func visitGroupingExpr( _ expr: Grouping) throws -> ExprReturn
	func visitLiteralExpr( _ expr: Literal) throws -> ExprReturn
	func visitUnaryExpr( _ expr: Unary) throws -> ExprReturn
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

	override func accept<V: VisitorExpr, T>(visitor: V) throws -> T where T == V.ExprReturn {
		try visitor.visitBinaryExpr(self)
	}

	override func isEqual(to other: Expr) -> Bool {
		guard let other = other as? Binary else { return false }
		return self.left == other.left &&
			self.`operator` == other.`operator` &&
			self.right == other.right
	}
}

final class Grouping: Expr {

	let expressions: [Expr]

	init(expressions: [Expr]) {
		self.expressions = expressions
	}

	override func accept<V: VisitorExpr, T>(visitor: V) throws -> T where T == V.ExprReturn {
		try visitor.visitGroupingExpr(self)
	}

	override func isEqual(to other: Expr) -> Bool {
		guard let other = other as? Grouping else { return false }
		return self.expressions == other.expressions
	}
}

final class Literal: Expr {

	let value: LiteralType?

	init(value: LiteralType?) {
		self.value = value
	}

	override func accept<V: VisitorExpr, T>(visitor: V) throws -> T where T == V.ExprReturn {
		try visitor.visitLiteralExpr(self)
	}

	override func isEqual(to other: Expr) -> Bool {
		guard let other = other as? Literal else { return false }
		return self.value == other.value
	}
}

final class Unary: Expr {

	let `operator`: Token
	let right: Expr

	init(`operator`: Token, right: Expr) {
		self.`operator` = `operator`
		self.right = right
	}

	override func accept<V: VisitorExpr, T>(visitor: V) throws -> T where T == V.ExprReturn {
		try visitor.visitUnaryExpr(self)
	}

	override func isEqual(to other: Expr) -> Bool {
		guard let other = other as? Unary else { return false }
		return self.`operator` == other.`operator` &&
			self.right == other.right
	}
}

