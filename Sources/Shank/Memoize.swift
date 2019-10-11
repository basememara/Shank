//
//  Memoize.swift
//  
//
//  Created by Kerr Marin Miller on 11/10/2019.
//

import Foundation

func memoize<T:Hashable, U>(fn: @escaping (T) -> U) -> (T) -> U {
    var cache = [T: U]()
    return { (val: T) -> U in
        if let value = cache[val] {
            return value
        }
        let newValue = fn(val)
        cache[val] = newValue
        return newValue
    }
}
