import Foundation

/// Stream control for pause/resume and bookmarking functionality
public class StreamControl {
    
    private static var isPaused = false
    private static var pausedLogs = [String]()
    private static var bookmarkedLogs = Set<String>()
    private static var pinnedLogs = [PinnedLog]()
    
    public struct PinnedLog {
        let timestamp: Date
        let message: String
        let id: String
        let note: String?
        
        init(message: String, note: String? = nil) {
            self.timestamp = Date()
            self.message = message
            self.id = UUID().uuidString
            self.note = note
        }
    }
    
    // MARK: - Pause/Resume Control
    
    /// Pause the log stream (logs continue buffering)
    public static func pauseStream() {
        isPaused = true
        SwifMetroClient.shared.captureLog("⏸️ [SwifMetro] Stream paused - logs buffering in background")
    }
    
    /// Resume the log stream (flush buffered logs)
    public static func resumeStream() {
        if isPaused {
            isPaused = false
            
            // Flush buffered logs
            let bufferedCount = pausedLogs.count
            for log in pausedLogs {
                SwifMetroClient.shared.captureLog(log)
            }
            pausedLogs.removeAll()
            
            SwifMetroClient.shared.captureLog("▶️ [SwifMetro] Stream resumed - flushed \(bufferedCount) buffered logs")
        }
    }
    
    /// Check if stream is paused
    public static func isStreamPaused() -> Bool {
        return isPaused
    }
    
    /// Capture log (respects pause state)
    public static func captureLog(_ message: String) {
        if isPaused {
            // Buffer the log while paused
            pausedLogs.append(message)
        } else {
            // Send immediately
            SwifMetroClient.shared.captureLog(message)
        }
    }
    
    // MARK: - Bookmarking & Pinning
    
    /// Bookmark a log message for later reference
    public static func bookmarkLog(_ message: String) {
        bookmarkedLogs.insert(message)
        SwifMetroClient.shared.captureLog("🔖 [Bookmarked] \(message)")
    }
    
    /// Pin a log with optional note
    public static func pinLog(_ message: String, note: String? = nil) {
        let pinned = PinnedLog(message: message, note: note)
        pinnedLogs.append(pinned)
        
        if let note = note {
            SwifMetroClient.shared.captureLog("📌 [Pinned] \(message) | Note: \(note)")
        } else {
            SwifMetroClient.shared.captureLog("📌 [Pinned] \(message)")
        }
    }
    
    /// Get all pinned logs
    public static func getPinnedLogs() -> [PinnedLog] {
        return pinnedLogs
    }
    
    /// Get all bookmarked logs
    public static func getBookmarkedLogs() -> Set<String> {
        return bookmarkedLogs
    }
    
    /// Clear all bookmarks
    public static func clearBookmarks() {
        bookmarkedLogs.removeAll()
        SwifMetroClient.shared.captureLog("🧹 [SwifMetro] Bookmarks cleared")
    }
    
    /// Clear all pins
    public static func clearPins() {
        pinnedLogs.removeAll()
        SwifMetroClient.shared.captureLog("🧹 [SwifMetro] Pins cleared")
    }
    
    // MARK: - Session Markers
    
    /// Add a session marker (visual separator in logs)
    public static func addSessionMarker(_ label: String? = nil) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        let marker = label ?? "Session Marker"
        
        SwifMetroClient.shared.captureLog("""
            
            ════════════════════════════════════════════════════════════
            📍 \(marker) - \(timestamp)
            ════════════════════════════════════════════════════════════
            
            """)
    }
    
    /// Mark a checkpoint in debugging
    public static func checkpoint(_ name: String) {
        SwifMetroClient.shared.captureLog("""
            
            ┌─────────────────────────────────────┐
            │ ✅ CHECKPOINT: \(name)
            └─────────────────────────────────────┘
            
            """)
    }
}

// MARK: - Public API Extensions

public extension SwifMetroClient {
    
    /// Pause log streaming (continues buffering)
    func pauseStream() {
        StreamControl.pauseStream()
    }
    
    /// Resume log streaming (flushes buffer)
    func resumeStream() {
        StreamControl.resumeStream()
    }
    
    /// Pin important log for later
    func pinLog(_ message: String, note: String? = nil) {
        StreamControl.pinLog(message, note: note)
    }
    
    /// Add visual checkpoint marker
    func checkpoint(_ name: String) {
        StreamControl.checkpoint(name)
    }
}