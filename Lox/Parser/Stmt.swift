class Stmt: Equatable, Hashable {
	func accept<V: VisitorStmt, T>(visitor: V) throws -> T where T == V.StmtReturn {
		fatalError()
	}

	static func == (lhs: Stmt, rhs: Stmt) -> Bool {
		lhs.isEqual(to: rhs)
	}

	func isEqual(to other: Stmt) -> Bool {
		fatalError()
	}

	func hash(into hasher: inout Hasher) {
		fatalError()
	}
}

protocol VisitorStmt{

	associatedtype StmtReturn

	func visitBlockStmt( _ stmt: Block) throws -> StmtReturn
	func visitClassStmt( _ stmt: Class) throws -> StmtReturn
	func visitExpressionStmt( _ stmt: Expression) throws -> StmtReturn
	func visitFunctionStmt( _ stmt: Function) throws -> StmtReturn
	func visitIfStmt( _ stmt: If) throws -> StmtReturn
	func visitPrintStmt( _ stmt: Print) throws -> StmtReturn
	func visitReturnStmt( _ stmt: Return) throws -> StmtReturn
	func visitVarStmt( _ stmt: Var) throws -> StmtReturn
	func visitWhileStmt( _ stmt: While) throws -> StmtReturn
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

	override func hash(into hasher: inout Hasher) {
		hasher.combine(statements)
	}
}

final class Class: Stmt {

	let name: Token
	let methods: [Function]

	init(name: Token, methods: [Function]) {
		self.name = name
		self.methods = methods
	}

	override func accept<V: VisitorStmt, T>(visitor: V) throws -> T where T == V.StmtReturn {
		try visitor.visitClassStmt(self)
	}

	override func isEqual(to other: Stmt) -> Bool {
		guard let other = other as? Class else { return false }
		return self.name == other.name &&
			self.methods == other.methods
	}

	override func hash(into hasher: inout Hasher) {
		hasher.combine(name)
		hasher.combine(methods)
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

	override func hash(into hasher: inout Hasher) {
		hasher.combine(expression)
	}
}

final class Function: Stmt {

	let name: Token
	let params: [Token]
	let body: [Stmt]

	init(name: Token, params: [Token], body: [Stmt]) {
		self.name = name
		self.params = params
		self.body = body
	}

	override func accept<V: VisitorStmt, T>(visitor: V) throws -> T where T == V.StmtReturn {
		try visitor.visitFunctionStmt(self)
	}

	override func isEqual(to other: Stmt) -> Bool {
		guard let other = other as? Function else { return false }
		return self.name == other.name &&
			self.params == other.params &&
			self.body == other.body
	}

	override func hash(into hasher: inout Hasher) {
		hasher.combine(name)
		hasher.combine(params)
		hasher.combine(body)
	}
}

final class If: Stmt {

	let condition: Expr 
	let thenBranch: Stmt
	let elseBranch: Stmt?

	init(condition: Expr , thenBranch: Stmt, elseBranch: Stmt?) {
		self.condition = condition
		self.thenBranch = thenBranch
		self.elseBranch = elseBranch
	}

	override func accept<V: VisitorStmt, T>(visitor: V) throws -> T where T == V.StmtReturn {
		try visitor.visitIfStmt(self)
	}

	override func isEqual(to other: Stmt) -> Bool {
		guard let other = other as? If else { return false }
		return self.condition == other.condition &&
			self.thenBranch == other.thenBranch &&
			self.elseBranch == other.elseBranch
	}

	override func hash(into hasher: inout Hasher) {
		hasher.combine(condition)
		hasher.combine(thenBranch)
		hasher.combine(elseBranch)
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

	override func hash(into hasher: inout Hasher) {
		hasher.combine(expression)
	}
}

final class Return: Stmt {

	let keyword: Token 
	let value: Expr?

	init(keyword: Token , value: Expr?) {
		self.keyword = keyword
		self.value = value
	}

	override func accept<V: VisitorStmt, T>(visitor: V) throws -> T where T == V.StmtReturn {
		try visitor.visitReturnStmt(self)
	}

	override func isEqual(to other: Stmt) -> Bool {
		guard let other = other as? Return else { return false }
		return self.keyword == other.keyword &&
			self.value == other.value
	}

	override func hash(into hasher: inout Hasher) {
		hasher.combine(keyword)
		hasher.combine(value)
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

	override func hash(into hasher: inout Hasher) {
		hasher.combine(name)
		hasher.combine(initializer)
	}
}

final class While: Stmt {

	let condition: Expr
	let body: Stmt

	init(condition: Expr, body: Stmt) {
		self.condition = condition
		self.body = body
	}

	override func accept<V: VisitorStmt, T>(visitor: V) throws -> T where T == V.StmtReturn {
		try visitor.visitWhileStmt(self)
	}

	override func isEqual(to other: Stmt) -> Bool {
		guard let other = other as? While else { return false }
		return self.condition == other.condition &&
			self.body == other.body
	}

	override func hash(into hasher: inout Hasher) {
		hasher.combine(condition)
		hasher.combine(body)
	}
}

