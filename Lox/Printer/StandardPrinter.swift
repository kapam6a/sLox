//
//  StandardPrinter.swift
//  Lox
//
//  Created by Алексей Якименко on 30.05.2021.
//

import Foundation

final class StandardPrinter: Printer {
    
    func print(_ string: String) {
        Swift.print(string)
    }
}
