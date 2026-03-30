import Foundation
import SQLite3

/// A high-performance, actor-isolated database manager for the Vera application.
/// Strictly compliant with Swift 6 concurrency rules without invalid 'nonisolated' initializers.
actor AppDatabaseManager: DatabaseProvider {
    
    /// Wraps the non-Sendable OpaquePointer to allow safe initialization across isolation boundaries.
    private struct DBConnection: @unchecked Sendable {
        let pointer: OpaquePointer?
    }

    /// Internal function to safely open the SQLite database.
    private static func openDatabaseConnection() -> OpaquePointer? {
        let fileManager = FileManager.default
        let currentDBVersion = 14 // Increase this to force a database refresh for all users
        let dbVersionKey = "VeraDatabaseVersion_LibrarySteps"
        let savedVersion = UserDefaults.standard.integer(forKey: dbVersionKey)
        
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let dbURL = documentsURL.appendingPathComponent("vera.sqlite")
        let dbPath = dbURL.path
        
        // 1. Force Update if version is outdated
        if fileManager.fileExists(atPath: dbPath) && savedVersion < currentDBVersion {
            // Only remove if we have a bundle replacement available to avoid data loss without a backup
            if Bundle.main.url(forResource: "vera", withExtension: "sqlite") != nil {
                try? fileManager.removeItem(at: dbURL)
                DebugLog.log("DB Version upgrade (\(savedVersion) -> \(currentDBVersion)). Forcing database refresh...")
            }
        }
        
        // 2. Copy from bundle if not exists (either first time or after removal above)
        if !fileManager.fileExists(atPath: dbPath) {
            guard let bundleURL = Bundle.main.url(forResource: "vera", withExtension: "sqlite") else { 
                DebugLog.error("Could not find vera.sqlite in bundle.")
                return nil 
            }
            do {
                try fileManager.copyItem(at: bundleURL, to: dbURL)
                UserDefaults.standard.set(currentDBVersion, forKey: dbVersionKey)
                DebugLog.success("Database successfully updated to version \(currentDBVersion).")
            } catch {
                DebugLog.error("Failed to copy database: \(error.localizedDescription)")
            }
        }
        
        var db: OpaquePointer?
        if sqlite3_open(dbPath, &db) == SQLITE_OK {
            return db
        } else {
            if let db = db {
                let error = String(cString: sqlite3_errmsg(db))
                DebugLog.error("SQLite Open Error: \(error)")
                sqlite3_close(db)
            }
            return nil
        }
    }

    /// The singleton instance, accessible from any context in Swift 6 as it's a 'static let'.
    static let shared = AppDatabaseManager(connection: DBConnection(pointer: openDatabaseConnection()))
    
    private let connection: DBConnection
    var db: OpaquePointer? { connection.pointer }
    
    /// Internal initializer for singleton creation.
    private init(connection: DBConnection) {
        self.connection = connection
    }

    deinit {
        if let db = connection.pointer {
            sqlite3_close(db)
        }
    }
}
