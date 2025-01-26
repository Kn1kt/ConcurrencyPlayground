//
//  IsolatedAnyFunctionTypes.swift
//  ConcurrencyPlaygroundTests
//
//  Created by Nikita Konashenko on 26.01.2025.
//

import Testing
import os

/// [SE-0431: `@isolated(any)` Function Types ](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0431-isolated-any-functions.md)
struct IsolatedAnyFunctionTypes {
    @Test
    @MainActor
    func transitiveEventOrderingOnMainActor() async throws {
        var results = [String]()
        
        let task1 = Task {
            results.append("b")
        }
        let task2 = Task {
            results.append("c")
        }
        let task3 = Task {
            results.append("d")
        }
        
        results.append("a")
        
        _ = await [task3.value, task2.value, task1.value]
        
        #expect(results == ["a", "b", "c", "d"])
    }
    
    @Test
    func isolationParameter() async throws {
        func expectActor(_ expectedActor: any Actor, for operation: @isolated(any) @escaping () -> Void) {
            let isolation = operation.isolation
            #expect(isolation === expectedActor)
        }
        
        expectActor(MainActor.shared, for: { @MainActor in })
        
        await Task { @SpecificGlobalActor in
            expectActor(SpecificGlobalActor.shared, for: {})
        }.value
    }
}
