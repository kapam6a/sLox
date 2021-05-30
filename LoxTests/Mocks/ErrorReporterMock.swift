//
//  ErrorReporterMock.swift
//  LoxTests
//
//  Created by Алексей Якименко on 29.05.2021.
//

import Foundation

final class ErrorReporterMock: ErrorReporter {
    
    var reportArgs: (Int, String, String)?
    func report(_ line: Int, _ where: String, _ message: String) {
        reportArgs = (line, `where`, message)
    }
    
    var reportArg: String?
    func report(_ messsage: String) {
        reportArg = messsage
    }
}
