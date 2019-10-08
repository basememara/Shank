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

/// A dependency collection that provides resolutions for object instances.
open class Dependencies {
    /// Stored object instance factories.
    private var modules = [String: Module]()
    private var instances = [String: Any]()
    
    /// Construct dependency resolutions.
    public init(@ModuleBuilder _ modules: () -> [Module]) {
        modules().forEach { add(module: $0) }
    }
    
    /// Construct dependency resolution.
    public init(@ModuleBuilder _ module: () -> Module) {
        add(module: module())
    }
    
    /// Assigns the current container to the composition root.
    open func build() {
        Self.root = self
    }
    
    fileprivate init() {}
    deinit { modules.removeAll() }
}

private extension Dependencies {
    /// Composition root container of dependencies.
    static var root = Dependencies()
    
    /// Registers a specific type and its instantiating factory.
    func add(module: Module) {
        modules[module.name] = module
    }

    /// Resolves through inference and returns an instance of the given type from the current default container.
    ///
    /// If the dependency is not found, an exception will occur.
    func resolve<T>(for name: String? = nil) -> T {
        let name = name ?? String(describing: T.self)
        // First, make sure the module is available
        guard let module = modules[name] else {
            fatalError("Module '\(T.self)' not found!")
        }

        // Second, resolve the module as a dependency. If the module was registered as a
        // prototype, return the resolved instance.
        // If the module was registered as a singleton, return the cached instance if it exists,
        // or the resolved one after storing it in the dependency resolver.
        let component: T = {
            guard let resolvedModule = module.resolve() as? T else {
                fatalError("Dependency '\(T.self)' not resolved!")
            }
            switch module.scope {
            case .prototype:
                return resolvedModule
            case .singleton:
                if let instance = instances[name] as? T {
                    return instance
                }
                instances[name] = resolvedModule
                return resolvedModule
            }
        }()

        return component
    }
}

// MARK: Public API

public extension Dependencies {
    
    /// DSL for declaring modules within the container dependency initializer.
    @_functionBuilder struct ModuleBuilder {
        public static func buildBlock(_ modules: Module...) -> [Module] { modules }
        public static func buildBlock(_ module: Module) -> Module { module }
    }
}

/// A type that contributes to the object graph.
public struct Module {
    fileprivate let name: String
    fileprivate let resolve: () -> Any
    fileprivate let scope: InjectionScope
    
    public init<T>(_ name: String? = nil, scope: InjectionScope = .prototype, _ resolve: @escaping () -> T) {
        self.name = name ?? String(describing: T.self)
        self.resolve = resolve
        self.scope = scope
    }
}

/// Resolves an instance from the dependency injection container.
@propertyWrapper
public final class Inject<Value> {
    private let name: String?
    private var value: Value?
    
    public var wrappedValue: Value {
        if let value = self.value {
            return value
        }
        let value: Value = Dependencies.root.resolve(for: name)
        self.value = value
        return value
    }
    
    public init() {
        self.name = nil
    }
    
    public init(_ name: String) {
        self.name = name
    }
}

public enum InjectionScope {
    case singleton
    case prototype
}
