classExpr{
final class Binary: Expr {
	Binary(Expr left, Token operator, Expr right) {
		self.left = left
		self.operator = operator
		self.right = right
	}

		letExpr left
		letToken operator
		letExpr right
	}final class Grouping: Expr {
	Grouping(Expr expression) {
		self.expression = expression
	}

		letExpr expression
	}final class Literal: Expr {
	Literal(Object value) {
		self.value = value
	}

		letObject value
	}final class Unary: Expr {
	Unary(Token operator, Expr right) {
		self.operator = operator
		self.right = right
	}

		letToken operator
		letExpr right
	}}