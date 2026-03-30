import Foundation

/// Merkezi debug logger. Sadece DEBUG modunda konsola yazdırır.
/// Release/Production build'lerde hiçbir çıktı üretmez.
enum DebugLog {
    nonisolated static func log(_ message: @autoclosure () -> String, file: String = #file, line: Int = #line) {
        #if DEBUG
        let filename = (file as NSString).lastPathComponent
        print("[\(filename):\(line)] \(message())")
        #endif
    }
    
    nonisolated static func error(_ message: @autoclosure () -> String, file: String = #file, line: Int = #line) {
        #if DEBUG
        let filename = (file as NSString).lastPathComponent
        print("❌ [\(filename):\(line)] \(message())")
        #endif
    }
    
    nonisolated static func warning(_ message: @autoclosure () -> String, file: String = #file, line: Int = #line) {
        #if DEBUG
        let filename = (file as NSString).lastPathComponent
        print("⚠️ [\(filename):\(line)] \(message())")
        #endif
    }
    
    nonisolated static func success(_ message: @autoclosure () -> String, file: String = #file, line: Int = #line) {
        #if DEBUG
        let filename = (file as NSString).lastPathComponent
        print("✅ [\(filename):\(line)] \(message())")
        #endif
    }
}
