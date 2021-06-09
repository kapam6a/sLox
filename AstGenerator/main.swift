//
//  main.swift
//  AstGenerator
//
//  Created by Алексей Якименко on 26.05.2021.
//

import Foundation

if CommandLine.arguments.count != 2 {
    print("Usage: generate_ast <output directory>")
    exit(64)
}
let outputDir = CommandLine.arguments[1]

defineAst(outputDir, "Expr", [
    "Assign   :: name: Token, value: Expr",
    "Binary   :: left: Expr, `operator`: Token, right: Expr",
    "Call     :: callee: Expr, paren: Token, arguments: [Expr]",
    "Grouping :: expressions: [Expr]",
    "Literal  :: value: LiteralType?",
    "Logical  :: left: Expr, `operator`: Token, right: Expr",
    "Unary    :: `operator`: Token, right: Expr",
    "Variable :: name: Token"
])

defineAst(outputDir, "Stmt", [
    "Block      :: statements: [Stmt]",
    "Expression :: expression: Expr",
    "Function   :: name: Token, params: [Token], body: [Stmt]",
    "If         :: condition: Expr , thenBranch: Stmt, elseBranch: Stmt?",
    "Print      :: expression: Expr",
    "Return     :: keyword: Token , value: Expr?",
    "Var        :: name: Token , initializer: Expr?",
    "While      :: condition: Expr, body: Stmt"
])

func defineAst(_ outputDir: String, _ baseName: String, _ types: [String]) {
    var str = defineExpr(baseName)
    str.append(defineVisitor(baseName, types))
    types.forEach {
        let className = $0.components(separatedBy: "::")[0].trimmingCharacters(in: .whitespaces)
        let fields = $0.components(separatedBy: "::")[1].trimmingCharacters(in: .whitespaces)
        str.append(defineType(baseName, className, fields))
        str.append("\n")
    }
    try! str.write(to: URL(fileURLWithPath: outputDir + baseName + ".swift"), atomically: true, encoding: .utf8)
}

func defineExpr(_ baseName: String) -> String {
    var str = "class " + baseName + ": Equatable {" + "\n"
    str.append("\t" + "func accept<V: Visitor" + baseName + ", T>(visitor: V) throws -> T where T == V." + baseName + "Return {" + "\n")
    str.append("\t\t" + "fatalError()" + "\n")
    str.append("\t" + "}" + "\n")
    str.append("\n")
    str.append("\t" + "static func == (lhs: " + baseName + ", rhs: " + baseName + ") -> Bool {" + "\n")
    str.append("\t\t" + "lhs.isEqual(to: rhs)" + "\n")
    str.append("\t" + "}" + "\n")
    str.append("\n")
    str.append("\t" + "func isEqual(to other: " + baseName + ") -> Bool {" + "\n")
    str.append("\t\t" + "fatalError()" + "\n")
    str.append("\t" + "}" + "\n")
    str.append("}" + "\n")
    str.append("\n")
    return str
}

func defineType(_ baseName: String, _ className: String, _ fields: String) -> String {
    var str = "final class " + className + ": " + baseName + " {" + "\n"
    str.append("\n")
    fields.components(separatedBy: ", ").forEach {
        str.append("\t" + "let " + $0 + "\n")
    }
    str.append("\n")
    str.append("\t" + "init" + "(" + fields + ") {" + "\n")
    fields.components(separatedBy: ", ").forEach {
        let name = $0.components(separatedBy: ":")[0]
        str.append("\t\t" + "self." + name + " = " + name + "\n")
    }
    str.append("\t" + "}" + "\n")
    str.append("\n")
    str.append("\t" + "override func accept<V: Visitor" + baseName + ", T>(visitor: V) throws -> T where T == V." + baseName + "Return {" + "\n")
    str.append("\t\t" + "try visitor.visit" + className + baseName + "(self)" + "\n")
    str.append("\t" + "}" + "\n")
    str.append("\n")
    str.append("\t" + "override func isEqual(to other: " + baseName + ") -> Bool {" + "\n")
    str.append("\t\t" + "guard let other = other as? " + className + " else { return false }" + "\n")
    str.append("\t\t" + "return ")
    for (index, field) in fields.components(separatedBy: ", ").enumerated() {
        if index != fields.components(separatedBy: ", ").startIndex {
            str.append("\t\t\t")
        }
        let name = field.components(separatedBy: ":")[0]
        str.append("self." + name + " == " + "other." + name)
        if index != fields.components(separatedBy: ", ").endIndex - 1 {
            str.append(" &&")
        }
        str.append("\n")
    }
    str.append("\t" + "}" + "\n")
    str.append("}" + "\n")
    return str
}

func defineVisitor(_ baseName: String, _ types: [String]) -> String {
    var str = "protocol Visitor" + baseName + "{" + "\n"
    str.append("\n")
    str.append("\t" + "associatedtype " + baseName + "Return" + "\n")
    str.append("\n")
    types.forEach {
        let className = $0.components(separatedBy: "::")[0].trimmingCharacters(in: .whitespaces)
        str.append("\t" + "func visit" + className + baseName + "( _ " + baseName.lowercased() + ": " + className + ") throws -> " + baseName + "Return" + "\n")
    }
    str.append("}" + "\n")
    str.append("\n")
    return str
}
