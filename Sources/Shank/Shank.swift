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
private class Resolver {
    /// Stored object instance closures.
    private var factories = [String: () -> Any?]()
    
    /// Registers a specific type and its instantiating factory.
    func register<T>(_ type: T.Type = T.self, factory: @escaping () -> T) {
        let key = String(describing: T.self)
        factories[key] = factory
    }

    /// Resolves and returns an instance of the given type from the current registry.
    ///
    /// If the dependency is not found, an exception will occur.
    /// Use `.optional()` if you expect dependencies to be `nil`.
    func resolve<T>(_ type: T.Type = T.self) -> T {
        guard let instance = optional(T.self) else {
            fatalError("Dependency '\(T.self)' not resolved!")
        }
        
        return instance
    }

    /// Resolves and returns an optional instance of the given type from the current registry.
    func optional<T>(_ type: T.Type = T.self) -> T? {
        let key = String(describing: T.self)
        return factories[key]?() as? T
    }
    
    deinit {
        factories.removeAll()
    }
}

// MARK: Public API

public struct Container {
    /// Composition root for dependency instances.
    fileprivate static let root = Resolver()
    
    public init() {}
    
    public func `import`(@ModuleTypeBuilder _ modules: () -> [Module.Type]) {
        modules().forEach { $0.init().export() }
    }

    @_functionBuilder
    public struct ModuleTypeBuilder {
        
        public static func buildBlock(_ modules: Module.Type...) -> [Module.Type] {
            modules
        }
    }
}

/// A type that contributes to the object graph.
public protocol Module {
    init()
    func export()
}

public extension Module {
    private static var root: Resolver { Container.root }
    
    func make<T>(resolved object: @escaping () -> T) {
        Self.root.register(factory: object)
    }
    
    func resolve<T>(_ type: T.Type = T.self) -> T {
        Self.root.resolve()
    }
    
    func optional<T>(_ type: T.Type = T.self) -> T? {
        Self.root.optional()
    }
}

/// Resolves an instance from the dependency injection container.
@propertyWrapper
public struct Inject<Value> {
    private static var root: Resolver { Container.root }
    
    public var wrappedValue: Value {
        Self.root.resolve(Value.self)
    }
    
    public init() {}
}
