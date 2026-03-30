import Foundation
import SQLite3

extension AppDatabaseManager {
    
    // MARK: - Namaz Sureleri
    func fetchPrayerSurahs() -> [Surah] {
        let sql = "SELECT title, subtitle, arabicText, turkishReading, meaning FROM prayer_surahs ORDER BY id ASC"
        
        return DatabaseHelper.query(db, sql: sql) { statement in
            Surah(
                title: DatabaseHelper.string(for: statement, column: 0),
                subtitle: DatabaseHelper.string(for: statement, column: 1),
                arabicText: DatabaseHelper.string(for: statement, column: 2),
                turkishReading: DatabaseHelper.string(for: statement, column: 3),
                meaning: DatabaseHelper.string(for: statement, column: 4)
            )
        }
    }
}
