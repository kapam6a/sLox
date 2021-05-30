//
//  StdErrorReporter.swift
//  Lox
//
//  Created by Алексей Якименко on 29.05.2021.
//

import Foundation

final class StandardErrorReporter: ErrorReporter {
    
    func report(_ line: Int, _ where: String, _ message: String) {
        let data = "[line \(line) ] Error \(`where`): \(message)".data(using: .utf8)
        FileHandle.standardError.write(data!)
    }
    
    func report(_ messsage: String) {
        let data = messsage.data(using: .utf8)
        FileHandle.standardError.write(data!)
    }
}
