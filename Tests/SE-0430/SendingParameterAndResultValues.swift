//
//  SendingParameterAndResultValues.swift
//  ConcurrencyPlaygroundTests
//
//  Created by Nikita Konashenko on 22.01.2025.
//

import Testing
import Foundation

/// [SE-0430: `sending` parameter and result values ](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0430-transferring-parameters-and-results.md)
final class SendingParameterAndResultValues {
    @MainActor
    private var mainActorCounter: NonSendableCounter?
    
    init() {}
    
#if swift(<6)
    @Test
    func concurrentAccessProblem() async throws {
        let nonIsolatedCounter = await withCheckedContinuation { continuation in
            Task { @MainActor in
                let nonIsolatedCounter = NonSendableCounter()
                
                // Save `nonIsolatedCounter` to main actor state for concurrent access later on.
                mainActorCounter = nonIsolatedCounter
                
                // `NonSendable` is passed from the main actor to a nonisolated context.
                continuation.resume(returning: nonIsolatedCounter)
            }
        }
        
        Task { @MainActor in
            // Uncomment this line and run test repeatedly to get crash.
            mainActorCounter!.count()
        }
        
        // `nonIsolatedCounter` and `mainActorCounter` are now the same non-Sendable value.
        // Concurrent access is possible!
        nonIsolatedCounter.count()
        
        let counts = await mainActorCounter?.counter
        #expect(counts == 2)
    }
#else
    @Test
    func sendingParameters() async throws {
        @MainActor
        func acceptSend(_ counter: sending NonSendableCounter) {
            counter.count()
        }
        
        let counter = NonSendableCounter()
        
        // ERROR: sending `counter` may cause a race.
        // Note: `counter` is passed as a `sending` parameter to `acceptSend`.
        // Local uses could race with later uses in `acceptSend`.
        await acceptSend(counter)
        
        // Note: access here could race.
        // Uncomment next line, to get an error above.
//        #expect(counter.counter == 1)
    }
    
    @Test
    func sendingResultValues() async throws {
        func makeNonSendable() async -> sending NonSendableCounter {
            let counter = NonSendableCounter()
            counter.count()
            
            // ERROR: Value of non-Sendable type accessed after being transferred; later accesses could race.
            // Uncomment next line, to get an error.
//            Task { counter.count() }
            
            return counter
        }
        
        let counter = await makeNonSendable()
        counter.count()
        
        #expect(counter.counter == 2)
    }
    
    @Test
    func sendingAPIs() async throws {
        let counter = await withCheckedContinuation {
            $0.resume(returning: NonSendableCounter())
        }
        let counter2 = await withUnsafeContinuation {
            $0.resume(returning: NonSendableCounter())
        }
        
        await Task { counter.count() }.value
        await Task.detached { counter2.count() }.value
        
        let (stream, continuation) = AsyncStream<NonSendableCounter>.makeStream()
        continuation.yield(NonSendableCounter())
        let counter3 = await stream.first { _ in true }
        
        #expect(counter3?.counter == 0)
    }
#endif
}

// MARK: - Test Data

extension SendingParameterAndResultValues {
    class NonSendableCounter {
        var counter: Int = 0
        
        // A simple way to simulate data race.
        private var nsObject = NSObject()
        
        func count() {
            counter += 1
            nsObject = NSObject()
        }
    }
}
