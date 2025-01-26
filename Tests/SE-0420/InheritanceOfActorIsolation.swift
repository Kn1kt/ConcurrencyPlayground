//
//  InheritanceOfActorIsolation.swift
//  ConcurrencyPlaygroundTests
//
//  Created by Nikita Konashenko on 19.01.2025.
//

import Testing

/// [SE-0420: Inheritance of actor isolation ](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0420-inheritance-of-actor-isolation.md)
struct InheritanceOfActorIsolation {
    @SpecificGlobalActor
    private let counter = Counter()
    
    init() {}
    
    @Test
    @SpecificGlobalActor
    func specificActorIsolation() async throws {
        // Allowed.
        await counter.incrementAndSleep()
        
#if swift(<0)
        // ERROR: Sending 'self.counter' risks causing data races.
        await counter.incrementAndSleep(isolation: SpecificGlobalActor())
        
        // ERROR: Sending 'self.counter' risks causing data races.
        await counter.incrementAndSleep(isolation: MainActor.shared)
        
        // ERROR: Sending 'self.counter' risks causing data races.
        await counter.incrementAndSleep(isolation: nil)
#endif
    }
    
    @Test
    func mainActorIsolation() async throws {
        @MainActor
        func testMainActor(counter: Counter) async {
            // Allowed.
            await counter.incrementAndSleep()
            
#if swift(<0)
            // ERROR: Sending 'counter' risks causing data races.
            await counter.incrementAndSleep(isolation: nil)
#endif
        }
        
        let count = Counter()
        await testMainActor(counter: count)
    }
    
    @Test
    func nonIsolated() async throws {
        func testNonIsolated(counter: Counter) async {
            // Allowed.
            await counter.incrementAndSleep()
            
#if swift(<0)
            // ERROR: Sending 'counter' risks causing data races.
            await counter.incrementAndSleep(isolation: MainActor.shared)
#endif
        }
    }
}

// MARK: - Test Data

@globalActor
actor SpecificGlobalActor {
    static let shared: some Actor = SpecificGlobalActor()
}

extension InheritanceOfActorIsolation {
    /// This class type is not Sendable.
    class Counter {
        var count = 0
        
        /// Since this is an async function, if it were just declared
        /// non-isolated, calling it from an isolated context would be
        /// forbidden because it requires sharing a non-Sendable value
        /// between concurrency domains.  Inheriting isolation makes it
        /// okay. This is a contrived example chosen for its simplicity.
        func incrementAndSleep(isolation: isolated (any Actor)? = #isolation) async {
            count += 1
            await withCheckedContinuation { continuation in
                continuation.resume()
            }
        }
    }
}
