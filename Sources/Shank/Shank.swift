//
//  Shank
//  A Swift micro-library that provides lightweight dependency injection.
//
//  Inspired by:
//  https://dagger.dev
//  https://github.com/hmlongco/Resolver
//  https://github.com/InsertKoinIO/koin
//
//  Created by Basem Emara on 2019-09-06.
//  Copyright © 2019 Zamzam Inc. All rights reserved.
//

import Foundation

/// A dependency registry that provides resolutions for object instances.
private class Container {
    /// Composition root for dependency factories.
    static let root = Container()
    
    /// Stored object instance closures.
    private var dependencies = [String: () -> Any?]()
    
    /// Registers a specific type and its instantiating factory.
    func register<T>(factory: @escaping () -> T) {
        let key = String(describing: T.self)
        dependencies[key] = factory
    }

    /// Resolves through inference and returns an instance of the given type from the current root container.
    ///
    /// If the dependency is not found, an exception will occur. Use `.optional()` if you expect dependencies to be `nil`.
    func resolve<T>() -> T {
        guard let instance: T = optional() else {
            fatalError("Dependency '\(T.self)' not resolved!")
        }
        
        return instance
    }

    /// Resolves and returns an optional instance of the given type from the current registry.
    func optional<T>() -> T? {
        let key = String(describing: T.self)
        return dependencies[key]?() as? T
    }
    
    deinit {
        dependencies.removeAll()
    }
}

// MARK: Public API

/// A type that contributes to the object graph.
public protocol Module {
    func register()
}

public extension Module {
    private static var root: Container { .root }
    
    func make<T>(factory: @escaping () -> T) {
        Self.root.register(factory: factory)
    }
    
    func resolve<T>() -> T {
        Self.root.resolve()
    }
    
    func optional<T>() -> T? {
        Self.root.optional()
    }
}

public extension Array where Element == Module {
    
    func register() {
        forEach { $0.register() }
    }
}

/// Resolves an instance from the dependency injection container.
@propertyWrapper
public struct Inject<Value> {
    private static var root: Container { .root }
    
    public var wrappedValue: Value {
        Self.root.resolve()
    }
    
    public init() {}
}
