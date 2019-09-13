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
    /// Default dependency registry for object instances.
    static let root = Resolver()
    
    private var registry = [String: Registration<Any>]()
    private let applicationScope = ApplicationScope()
    private let uniqueScope = UniqueScope()
}

// MARK: Actions

private extension Resolver {
    
    /// Registers a specific types and its scoped instantiating factory.
    func register<T>(_ type: T.Type = T.self, scope: ResolverScope, factory: @escaping FactoryClosure<T>) {
        registry[key(for: T.self)] = .init(scope: scope, factory: factory)
    }

    /// Resolves and returns an instance of the given type from the current registry.
    func resolve<T>(_ type: T.Type = T.self) -> T {
        let key = key(for: T.self)
        
        guard let instance = registry[key]?.resolve(for: key) as? T else {
            fatalError("Dependency '\(T.self)' not resolved!")
        }
        
        return instance
    }
    
    func key(for type: T.Type) -> String {
        String(describing: T.self)
    }
}

// MARK: Subtypes

private extension Resolver {
    typealias FactoryClosure<T> = () -> T?

    class Registration<T> {
        private let scope: ResolverScope
        let factory: FactoryClosure<T>

        init(scope: ResolverScope, factory: @escaping FactoryClosure<T>) {
            self.scope = scope
            self.factory = factory
        }
        
        func resolve(for key: String) -> T? {
            scope.resolve(factory, for: key)
        }
    }
}

// MARK: Scopes

/// Resolver scopes exist to control when resolution occurs and how resolved instances are cached.
private protocol ResolverScope: class {
    func resolve<T>(_ factory: Resolver.FactoryClosure<T>, for key: String) -> T?
}

private extension Resolver {
    
    /// All application scoped types exist for lifetime of the app (singletons).
    class ApplicationScope: ResolverScope {
        private let queue = DispatchQueue(label: "Resolver.ApplicationScope")
        private var cached = [String: Any]()

        func resolve<T>(_ factory: FactoryClosure<T>, for key: String) -> T? {
            guard let element = cached[key] else {
                guard let resolved = factory() else { return nil }
                queue.sync { cached[key] = resolved }
                return resolved
            }
            
            return element as? T
        }
    }

    /// Unique type are created and initialized each and every time they are resolved.
    class UniqueScope: ResolverScope {
        
        fileprivate func resolve<T>(_ factory: FactoryClosure<T>, for key: String) -> T? {
            factory()
        }
    }
}

// MARK: Public API

/// Resolves an instance from the dependency injection container.
@propertyWrapper
public struct Inject<Value> {
    
    public var wrappedValue: Value {
        Resolver.root.resolve(Value.self)
    }

    public init() {}
    
    public init(module: Module) {
        module.resolve()
    }
}

/// A space to declare dependency instances.
public protocol Module {}
public extension Module {
    
    func single<T>(resolved object: @escaping () -> T) {
        Resolver.root.register(scope: Resolver.root.applicationScope, factory: object)
    }
    
    func factory<T>(resolved object: @escaping () -> T) {
        Resolver.root.register(scope: Resolver.root.uniqueScope, factory: object)
    }
    
    func resolve<T>(_ type: T.Type = T.self) -> T {
        Resolver.root.resolve()
    }
}
