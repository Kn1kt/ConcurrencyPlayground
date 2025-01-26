//
//  UsabilityOfGlobalActorIsolatedTypes.swift
//  ConcurrencyPlaygroundTests
//
//  Created by Nikita Konashenko on 26.01.2025.
//

import Testing

struct UsabilityOfGlobalActorIsolatedTypes {
    @Test
    func globalActorIsolatedValueTypes() async throws {
        @MainActor
        struct Point: Equatable {
            let x: Int = .zero
            var y: Int = .zero
            
            nonisolated static func == (lhs: Self, rhs: Self) -> Bool {
                return lhs.x == rhs.x
                // Swift 5
                // ERROR:
                && lhs.y == rhs.y
            }
        }
    }
    
    @Test
    func globallyIsolatedSendableClosure() async throws {
        func test(globallyIsolated: @escaping @MainActor () -> Void) {
            Task {
                // Swift 5
                // ERROR: capture of `globallyIsolated` with non-sendable type `@MainActor () -> Void` in a `@Sendable` closure.
                await globallyIsolated()
            }
        }
    }
    
    @Test
    func globallyIsolatedSendableClosureWithNonSendable() async throws {
        let ns = NonSendable()
        
        let closure = { @MainActor in
            print(ns)
        }
        
        Task {
            await closure() // Okay.
        }
    }
    
    @Test
    func nonSendableInheritance() async throws {
        // ERROR: main actor-isolated class `Subclass` has different actor isolation from nonisolated superclass `NonSendable`.
        @MainActor
        class Subclass: NonSendable {}
    }
}

// MARK: Test Data

extension UsabilityOfGlobalActorIsolatedTypes {
    class NonSendable {}
}
