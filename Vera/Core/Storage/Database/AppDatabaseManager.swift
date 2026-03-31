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
        let currentDBVersion = 15 // Increase this to force a database refresh for all users
        let dbVersionKey = "VeraDatabaseVersion_ReligiousGuides"
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
    
    private var connection: DBConnection
    var db: OpaquePointer? { connection.pointer }
    
    /// Internal initializer for singleton creation.
    private init(connection: DBConnection) {
        self.connection = connection
        ensureSchema()
    }
    
    private func ensureSchema() {
        let sql = """
        CREATE TABLE IF NOT EXISTS daily_progress (
            id TEXT PRIMARY KEY,
            task_id TEXT NOT NULL,
            date TEXT NOT NULL,
            is_completed INTEGER DEFAULT 0,
            value INTEGER DEFAULT 0
        );
        """
        _ = DatabaseHelper.execute(db, sql: sql, bindings: nil)
    }

    /// Resets the database by closing the connection, deleting the file, and re-copying it from the bundle.
    func reset() async {
        // 1. Close current connection
        if let db = connection.pointer {
            sqlite3_close(db)
        }
        
        // 2. Delete and re-copy file
        AppDatabaseManager.resetDatabaseFile()
        
        // 3. Re-open connection
        self.connection = DBConnection(pointer: AppDatabaseManager.openDatabaseConnection())
        
        // 4. Ensure schema is applied to the fresh database
        ensureSchema()
        
        DebugLog.success("Database has been successfully reset to factory defaults.")
    }
    
    private static func resetDatabaseFile() {
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let dbURL = documentsURL.appendingPathComponent("vera.sqlite")
        
        if fileManager.fileExists(atPath: dbURL.path) {
            try? fileManager.removeItem(at: dbURL)
            DebugLog.log("Resetting: Existing database file removed.")
        }
    }

    deinit {
        if let db = connection.pointer {
            sqlite3_close(db)
        }
    }
}
