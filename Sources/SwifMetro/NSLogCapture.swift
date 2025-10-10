// NSLogCapture.swift
// Revolutionary technique to capture ALL logs on iOS

import Foundation
import Darwin

// MARK: - The Magic: Override NSLog globally

// This is the KEY - we override NSLog at the symbol level
@_silgen_name("NSLog")
public func NSLog_SwifMetro(_ format: NSString, _ args: CVarArg...) {
    // Format the message
    let message = String(format: format as String, arguments: args)
    
    // Send to SwifMetro
    SwifMetroClient.shared.captureLog("📝 [NSLog] \(message)")
    
    // Also write to stderr so it appears in Xcode console
    withVaList(args) { vaList in
        NSLogv(format, vaList)
    }
}

// MARK: - Capture stderr where NSLog writes on macOS (not iOS)

public class StderrCapture {
    private static var pipe: [Int32] = [0, 0]
    private static var originalStderr: Int32 = 0
    
    public static func start() {
        // Create pipe
        Darwin.pipe(&pipe)
        
        // Save original stderr
        originalStderr = dup(STDERR_FILENO)
        
        // Redirect stderr to our pipe
        dup2(pipe[1], STDERR_FILENO)
        
        // Make read end non-blocking
        fcntl(pipe[0], F_SETFL, O_NONBLOCK)
        
        // Start reading
        DispatchQueue.global(qos: .background).async {
            let bufferSize = 1024
            var buffer = [CChar](repeating: 0, count: bufferSize)
            
            while true {
                let bytesRead = read(pipe[0], &buffer, bufferSize - 1)
                if bytesRead > 0 {
                    buffer[bytesRead] = 0
                    
                    // Write to original stderr
                    write(originalStderr, buffer, bytesRead)
                    
                    // Send to SwifMetro if it looks like NSLog
                    if let str = String(cString: buffer, encoding: .utf8) {
                        processStderr(str)
                    }
                }
                usleep(1000)
            }
        }
    }
    
    private static func processStderr(_ output: String) {
        // Parse NSLog format: "2025-10-10 13:45:23.456 AppName[12345:67890] Message"
        let lines = output.components(separatedBy: "\n")
        for line in lines where !line.isEmpty {
            // Check if it's NSLog format
            if line.contains("[") && line.contains("]") {
                if let bracketStart = line.firstIndex(of: "]") {
                    let messageIndex = line.index(after: bracketStart)
                    if messageIndex < line.endIndex {
                        let message = String(line[messageIndex...]).trimmingCharacters(in: .whitespaces)
                        if !message.isEmpty && !message.contains("SwifMetro") {
                            SwifMetroClient.shared.captureLog("📝 [NSLog] \(message)")
                        }
                    }
                }
            }
        }
    }
}