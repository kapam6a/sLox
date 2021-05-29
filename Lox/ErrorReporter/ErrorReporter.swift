//
//  ErrorReporter.swift
//  Lox
//
//  Created by Алексей Якименко on 29.05.2021.
//

import Foundation

protocol ErrorReporter {
    
    func report(_ line: Int, _ where: String, _ message: String)
}
