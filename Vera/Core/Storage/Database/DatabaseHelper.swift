import Foundation
import SQLite3

/// A helper struct to abstract common SQLite operations and reduce boilerplate.
struct DatabaseHelper {
    
    /// Prepares a statement and executes a block with it.
    nonisolated static func query<T>(_ db: OpaquePointer?, sql: String, bindings: ((OpaquePointer) -> Void)? = nil, transform: (OpaquePointer) -> T) -> [T] {
        var statement: OpaquePointer?
        var results = [T]()
        
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            bindings?(statement!)
            while sqlite3_step(statement) == SQLITE_ROW {
                results.append(transform(statement!))
            }
        } else {
            if let db = db {
                let error = String(cString: sqlite3_errmsg(db))
                DebugLog.error("SQLite Query Error: \(error) | SQL: \(sql)")
            }
        }
        sqlite3_finalize(statement)
        return results
    }
    
    /// Executes a single row query (e.g., LIMIT 1) and returns a single result.
    nonisolated static func queryRow<T>(_ db: OpaquePointer?, sql: String, bindings: ((OpaquePointer) -> Void)? = nil, transform: (OpaquePointer) -> T) -> T? {
        var statement: OpaquePointer?
        var result: T?
        
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            bindings?(statement!)
            if sqlite3_step(statement) == SQLITE_ROW {
                result = transform(statement!)
            }
        } else {
            if let db = db {
                let error = String(cString: sqlite3_errmsg(db))
                DebugLog.error("SQLite QueryRow Error: \(error) | SQL: \(sql)")
            }
        }
        sqlite3_finalize(statement)
        return result
    }
    
    /// Executes a non-query SQL (INSERT, UPDATE, DELETE).
    nonisolated static func execute(_ db: OpaquePointer?, sql: String, bindings: ((OpaquePointer) -> Void)?) -> Bool {
        var statement: OpaquePointer?
        var success = false
        
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            bindings?(statement!)
            if sqlite3_step(statement) == SQLITE_DONE {
                success = true
            } else {
                if let db = db {
                    let error = String(cString: sqlite3_errmsg(db))
                    DebugLog.error("SQLite Execute Error: \(error) | SQL: \(sql)")
                }
            }
        }
        sqlite3_finalize(statement)
        return success
    }
    
    // MARK: - Column extraction helpers
    
    nonisolated static func string(for statement: OpaquePointer, column: Int32) -> String {
        guard let ptr = sqlite3_column_text(statement, column) else { return "" }
        return String(cString: ptr)
    }
    
    nonisolated static func int(for statement: OpaquePointer, column: Int32) -> Int {
        return Int(sqlite3_column_int(statement, column))
    }
    
    nonisolated static func bool(for statement: OpaquePointer, column: Int32) -> Bool {
        return sqlite3_column_int(statement, column) != 0
    }
}
