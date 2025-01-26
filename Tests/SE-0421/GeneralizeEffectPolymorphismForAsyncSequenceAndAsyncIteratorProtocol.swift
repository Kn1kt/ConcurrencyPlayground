//
//  GeneralizeEffectPolymorphismForAsyncSequenceAndAsyncIteratorProtocol.swift
//  ConcurrencyPlaygroundTests
//
//  Created by Nikita Konashenko on 20.01.2025.
//

import Testing

struct GeneralizeEffectPolymorphismForAsyncSequenceAndAsyncIteratorProtocol {
    @Test
    func notThrowingAsyncIterator() async throws {
        var iterator = NotThrowingAsyncIterator()
        let next = await iterator.next()
        
        #expect(next == .zero)
    }
    
    @Test
    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    func asyncSequenceAssociatedTypes() async throws {
        let sequence: some AsyncSequence<Int, Never> = AsyncStream { .zero }
        let next = await sequence.first { _ in true }
        
        #expect(next == .zero)
    }
    
    @Test
    func asyncSequence() async throws {
        class NonSendable {}
        
        @MainActor
        func iterate(over stream: AsyncStream<NonSendable>) async {
            // Swift 6 & SwiftStdlib 6
            // OK
            if #available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *) {
                for await element in stream {
                    _ = element
                }
            }
            
#if swift(>=6)
            // Swift 6 & SwiftStdlib 5
            // ERROR: Non-sendable type 'NonSendable?' returned by implicitly asynchronous call
            // to nonisolated function cannot cross actor boundary
            for await element in stream.map(UncheckedSendable.init) {
                _ = element
            }
#else
            // Swift 5 & Xcode 15
            // WARNING: Non-sendable type 'NonSendable?' returned by implicitly asynchronous call
            // to nonisolated function cannot cross actor boundary
            for await element in stream {
                _ = element
            }
#endif
        }
    }
}

// MARK: - Test Data

extension GeneralizeEffectPolymorphismForAsyncSequenceAndAsyncIteratorProtocol {
#if swift(<6)
    struct NotThrowingAsyncIterator: AsyncIteratorProtocol {
        mutating func next() async -> Int? {
            return .zero
        }
    }
#else
    struct NotThrowingAsyncIterator: AsyncIteratorProtocol {
        mutating func next() async throws(Never) -> Int? {
            return .zero
        }
    }
#endif
    
    struct UncheckedSendable<T>: @unchecked Sendable {
        let value: T
    }
}
