//
//  PrinterMock.swift
//  LoxTests
//
//  Created by Алексей Якименко on 30.05.2021.
//

import Foundation

final class PrinterMock: Printer {
    
    var message: String?
    func print(_ string: String) {
        message = string
    }
}
