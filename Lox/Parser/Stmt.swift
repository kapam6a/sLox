class Stmt: Equatable {
	func accept<V: VisitorStmt, T>(visitor: V) throws -> T where T == V.T {
		fatalError()
	}

	static func == (lhs: Stmt, rhs: Stmt) -> Bool {
		lhs.isEqual(to: rhs)
	}

	func isEqual(to other: Stmt) -> Bool {
		fatalError()
	}
}

protocol VisitorStmt{

	associatedtype T

	func visitExpressionStmt( _ stmt: Expression) throws -> T
	func visitPrintStmt( _ stmt: Print) throws -> T
}

final class Expression: Stmt {

	let expression: Expr

	init(expression: Expr) {
		self.expression = expression
	}

	override func accept<V: VisitorStmt, T>(visitor: V) throws -> T where T == V.T {
		try visitor.visitExpressionStmt(self)
	}

	override func isEqual(to other: Stmt) -> Bool {
		guard let other = other as? Expression else { return false }
		return self.expression == other.expression
	}
}

final class Print: Stmt {

	let expression: Expr

	init(expression: Expr) {
		self.expression = expression
	}

	override func accept<V: VisitorStmt, T>(visitor: V) throws -> T where T == V.T {
		try visitor.visitPrintStmt(self)
	}

	override func isEqual(to other: Stmt) -> Bool {
		guard let other = other as? Print else { return false }
		return self.expression == other.expression
	}
}

