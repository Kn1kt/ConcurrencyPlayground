//
//  RegionBasedIsolation.swift
//  ConcurrencyPlaygroundTests
//
//  Created by Nikita Konashenko on 18.01.2025.
//

import Testing

/// [SE-0414: Region based Isolation](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0414-region-based-isolation.md)
struct RegionBasedIsolation {
#if swift(>=6)
    @Test
    func sendingToActorIsolated() async throws {
        @MainActor
        func storeClient(_ client: NonSendableClient) {}
        
        func openNewAccount(name: String) async -> NonSendableClient {
            let client = NonSendableClient(name: name)
            
            // Swift 5
            // ERROR: `Client` is non-`Sendable`.
            await storeClient(client)
            
            // Uncomment next line to check the region based isolation.
            // return client
            
            return NonSendableClient(name: name)
        }
        
        let storedClient = await openNewAccount(name: "Alice")
        #expect(storedClient.name == "Alice")
    }
    
    @Test
    func sendingToNonIsolated() async throws {
        func storeClient(_ c: NonSendableClient) async {}
        
        func openNewAccount(name: String) async -> NonSendableClient {
            let client = NonSendableClient(name: name)
            
            // Swift 5
            // ERROR: `Client` is non-`Sendable`.
            await storeClient(client)
            
            // Safe to pass client away.
            return client
        }
        
        let storedClient = await openNewAccount(name: "Alice")
        #expect(storedClient.name == "Alice")
    }
#endif
}

// MARK: - Test Data

extension RegionBasedIsolation {
    // Not Sendable.
    class NonSendableClient {
        let name: String
        
        init(name: String) {
            self.name = name
        }
    }
}
