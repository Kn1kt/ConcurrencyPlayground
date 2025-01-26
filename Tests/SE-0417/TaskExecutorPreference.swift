//
//  TaskExecutorPreference.swift
//  ConcurrencyPlaygroundTests
//
//  Created by Nikita Konashenko on 18.01.2025.
//

import Testing
import Dispatch

/// [SE-0417: Task Executor Preference](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0417-task-executor-preference.md)
struct TaskExecutorPreference {
    @Test
    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    func taskExecutorPreference() async throws {
        let executor = SpecificTaskExecutor()
        
        await Task(executorPreference: executor) {
            // Starts and runs on the `executor`.
            await nonisolatedAsyncFunc()
            
            executor.checkIsolated()
        }.value
        
        await Task.detached(executorPreference: executor) {
            // Starts and runs on the `executor`.
            await nonisolatedAsyncFunc()
            
            executor.checkIsolated()
        }.value
        
        await withDiscardingTaskGroup { group in
            group.addTask(executorPreference: executor) {
                // Starts and runs on the `executor`.
                await nonisolatedAsyncFunc()
                
                executor.checkIsolated()
            }
        }
    }
    
    @Test
    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    func taskGlobalConcurrentExecutorPreference() async throws {
        let globalConcurrentExecutor = globalConcurrentExecutor.asUnownedTaskExecutor()
        
        await Task {
            // Starts and runs on the `globalConcurrentExecutor`.
            await nonisolatedAsyncFunc()
            
            #expect(withUnsafeCurrentTask { $0!.unownedTaskExecutor == globalConcurrentExecutor })
        }.value
        
        await Task.detached {
            // Starts and runs on the `globalConcurrentExecutor`.
            await nonisolatedAsyncFunc()
            
            #expect(withUnsafeCurrentTask { $0!.unownedTaskExecutor == globalConcurrentExecutor })
        }.value
        
        await withDiscardingTaskGroup { group in
            group.addTask {
                // Starts and runs on the `globalConcurrentExecutor`.
                await nonisolatedAsyncFunc()
                
                #expect(withUnsafeCurrentTask { $0!.unownedTaskExecutor == globalConcurrentExecutor })
            }
        }
    }
}

// MARK: - Test Data

extension TaskExecutorPreference {
    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    final class SpecificTaskExecutor: TaskExecutor, SerialExecutor {
        private let queue = DispatchSerialQueue(label: "SpecificTaskExecutor.default", target: .global())
        
        func checkIsolated() {
            dispatchPrecondition(condition: .onQueue(queue))
        }
        
        func enqueue(_ job: consuming ExecutorJob) {
            let taskExecutor = asUnownedTaskExecutor()
            let serialExecutor = queue.asUnownedSerialExecutor()
            let unownedJob = UnownedJob(job)
            
            queue.async {
                unownedJob.runSynchronously(isolatedTo: serialExecutor, taskExecutor: taskExecutor)
            }
        }
    }
    
    func nonisolatedAsyncFunc() async {
        // If the Task has a specific executor preference,
        // runs on that ‘executor’ rather than on the default global concurrent executor.
    }
}
