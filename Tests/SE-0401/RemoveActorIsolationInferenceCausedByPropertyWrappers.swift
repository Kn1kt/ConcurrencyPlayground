//
//  RemoveActorIsolationInferenceCausedByPropertyWrappers.swift
//  ConcurrencyPlaygroundTests
//
//  Created by Nikita Konashenko on 12.01.2025.
//

import Testing

/// [SE-0401: Remove Actor Isolation Inference caused by Property Wrappers ](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0401-remove-property-wrapper-isolation.md)
struct RemoveActorIsolationInferenceCausedByPropertyWrappers {
#if swift(<6)
    @Test
    @DatabaseActor
    func fetchOrdersFromDatabase() async throws {
        let connection = DBConnection()
        
        // No 'await' needed here, because 'connection' is also isolated to `DatabaseActor`.
        let result = connection.executeQuery("...")
        
        #expect(result == "Result...")
    }
#else
    @Test
    func fetchOrdersFromDatabase() async throws {
        let connection = DBConnection()
        
        // No 'await' needed here, because 'connection' is non-isolated.
        let result = connection.executeQuery("...")
        
        #expect(result == "Result...")
    }
#endif
}

// MARK: - Test Data

extension RemoveActorIsolationInferenceCausedByPropertyWrappers {
    @globalActor
    actor DatabaseActor {
        static let shared = DatabaseActor()
    }
    
    // A property wrapper for use with our database library.
    @propertyWrapper
    struct DBParameter<T> {
        @DatabaseActor
        public var wrappedValue: T
        
        @DatabaseActor // At some reason this `init` doesn't work without `@DatabaseActor`.
        init(wrappedValue: sending T) {
            self.wrappedValue = wrappedValue
        }
        
        nonisolated init(wrappedValue: T) where T: Sendable {
            self.wrappedValue = wrappedValue
        }
    }
    
    // Swift 5
    // Inferred `@DatabaseActor` isolation because of use of `@DBParameter`.
    struct DBConnection {
        @DBParameter private var connectionID: Int = .zero
        
        func executeQuery(_ query: String) -> String {
            return "Result" + query
        }
    }
}
