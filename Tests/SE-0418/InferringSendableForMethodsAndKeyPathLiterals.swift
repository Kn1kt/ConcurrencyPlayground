//
//  InferringSendableForMethodsAndKeyPathLiterals.swift
//  ConcurrencyPlaygroundTests
//
//  Created by Nikita Konashenko on 19.01.2025.
//

import Testing

struct InferringSendableForMethodsAndKeyPathLiterals {
    @Test
    func inferringSendableForMethods() async throws {
        struct SendableType: Sendable {
            func someMethod() {}
        }
        
        func test() {
            let value = SendableType()
            
            // Swift 5
            // WARNING: Converting non-sendable function value to '@Sendable () async -> Void' may introduce data races.
            let closure: @Sendable () -> Void = value.someMethod
            
            Task(operation: closure)
        }
    }
    
    @Test
    func inferringSendableForKeyPathLiterals() async throws {
        final class Info: Hashable {
            func hash(into hasher: inout Hasher) {}
            static func == (lhs: Info, rhs: Info) -> Bool { true }
        }
        
        struct Entry: Equatable {}
        
        struct User {
            subscript(info: Info) -> Entry { Entry() }
        }
        
        // Swift 5
        // WARNING: Cannot form key path that captures non-sendable type 'Info'.
        let entry: KeyPath<User, Entry> = \.[Info()]
        #expect(User()[keyPath: entry] == Entry())
        
#if swift(<6)
        // Swift 6
        // ERROR: Converting non-sendable function value to '@Sendable (User) -> Entry' may introduce data races.
        let sendableEntry: @Sendable (User) -> Entry = \.[Info()]
        #expect(sendableEntry(User()) == Entry())
#endif
    }
}
