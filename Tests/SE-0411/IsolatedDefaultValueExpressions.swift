//
//  IsolatedDefaultValueExpressions.swift
//  ConcurrencyPlaygroundTests
//
//  Created by Nikita Konashenko on 12.01.2025.
//

import Testing

/// [SE-0411: Isolated default value expressions](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0411-isolated-default-values.md)
struct IsolatedDefaultValueExpressions {
#if swift(>=6)
    @Test
    func defaultFunctionParameters() async throws {
        @MainActor class C {}
        @MainActor func f(c: C = C()) {} // Error in Swift 5.
        @MainActor func useFromMainActor() {
            f()
        }
    }
#endif
    
    @Test
    func defaultPropertyValues() async throws {
        @globalActor
        actor AnotherActor {
            static let shared: some Actor = AnotherActor()
        }
        
        @MainActor func requiresMainActor() -> Int { .zero }
        @AnotherActor func requiresAnotherActor() -> Int { .zero }
        
        final class Model {
            @MainActor var x1 = requiresMainActor()
            @AnotherActor var x2 = requiresAnotherActor()
            
#if swift(<6)
            nonisolated init() {} // No Error in Swift 5.
#else
            init() async {
                self.x1 = await requiresMainActor()
                self.x2 = await requiresAnotherActor()
            }
#endif
        }
        
        // Swift 5
        // WARNING: No 'async' operations occur within 'await' expression
        let _ = await Model()
    }
    
    @Test
    func memberwiseInitializers() async throws {
        class NonSendable {}
        
        @MainActor
        struct Model {
            var value: NonSendable = .init()
        }
        
        // Swift 5
        // WARNING: No 'async' operations occur within 'await' expression
        let _ = await Model(value: NonSendable())
        let _ = await Task { @MainActor in Model() }.value
    }
}
