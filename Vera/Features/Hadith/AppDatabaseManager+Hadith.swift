import Foundation
import SQLite3

extension AppDatabaseManager {
    
    // MARK: - Hadisler
    func fetchHadithOfTheDay() -> Hadith? {
        let sql = "SELECT id, hadith_no, content FROM hadiths ORDER BY RANDOM() LIMIT 1"
        
        return DatabaseHelper.queryRow(db, sql: sql) { statement in
            Hadith(
                id: DatabaseHelper.int(for: statement, column: 0),
                hadithNo: DatabaseHelper.int(for: statement, column: 1),
                content: DatabaseHelper.string(for: statement, column: 2)
            )
        }
    }
    
    func fetchAllHadiths() -> [Hadith] {
        let sql = "SELECT id, hadith_no, content FROM hadiths ORDER BY hadith_no ASC"
        
        return DatabaseHelper.query(db, sql: sql) { statement in
            Hadith(
                id: DatabaseHelper.int(for: statement, column: 0),
                hadithNo: DatabaseHelper.int(for: statement, column: 1),
                content: DatabaseHelper.string(for: statement, column: 2)
            )
        }
    }
    
    func fetchHadithsPaged(offset: Int, limit: Int) -> [Hadith] {
        let sql = "SELECT id, hadith_no, content FROM hadiths ORDER BY hadith_no ASC LIMIT ? OFFSET ?"
        
        return DatabaseHelper.query(db, sql: sql, bindings: { statement in
            sqlite3_bind_int(statement, 1, Int32(limit))
            sqlite3_bind_int(statement, 2, Int32(offset))
        }) { statement in
            Hadith(
                id: DatabaseHelper.int(for: statement, column: 0),
                hadithNo: DatabaseHelper.int(for: statement, column: 1),
                content: DatabaseHelper.string(for: statement, column: 2)
            )
        }
    }
    
    func searchHadiths(query: String) -> [Hadith] {
        let sql = "SELECT id, hadith_no, content FROM hadiths WHERE content LIKE ? OR CAST(hadith_no AS TEXT) LIKE ? ORDER BY hadith_no ASC"
        
        return DatabaseHelper.query(db, sql: sql, bindings: { statement in
            let searchPattern = "%\(query)%"
            sqlite3_bind_text(statement, 1, (searchPattern as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (searchPattern as NSString).utf8String, -1, nil)
        }) { statement in
            Hadith(
                id: DatabaseHelper.int(for: statement, column: 0),
                hadithNo: DatabaseHelper.int(for: statement, column: 1),
                content: DatabaseHelper.string(for: statement, column: 2)
            )
        }
    }
    
    func fetchHadithCount() -> Int {
        let sql = "SELECT COUNT(*) FROM hadiths"
        
        return DatabaseHelper.queryRow(db, sql: sql) { statement in
            DatabaseHelper.int(for: statement, column: 0)
        } ?? 0
    }
}
