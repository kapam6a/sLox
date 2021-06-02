class Stmt: Equatable {
	func accept<V: VisitorStmt, T>(visitor: V) throws -> T where T == V.StmtReturn {
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

	associatedtype StmtReturn

	func visitBlockStmt( _ stmt: Block) throws -> StmtReturn
	func visitExpressionStmt( _ stmt: Expression) throws -> StmtReturn
	func visitPrintStmt( _ stmt: Print) throws -> StmtReturn
	func visitVarStmt( _ stmt: Var) throws -> StmtReturn
}

final class Block: Stmt {

	let statements: [Stmt]

	init(statements: [Stmt]) {
		self.statements = statements
	}

	override func accept<V: VisitorStmt, T>(visitor: V) throws -> T where T == V.StmtReturn {
		try visitor.visitBlockStmt(self)
	}

	override func isEqual(to other: Stmt) -> Bool {
		guard let other = other as? Block else { return false }
		return self.statements == other.statements
	}
}

final class Expression: Stmt {

	let expression: Expr

	init(expression: Expr) {
		self.expression = expression
	}

	override func accept<V: VisitorStmt, T>(visitor: V) throws -> T where T == V.StmtReturn {
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

	override func accept<V: VisitorStmt, T>(visitor: V) throws -> T where T == V.StmtReturn {
		try visitor.visitPrintStmt(self)
	}

	override func isEqual(to other: Stmt) -> Bool {
		guard let other = other as? Print else { return false }
		return self.expression == other.expression
	}
}

final class Var: Stmt {

	let name: Token 
	let initializer: Expr?

	init(name: Token , initializer: Expr?) {
		self.name = name
		self.initializer = initializer
	}

	override func accept<V: VisitorStmt, T>(visitor: V) throws -> T where T == V.StmtReturn {
		try visitor.visitVarStmt(self)
	}

	override func isEqual(to other: Stmt) -> Bool {
		guard let other = other as? Var else { return false }
		return self.name == other.name &&
			self.initializer == other.initializer
	}
}

