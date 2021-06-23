class Expr: Equatable, Hashable {
	func accept<V: VisitorExpr, T>(visitor: V) throws -> T where T == V.ExprReturn {
		fatalError()
	}

	static func == (lhs: Expr, rhs: Expr) -> Bool {
		lhs.isEqual(to: rhs)
	}

	func isEqual(to other: Expr) -> Bool {
		fatalError()
	}

	func hash(into hasher: inout Hasher) {
		fatalError()
	}
}

protocol VisitorExpr{

	associatedtype ExprReturn

	func visitAssignExpr( _ expr: Assign) throws -> ExprReturn
	func visitBinaryExpr( _ expr: Binary) throws -> ExprReturn
	func visitCallExpr( _ expr: Call) throws -> ExprReturn
	func visitGetExpr( _ expr: Get) throws -> ExprReturn
	func visitGroupingExpr( _ expr: Grouping) throws -> ExprReturn
	func visitLiteralExpr( _ expr: Literal) throws -> ExprReturn
	func visitLogicalExpr( _ expr: Logical) throws -> ExprReturn
	func visitLoxSetExpr( _ expr: LoxSet) throws -> ExprReturn
	func visitSuperExpr( _ expr: Super) throws -> ExprReturn
	func visitThisExpr( _ expr: This) throws -> ExprReturn
	func visitUnaryExpr( _ expr: Unary) throws -> ExprReturn
	func visitVariableExpr( _ expr: Variable) throws -> ExprReturn
}

final class Assign: Expr {

	let name: Token
	let value: Expr

	init(name: Token, value: Expr) {
		self.name = name
		self.value = value
	}

	override func accept<V: VisitorExpr, T>(visitor: V) throws -> T where T == V.ExprReturn {
		try visitor.visitAssignExpr(self)
	}

	override func isEqual(to other: Expr) -> Bool {
		guard let other = other as? Assign else { return false }
		return self.name == other.name &&
			self.value == other.value
	}

	override func hash(into hasher: inout Hasher) {
		hasher.combine(name)
		hasher.combine(value)
	}
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

	override func hash(into hasher: inout Hasher) {
		hasher.combine(left)
		hasher.combine(`operator`)
		hasher.combine(right)
	}
}

final class Call: Expr {

	let callee: Expr
	let paren: Token
	let arguments: [Expr]

	init(callee: Expr, paren: Token, arguments: [Expr]) {
		self.callee = callee
		self.paren = paren
		self.arguments = arguments
	}

	override func accept<V: VisitorExpr, T>(visitor: V) throws -> T where T == V.ExprReturn {
		try visitor.visitCallExpr(self)
	}

	override func isEqual(to other: Expr) -> Bool {
		guard let other = other as? Call else { return false }
		return self.callee == other.callee &&
			self.paren == other.paren &&
			self.arguments == other.arguments
	}

	override func hash(into hasher: inout Hasher) {
		hasher.combine(callee)
		hasher.combine(paren)
		hasher.combine(arguments)
	}
}

final class Get: Expr {

	let object: Expr
	let name: Token

	init(object: Expr, name: Token) {
		self.object = object
		self.name = name
	}

	override func accept<V: VisitorExpr, T>(visitor: V) throws -> T where T == V.ExprReturn {
		try visitor.visitGetExpr(self)
	}

	override func isEqual(to other: Expr) -> Bool {
		guard let other = other as? Get else { return false }
		return self.object == other.object &&
			self.name == other.name
	}

	override func hash(into hasher: inout Hasher) {
		hasher.combine(object)
		hasher.combine(name)
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

	override func hash(into hasher: inout Hasher) {
		hasher.combine(expressions)
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

	override func hash(into hasher: inout Hasher) {
		hasher.combine(value)
	}
}

final class Logical: Expr {

	let left: Expr
	let `operator`: Token
	let right: Expr

	init(left: Expr, `operator`: Token, right: Expr) {
		self.left = left
		self.`operator` = `operator`
		self.right = right
	}

	override func accept<V: VisitorExpr, T>(visitor: V) throws -> T where T == V.ExprReturn {
		try visitor.visitLogicalExpr(self)
	}

	override func isEqual(to other: Expr) -> Bool {
		guard let other = other as? Logical else { return false }
		return self.left == other.left &&
			self.`operator` == other.`operator` &&
			self.right == other.right
	}

	override func hash(into hasher: inout Hasher) {
		hasher.combine(left)
		hasher.combine(`operator`)
		hasher.combine(right)
	}
}

final class LoxSet: Expr {

	let object: Expr
	let name: Token
	let value: Expr

	init(object: Expr, name: Token, value: Expr) {
		self.object = object
		self.name = name
		self.value = value
	}

	override func accept<V: VisitorExpr, T>(visitor: V) throws -> T where T == V.ExprReturn {
		try visitor.visitLoxSetExpr(self)
	}

	override func isEqual(to other: Expr) -> Bool {
		guard let other = other as? LoxSet else { return false }
		return self.object == other.object &&
			self.name == other.name &&
			self.value == other.value
	}

	override func hash(into hasher: inout Hasher) {
		hasher.combine(object)
		hasher.combine(name)
		hasher.combine(value)
	}
}

final class Super: Expr {

	let keyword: Token
	let method: Token

	init(keyword: Token, method: Token) {
		self.keyword = keyword
		self.method = method
	}

	override func accept<V: VisitorExpr, T>(visitor: V) throws -> T where T == V.ExprReturn {
		try visitor.visitSuperExpr(self)
	}

	override func isEqual(to other: Expr) -> Bool {
		guard let other = other as? Super else { return false }
		return self.keyword == other.keyword &&
			self.method == other.method
	}

	override func hash(into hasher: inout Hasher) {
		hasher.combine(keyword)
		hasher.combine(method)
	}
}

final class This: Expr {

	let keyword: Token

	init(keyword: Token) {
		self.keyword = keyword
	}

	override func accept<V: VisitorExpr, T>(visitor: V) throws -> T where T == V.ExprReturn {
		try visitor.visitThisExpr(self)
	}

	override func isEqual(to other: Expr) -> Bool {
		guard let other = other as? This else { return false }
		return self.keyword == other.keyword
	}

	override func hash(into hasher: inout Hasher) {
		hasher.combine(keyword)
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

	override func hash(into hasher: inout Hasher) {
		hasher.combine(`operator`)
		hasher.combine(right)
	}
}

final class Variable: Expr {

	let name: Token

	init(name: Token) {
		self.name = name
	}

	override func accept<V: VisitorExpr, T>(visitor: V) throws -> T where T == V.ExprReturn {
		try visitor.visitVariableExpr(self)
	}

	override func isEqual(to other: Expr) -> Bool {
		guard let other = other as? Variable else { return false }
		return self.name == other.name
	}

	override func hash(into hasher: inout Hasher) {
		hasher.combine(name)
	}
}

