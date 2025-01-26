//
//  CustomIsolationCheckingForSerialExecutor.swift
//  ConcurrencyPlaygroundTests
//
//  Created by Nikita Konashenko on 21.01.2025.
//

import Testing
import Dispatch

/// [SE-0424: Custom isolation checking for SerialExecutor](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0424-custom-isolation-checking-for-serialexecutor.md)
struct CustomIsolationCheckingForSerialExecutor {
    @Test
    func customIsolationCheckingForSerialExecutor() async throws {
        actor Caplin {
            var number: Int = .zero // Actor isolated state.
            
            nonisolated var unownedExecutor: UnownedSerialExecutor {
                // Use the queue as this actor's `SerialExecutor`.
                queue.asUnownedSerialExecutor()
            }
            
            private let queue: DispatchSerialQueue = .init(label: "Caplin.default", target: .global())
            
            nonisolated func connect() {
                queue.async {
                    // Guaranteed to execute on queue which is the same as self's serial executor.
                    
                    // SwiftStdlib 5
                    // CRASH: Incorrect actor executor assumption.
                    self.queue.assertIsolated()
                    
                    // SwiftStdlib 5
                    // CRASH: Incorrect actor executor assumption.
                    self.assumeIsolated { caplin in
                        caplin.number += 1
                    }
                }
            }
        }
        
        let actor = Caplin()
        actor.connect()
        
        #expect(await actor.number == 1)
    }
}
