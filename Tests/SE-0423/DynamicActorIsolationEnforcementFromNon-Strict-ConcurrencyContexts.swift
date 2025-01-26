//
//  DynamicActorIsolationEnforcementFromNon-Strict-ConcurrencyContexts.swift
//  ConcurrencyPlaygroundTests
//
//  Created by Nikita Konashenko on 21.01.2025.
//

import Testing

struct DynamicActorIsolationEnforcementFromNonStrictConcurrencyContexts {
    @Test
    func dynamicActorIsolationEnforcementFromNonStrictConcurrencyContexts() async throws {
        @MainActor
        class MyViewController: @preconcurrency ViewDelegateProtocol {
            nonisolated init() {}
            
            // ERROR: @MainActor function cannot satisfy a nonisolated requirement.
            func respondToUIEvent() {
                // Implementation...
            }
        }
        
        let controller = MyViewController()
        
        // Compiler continue to emit diagnostics inside the module.
        // So await is required.
        await controller.respondToUIEvent()
    }
}

// MARK: - Test Data

extension DynamicActorIsolationEnforcementFromNonStrictConcurrencyContexts {
    protocol ViewDelegateProtocol {
        func respondToUIEvent()
    }
}
