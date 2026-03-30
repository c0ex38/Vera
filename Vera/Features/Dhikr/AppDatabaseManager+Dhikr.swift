import Foundation
import SQLite3

extension AppDatabaseManager {
    
    // MARK: - Zikirmatik (Dhikr) Yazma/Okuma
    func fetchActiveDhikr() -> Dhikr? {
        let query = "SELECT id, title, count, target FROM user_dhikrs LIMIT 1"
        
        return DatabaseHelper.queryRow(db, sql: query) { statement in
            let idPtr = sqlite3_column_text(statement, 0)
            let idString = idPtr != nil ? String(cString: idPtr!) : UUID().uuidString
            let title = DatabaseHelper.string(for: statement, column: 1)
            let count = DatabaseHelper.int(for: statement, column: 2)
            let target = DatabaseHelper.int(for: statement, column: 3)
            
            return Dhikr(id: UUID(uuidString: idString) ?? UUID(), title: title, count: count, target: target)
        }
    }
    
    func saveActiveDhikr(_ dhikr: Dhikr) {
        let query = "INSERT OR REPLACE INTO user_dhikrs (id, title, count, target) VALUES (?, ?, ?, ?)"
        
        _ = DatabaseHelper.execute(db, sql: query) { statement in
            sqlite3_bind_text(statement, 1, (dhikr.id.uuidString as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (dhikr.title as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 3, Int32(dhikr.count))
            if let target = dhikr.target {
                sqlite3_bind_int(statement, 4, Int32(target))
            } else {
                sqlite3_bind_null(statement, 4)
            }
        }
    }
}
