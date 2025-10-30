// NetworkCapture.swift
// Capture all network requests like React Native

import Foundation

public class NetworkCapture {
    
    public static func swizzleURLSession() {
        // Swizzle URLSession to capture all network requests
        let originalClass = URLSession.self
        
        // Swizzle dataTask
        if let originalMethod = class_getInstanceMethod(originalClass, #selector(URLSession.dataTask(with:completionHandler:) as (URLSession) -> (URLRequest, @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask)),
           let swizzledMethod = class_getInstanceMethod(originalClass, #selector(URLSession.swifmetro_dataTask(with:completionHandler:))) {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
}

extension URLSession {
    @objc func swifmetro_dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let startTime = Date()
        let requestId = UUID().uuidString.prefix(8)
        
        // Log request
        console.group("🌐 Network Request [\(requestId)]")
        console.log("➡️ \(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? "unknown")")
        
        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            console.log("📋 Headers: \(headers)")
        }
        
        if let body = request.httpBody {
            if let bodyString = String(data: body, encoding: .utf8) {
                console.log("📦 Body: \(bodyString.prefix(500))")
            }
        }
        console.groupEnd()
        
        // Call original method
        return self.swifmetro_dataTask(with: request) { data, response, error in
            let duration = Date().timeIntervalSince(startTime) * 1000
            
            // Log response
            console.group("🌐 Network Response [\(requestId)]")
            
            if let error = error {
                console.error("❌ Failed after \(String(format: "%.0f", duration))ms")
                console.error("Error: \(error.localizedDescription)")
            } else if let httpResponse = response as? HTTPURLResponse {
                let status = httpResponse.statusCode
                let emoji = (200...299).contains(status) ? "✅" : status >= 400 ? "❌" : "⚠️"
                console.log("\(emoji) Status: \(status) in \(String(format: "%.0f", duration))ms")
                
                // Log response headers
                if !httpResponse.allHeaderFields.isEmpty {
                    console.log("📋 Response Headers: \(httpResponse.allHeaderFields)")
                }
                
                // Log response body
                if let data = data {
                    if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                        console.log("📦 Response (JSON): \(json)")
                    } else if let text = String(data: data, encoding: .utf8) {
                        console.log("📦 Response: \(text.prefix(500))")
                    } else {
                        console.log("📦 Response: \(data.count) bytes")
                    }
                }
            }
            
            console.groupEnd()
            completionHandler(data, response, error)
        }
    }
}

// Capture URLSession delegate methods
public class URLSessionCapture: NSObject {
    
    public static func captureMetrics() {
        // Listen for URLSession task metrics
        // Note: NSURLSessionTaskDidCompleteWithError is not available in Swift
        // We capture metrics through method swizzling instead
        console.log("📊 Network metrics captured via URLSession swizzling")
    }
}