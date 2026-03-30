import Foundation
import SQLite3

extension AppDatabaseManager {
    
    // MARK: - Kuran-ı Kerim Motoru
    
    func fetchAuthors() -> [QuranAuthor] {
        let sql = "SELECT id, name, description, language FROM authors WHERE language IN ('tr', 'en') ORDER BY language DESC, name ASC"
        
        return DatabaseHelper.query(db, sql: sql) { statement in
            QuranAuthor(
                id: DatabaseHelper.int(for: statement, column: 0),
                name: DatabaseHelper.string(for: statement, column: 1),
                description: DatabaseHelper.string(for: statement, column: 2),
                language: DatabaseHelper.string(for: statement, column: 3)
            )
        }
    }
    
    func fetchSurahs() -> [QuranChapter] {
        let sql = "SELECT id, name, name_translation_tr, verse_count, page_number FROM surahs ORDER BY id ASC"
        
        return DatabaseHelper.query(db, sql: sql) { statement in
            QuranChapter(
                id: DatabaseHelper.int(for: statement, column: 0),
                name: DatabaseHelper.string(for: statement, column: 1),
                meaning: DatabaseHelper.string(for: statement, column: 2),
                verseCount: DatabaseHelper.int(for: statement, column: 3),
                pageNumber: DatabaseHelper.int(for: statement, column: 4)
            )
        }
    }
    
    func fetchVersesForPage(page: Int, authorId: Int) -> [QuranVerse] {
        let sql = """
        SELECT v.id, v.surah_id, v.verse_number, v.verse_diyanet, v.transcription, t.text
        FROM verses v
        LEFT JOIN translations t ON v.id = t.verse_id AND t.author_id = ?
        WHERE v.page = ?
        ORDER BY v.id ASC
        """
        
        return DatabaseHelper.query(db, sql: sql, bindings: { statement in
            sqlite3_bind_int(statement, 1, Int32(authorId))
            sqlite3_bind_int(statement, 2, Int32(page))
        }) { statement in
            QuranVerse(
                id: DatabaseHelper.int(for: statement, column: 0),
                surahId: DatabaseHelper.int(for: statement, column: 1),
                verseNumberInSurah: DatabaseHelper.int(for: statement, column: 2),
                text: DatabaseHelper.string(for: statement, column: 3),
                transcription: DatabaseHelper.string(for: statement, column: 4),
                translation: DatabaseHelper.string(for: statement, column: 5).isEmpty ? "Meal bulunamadı." : DatabaseHelper.string(for: statement, column: 5),
                pageNumber: page
            )
        }
    }
}
