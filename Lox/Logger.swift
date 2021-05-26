//
//  Logger.swift
//  Lox
//
//  Created by Алексей Якименко on 26.05.2021.
//

import Foundation

final class func error(_ line: Int, _ message: String) {
    report(line, "", message)
    hadError = true
}
