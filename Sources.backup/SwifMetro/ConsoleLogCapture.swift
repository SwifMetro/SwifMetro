// ConsoleLogCapture.swift
// Capture console-like logs on iOS (OSLogStore is macOS only)

import Foundation
import os.log

// iOS doesn't have OSLogStore API, so we use alternative approaches
public class ConsoleLogCapture {
    private static var isCapturing = false
    
    public static func startCapturing() {
        guard !isCapturing else { return }
        isCapturing = true
        
        print("🔍 SwifMetro: Console capture active (via stdout/stderr interception)")
        
        // On iOS, we already capture console output through:
        // 1. stdout/stderr redirection (SwifMetroInterceptor)
        // 2. NSLog interception (LogHooks)
        // 3. os_log capture (setupOSLogCapture)
        // This is just a placeholder for future iOS console capture methods
    }
    
    public static func stopCapturing() {
        isCapturing = false
    }
}

// For iOS 14 and below, use simpler approach
public class LegacyConsoleCapture {
    private static var isCapturing = false
    
    public static func startCapturing() {
        guard !isCapturing else { return }
        isCapturing = true
        
        print("🔍 SwifMetro: Starting legacy console capture...")
        
        // We already capture NSLog and os_log through other methods
        // This is just a placeholder for iOS 14 and below
    }
    
    public static func stopCapturing() {
        isCapturing = false
    }
}

// Convenience wrapper
public class SystemConsoleCapture {
    public static func start() {
        if #available(iOS 15.0, *) {
            ConsoleLogCapture.startCapturing()
        } else {
            LegacyConsoleCapture.startCapturing()
        }
    }
    
    public static func stop() {
        if #available(iOS 15.0, *) {
            ConsoleLogCapture.stopCapturing()
        } else {
            LegacyConsoleCapture.stopCapturing()
        }
    }
}