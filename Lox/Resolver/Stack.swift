//
//  Stack.swift
//  Lox
//
//  Created by Алексей Якименко on 12.06.2021.
//

import Foundation

final class Stack<T>: Sequence {
    
    private var array: [T] = []
    
    @discardableResult func pop() -> T? {
        array.popLast()
    }
    
    func push(_ object: T) {
        array.append(object)
    }
    
    func peek() -> T? {
        array.last
    }
    
    func hasNext() -> Bool {
        !array.isEmpty
    }
    
    func size() -> Int {
        array.count
    }
    
    func get(_ index: Int) -> T? {
        array[index]
    }
    
    func makeIterator() -> IndexingIterator<Array<T>> {
        array.makeIterator() 
    }
}
