# 🏖️ConcurrencyPlayground

A comprehensive test suite exploring the latest changes and improvements in Swift Concurrency, focusing on Swift 6 and newer Swift Evolution proposals.

## Overview

ConcurrencyPlayground is a collection of test cases demonstrating the implementation and usage of various Swift Evolution proposals related to concurrency. It serves as both a learning resource and a verification tool for understanding how different concurrency features work in Swift.

## Contents

The project contains implementation tests of the following Swift Evolution proposals:

- [SE-0401: Remove Actor Isolation Inference caused by Property Wrappers](https://github.com/Kn1kt/ConcurrencyPlayground/blob/6a3b946fe05ebbf25be2826975c1282e51e88198/Tests/SE-0401/RemoveActorIsolationInferenceCausedByPropertyWrappers.swift) - Demonstrates changes to property wrapper isolation rules.

- [SE-0411: Isolated default value expressions](https://github.com/Kn1kt/ConcurrencyPlayground/blob/6a3b946fe05ebbf25be2826975c1282e51e88198/Tests/SE-0411/IsolatedDefaultValueExpressions.swift) - Tests isolation rules for default values.

- [SE-0414: Region based Isolation](https://github.com/Kn1kt/ConcurrencyPlayground/blob/6a3b946fe05ebbf25be2826975c1282e51e88198/Tests/SE-0414/RegionBasedIsolation.swift) - Tests region-based actor isolation rules.

- [SE-0417: Task Executor Preference](https://github.com/Kn1kt/ConcurrencyPlayground/blob/6a3b946fe05ebbf25be2826975c1282e51e88198/Tests/SE-0417/TaskExecutorPreference.swift) - Shows task executor customization with preferences.

- [SE-0418: Inferring `Sendable` for methods and key path literals](https://github.com/Kn1kt/ConcurrencyPlayground/blob/6a3b946fe05ebbf25be2826975c1282e51e88198/Tests/SE-0418/InferringSendableForMethodsAndKeyPathLiterals.swift) - Tests automatic `Sendable` inference improvements.

- [SE-0420: Inheritance of actor isolation](https://github.com/Kn1kt/ConcurrencyPlayground/blob/6a3b946fe05ebbf25be2826975c1282e51e88198/Tests/SE-0420/InheritanceOfActorIsolation.swift) - Demonstrates dynamic actor isolation inheritance rules.

- [SE-0421: Generalize effect polymorphism for `AsyncSequence` and `AsyncIteratorProtocol`](https://github.com/Kn1kt/ConcurrencyPlayground/blob/6a3b946fe05ebbf25be2826975c1282e51e88198/Tests/SE-0421/GeneralizeEffectPolymorphismForAsyncSequenceAndAsyncIteratorProtocol.swift) - Tests `AsyncSequence` and `AsyncIteratorProtocol` improvements.

- [SE-0423: Dynamic actor isolation enforcement from non-strict-concurrency contexts](https://github.com/Kn1kt/ConcurrencyPlayground/blob/6a3b946fe05ebbf25be2826975c1282e51e88198/Tests/SE-0423/DynamicActorIsolationEnforcementFromNon-Strict-ConcurrencyContexts.swift) - Tests new usage of `@preconcurrency` attribute.

- [SE-0424: Custom isolation checking for SerialExecutor](https://github.com/Kn1kt/ConcurrencyPlayground/blob/6a3b946fe05ebbf25be2826975c1282e51e88198/Tests/SE-0424/CustomIsolationCheckingForSerialExecutor.swift) - Shows custom executor implementation with isolation checking.

- [SE-0430: `sending` parameter and result values](https://github.com/Kn1kt/ConcurrencyPlayground/blob/6a3b946fe05ebbf25be2826975c1282e51e88198/Tests/SE-0430/SendingParameterAndResultValues.swift) - Tests safe transfer of non-sendable values between actors.

- [SE-0431: `@isolated(any)` Function Types](https://github.com/Kn1kt/ConcurrencyPlayground/blob/6a3b946fe05ebbf25be2826975c1282e51e88198/Tests/SE-0431/IsolatedAnyFunctionTypes.swift) - Demonstrates new isolation parameter for closures.

- [SE-0434: Usability of global-actor-isolated types](https://github.com/Kn1kt/ConcurrencyPlayground/blob/6a3b946fe05ebbf25be2826975c1282e51e88198/Tests/SE-0434/UsabilityOfGlobalActorIsolatedTypes.swift) - Tests global actor isolation improvements for value types and closures.

Each test file contains detailed examples and edge cases for the corresponding proposal implementation. The test suite helps verify the behavior of these new concurrency features and serves as a learning resource for understanding Swift's evolving concurrency model.

## Usage

Clone the repository and open `Package.swift` in Xcode:

- Feel free to change `swiftLanguageModes` in `Package.swift` to Swift 5 and investigate language difference.

- Switch between targets with `iOS 17` and `iOS 18` to check different runtime behaviour.
