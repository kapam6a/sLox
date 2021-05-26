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
    "Binary   :: left: Expr, `operator`: Token, right: Expr",
    "Grouping :: expression: Expr",
    "Literal  :: value: LiteralType?",
    "Unary    :: `operator`: Token, right: Expr"
])

func defineAst(_ outputDir: String, _ baseName: String, _ types: [String]) {
    let fullPath = outputDir + baseName + ".swift"
    var str = "protocol " + baseName + " {" + "\n"
    str.append("\t" + "func accept<V: Visitor, T>(visitor: V) -> T where T == V.T" + "\n")
    str.append("}" + "\n")
    str.append("\n")
    str.append(defineVisitor(baseName, types))
    str.append("\n")
    types.forEach {
        let className = $0.components(separatedBy: "::")[0].trimmingCharacters(in: .whitespaces)
        let fields = $0.components(separatedBy: "::")[1].trimmingCharacters(in: .whitespaces)
        str.append(defineType(baseName, className, fields))
        str.append("\n")
    }
    try! str.write(to: URL(fileURLWithPath: fullPath), atomically: true, encoding: .utf8)
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
    str.append("\t" + "func accept<V: Visitor, T>(visitor: V) -> T where T == V.T {" + "\n")
    str.append("\t\t" + "visitor.visit" + className + baseName + "(self)" + "\n")
    str.append("\t" + "}" + "\n")
    str.append("}" + "\n")
    return str
}

func defineVisitor(_ baseName: String, _ types: [String]) -> String {
    var str = "protocol Visitor {" + "\n"
    str.append("\n")
    str.append("\t" + "associatedtype T" + "\n")
    str.append("\n")
    types.forEach {
        let className = $0.components(separatedBy: "::")[0].trimmingCharacters(in: .whitespaces)
        str.append("\t" + "func visit" + className + baseName + "( _ " + baseName.lowercased() + ": " + className + ") -> T" + "\n")
    }
    str.append("}" + "\n")
    return str
}
