// DebugTester.swift
// Comprehensive debugging test to verify SwifMetro captures EVERYTHING

import Foundation
import os.log

public class DebugTester {
    
    public static func testAllDebuggingScenarios() {
        console.group("🧪 TESTING ALL DEBUG SCENARIOS")
        
        // 1. Test normal debugging logs
        testNormalDebugging()
        
        // 2. Test error scenarios
        testErrorScenarios()
        
        // 3. Test performance debugging
        testPerformanceDebugging()
        
        // 4. Test memory debugging
        testMemoryDebugging()
        
        // 5. Test custom debug functions
        testCustomDebugFunctions()
        
        // 6. Test complex object logging
        testComplexObjectLogging()
        
        // 7. Test async/await debugging
        testAsyncDebugging()
        
        // 8. Test network debugging
        testNetworkDebugging()
        
        console.groupEnd()
    }
    
    // MARK: - Normal Debugging
    
    static func testNormalDebugging() {
        console.group("📝 Normal Debugging")
        
        // Different log levels
        print("This is a normal print statement")
        NSLog("This is an NSLog statement")
        os_log("This is an os_log statement")
        os_log(.debug, "Debug level log")
        os_log(.info, "Info level log")
        os_log(.error, "Error level log")
        
        // Console API
        console.log("Console.log message")
        console.info("Console.info message")
        console.warn("Console.warn message")
        console.error("Console.error message")
        console.debug("Console.debug message")
        
        // Custom debug helpers
        debugLog("This is a debug log with file/line info")
        bugLog("Found a bug here!")
        todoLog("Need to implement this feature")
        fixmeLog("This needs to be fixed")
        
        console.groupEnd()
    }
    
    // MARK: - Error Scenarios
    
    static func testErrorScenarios() {
        console.group("❌ Error Scenarios")
        
        // Test error catching
        do {
            try riskyOperation()
        } catch {
            console.error("Caught error: \(error)")
            bugLog("Error in risky operation: \(error.localizedDescription)")
        }
        
        // Test optional handling
        let optional: String? = nil
        if let value = optional {
            console.log("Optional has value: \(value)")
        } else {
            console.warn("Optional is nil - potential bug if not handled!")
            debugLog("Optional was nil at this point")
        }
        
        // Test guard statements
        guard let unwrapped = optional else {
            console.error("Guard statement failed - early return")
            debugLog("Guard failed for optional")
            console.groupEnd()
            return
        }
        
        console.groupEnd()
    }
    
    static func riskyOperation() throws {
        enum TestError: Error {
            case somethingWentWrong(reason: String)
        }
        
        console.warn("About to throw an error for testing...")
        throw TestError.somethingWentWrong(reason: "Testing error handling")
    }
    
    // MARK: - Performance Debugging
    
    static func testPerformanceDebugging() {
        console.group("⚡ Performance Debugging")
        
        // Time operations
        console.time("ExpensiveOperation")
        
        // Simulate expensive operation
        var result = 0
        for i in 0..<1000000 {
            result += i
        }
        
        console.timeEnd("ExpensiveOperation")
        
        // Log performance metrics
        debugLog("Operation result: \(result)")
        
        // Track multiple timers
        console.time("Timer1")
        console.time("Timer2")
        
        Thread.sleep(forTimeInterval: 0.1)
        console.timeEnd("Timer1")
        
        Thread.sleep(forTimeInterval: 0.2)
        console.timeEnd("Timer2")
        
        console.groupEnd()
    }
    
    // MARK: - Memory Debugging
    
    static func testMemoryDebugging() {
        console.group("💾 Memory Debugging")
        
        // Test memory logging
        let largeArray = Array(repeating: "Test", count: 10000)
        console.log("Created large array with \(largeArray.count) items")
        debugLog("Memory allocated for large array")
        
        // Test retain cycle detection
        class LeakyClass {
            var closure: (() -> Void)?
            
            init() {
                // This creates a retain cycle (intentionally for testing)
                closure = { [unowned self] in
                    console.warn("Potential retain cycle if not using weak/unowned!")
                    debugLog("LeakyClass instance: \(self)")
                }
            }
        }
        
        let leaky = LeakyClass()
        leaky.closure?()
        
        console.groupEnd()
    }
    
    // MARK: - Custom Debug Functions
    
    static func testCustomDebugFunctions() {
        console.group("🔧 Custom Debug Functions")
        
        // Use all custom debug functions
        debugLog("Debug message with automatic file/line tracking")
        bugLog("Bug detected in user flow")
        todoLog("Implement user preferences")
        fixmeLog("Fix animation glitch on rotation")
        
        // Test with different contexts
        for i in 0..<3 {
            debugLog("Loop iteration \(i)")
            
            if i == 1 {
                bugLog("Found issue at iteration \(i)")
            }
        }
        
        console.groupEnd()
    }
    
    // MARK: - Complex Object Logging
    
    static func testComplexObjectLogging() {
        console.group("📦 Complex Object Logging")
        
        // Log dictionary
        let userInfo: [String: Any] = [
            "id": 123,
            "name": "John Doe",
            "email": "john@example.com",
            "settings": [
                "darkMode": true,
                "notifications": false
            ]
        ]
        
        console.log("User Info Dictionary:")
        console.dir(userInfo)
        
        // Log array of objects
        let items = [
            ["id": 1, "name": "Item 1", "price": 9.99],
            ["id": 2, "name": "Item 2", "price": 19.99],
            ["id": 3, "name": "Item 3", "price": 29.99]
        ]
        
        console.log("Items Array:")
        console.table(items)
        
        // Log custom objects
        struct Product {
            let id: Int
            let name: String
            let price: Double
        }
        
        let products = [
            Product(id: 1, name: "iPhone", price: 999),
            Product(id: 2, name: "iPad", price: 799),
            Product(id: 3, name: "MacBook", price: 1999)
        ]
        
        console.log("Products:")
        products.forEach { product in
            debugLog("Product: \(product.name) - $\(product.price)")
        }
        
        console.groupEnd()
    }
    
    // MARK: - Async Debugging
    
    static func testAsyncDebugging() {
        console.group("🔄 Async/Await Debugging")
        
        Task {
            console.log("Starting async task...")
            console.time("AsyncOperation")
            
            do {
                let result = try await performAsyncOperation()
                console.log("Async result: \(result)")
                debugLog("Async operation completed successfully")
            } catch {
                console.error("Async error: \(error)")
                bugLog("Async operation failed: \(error)")
            }
            
            console.timeEnd("AsyncOperation")
        }
        
        console.groupEnd()
    }
    
    static func performAsyncOperation() async throws -> String {
        console.log("Inside async operation...")
        
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        console.log("Async operation completing...")
        return "Async Success!"
    }
    
    // MARK: - Network Debugging
    
    static func testNetworkDebugging() {
        console.group("🌐 Network Debugging")
        
        // Test network request logging
        console.log("Making test network request...")
        
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts/1") else {
            console.error("Invalid URL")
            bugLog("URL creation failed")
            console.groupEnd()
            return
        }
        
        console.time("NetworkRequest")
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            console.timeEnd("NetworkRequest")
            
            if let error = error {
                console.error("Network error: \(error)")
                bugLog("Network request failed: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                console.log("Response status: \(httpResponse.statusCode)")
                debugLog("Headers: \(httpResponse.allHeaderFields)")
            }
            
            if let data = data {
                console.log("Received \(data.count) bytes")
                
                if let json = try? JSONSerialization.jsonObject(with: data) {
                    console.log("Response JSON:")
                    console.dir(json)
                }
            }
        }
        
        task.resume()
        
        console.groupEnd()
    }
    
    // MARK: - Crash Simulation (Commented out for safety)
    
    static func testCrashScenarios() {
        console.group("💥 Crash Scenarios (Simulated)")
        
        // These are commented out to prevent actual crashes
        // Uncomment only when you want to test crash reporting
        
        /*
        // Force unwrap nil
        let nilValue: String? = nil
        let crashed = nilValue!  // This would crash
        
        // Array out of bounds
        let array = [1, 2, 3]
        let item = array[10]  // This would crash
        
        // Divide by zero
        let zero = 0
        let result = 10 / zero  // This would crash
        */
        
        console.warn("Crash scenarios are commented out for safety")
        console.log("Uncomment specific scenarios in code to test crash reporting")
        
        console.groupEnd()
    }
}