import Foundation
import SQLite3

extension AppDatabaseManager {
    
    // MARK: - Dini Günler
    func fetchReligiousDays() -> [ReligiousDay] {
        let sql = "SELECT name, hicriDate, miladiDate, dayOfWeek, isImportant FROM religious_days ORDER BY id ASC"
        
        return DatabaseHelper.query(db, sql: sql) { statement in
            ReligiousDay(
                name: DatabaseHelper.string(for: statement, column: 0),
                hicriDate: DatabaseHelper.string(for: statement, column: 1),
                miladiDate: DatabaseHelper.string(for: statement, column: 2),
                dayOfWeek: DatabaseHelper.string(for: statement, column: 3),
                isImportant: DatabaseHelper.bool(for: statement, column: 4)
            )
        }
    }
}
