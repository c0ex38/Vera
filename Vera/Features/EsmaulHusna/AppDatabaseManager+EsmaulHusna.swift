import Foundation
import SQLite3

extension AppDatabaseManager {
    
    // MARK: - Esmaül Hüsna
    func fetchEsmaulHusna() -> [EsmaulHusna] {
        let query = "SELECT order_id, arabic, turkishReading, meaningText, descriptionText FROM esmaul_husna ORDER BY order_id ASC"
        
        return DatabaseHelper.query(db, sql: query) { statement in
            EsmaulHusna(
                order: DatabaseHelper.int(for: statement, column: 0),
                arabic: DatabaseHelper.string(for: statement, column: 1),
                turkishReading: DatabaseHelper.string(for: statement, column: 2),
                meaningText: DatabaseHelper.string(for: statement, column: 3),
                descriptionText: DatabaseHelper.string(for: statement, column: 4)
            )
        }
    }
}
