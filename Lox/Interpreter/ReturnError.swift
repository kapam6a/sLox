//
//  ReturnError.swift
//  Lox
//
//  Created by Алексей Якименко on 08.06.2021.
//

import Foundation

final class ReturnError: Error {
    
    let value: Any?
    
    init(_ value: Any?) {
        self.value = value
    }
}
