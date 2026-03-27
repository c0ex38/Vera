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
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let dbURL = documentsURL.appendingPathComponent("vera.sqlite")
        let dbPath = dbURL.path
        
        // Cache cleanup
        if fileManager.fileExists(atPath: dbPath) {
            if let attrs = try? fileManager.attributesOfItem(atPath: dbPath),
               let fileSize = attrs[.size] as? UInt64, fileSize < 1_000_000 {
                try? fileManager.removeItem(atPath: dbPath)
            }
        }
        
        // Copy from bundle
        if !fileManager.fileExists(atPath: dbPath) {
            guard let bundleURL = Bundle.main.url(forResource: "vera", withExtension: "sqlite") else { return nil }
            try? fileManager.copyItem(at: bundleURL, to: dbURL)
        }
        
        var db: OpaquePointer?
        if sqlite3_open(dbPath, &db) == SQLITE_OK {
            return db
        }
        return nil
    }

    /// The singleton instance, accessible from any context in Swift 6 as it's a 'static let'.
    static let shared = AppDatabaseManager(connection: DBConnection(pointer: openDatabaseConnection()))
    
    private let connection: DBConnection
    private var db: OpaquePointer? { connection.pointer }
    
    /// Internal initializer for singleton creation.
    private init(connection: DBConnection) {
        self.connection = connection
    }

    deinit {
        if let db = connection.pointer {
            sqlite3_close(db)
        }
    }
    
    // MARK: - Esmaül Hüsna
    func fetchEsmaulHusna() -> [EsmaulHusna] {
        let query = "SELECT order_id, arabic, turkishReading, meaningText, descriptionText FROM esmaul_husna ORDER BY order_id ASC"
        var statement: OpaquePointer?
        var results = [EsmaulHusna]()
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let order = Int(sqlite3_column_int(statement, 0))
                let arabic = String(cString: sqlite3_column_text(statement, 1))
                let turkish = String(cString: sqlite3_column_text(statement, 2))
                let meaning = String(cString: sqlite3_column_text(statement, 3))
                let desc = String(cString: sqlite3_column_text(statement, 4))
                
                results.append(EsmaulHusna(order: order, arabic: arabic, turkishReading: turkish, meaningText: meaning, descriptionText: desc))
            }
        }
        sqlite3_finalize(statement)
        return results
    }
    
    // MARK: - Namaz Sureleri
    func fetchPrayerSurahs() -> [Surah] {
        let query = "SELECT id, title, subtitle, arabicText, turkishReading, meaning FROM prayer_surahs ORDER BY id ASC"
        var statement: OpaquePointer?
        var results = [Surah]()
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                _ = Int(sqlite3_column_int(statement, 0))
                let title = String(cString: sqlite3_column_text(statement, 1))
                let subtitle = String(cString: sqlite3_column_text(statement, 2))
                let arabic = String(cString: sqlite3_column_text(statement, 3))
                let turkish = String(cString: sqlite3_column_text(statement, 4))
                let meaning = String(cString: sqlite3_column_text(statement, 5))
                
                results.append(Surah(title: title, subtitle: subtitle, arabicText: arabic, turkishReading: turkish, meaning: meaning))
            }
        }
        sqlite3_finalize(statement)
        return results
    }
    
    // MARK: - Dini Günler
    func fetchReligiousDays() -> [ReligiousDay] {
        let query = "SELECT name, hicriDate, miladiDate, dayOfWeek, isImportant FROM religious_days ORDER BY id ASC"
        var statement: OpaquePointer?
        var results = [ReligiousDay]()
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let name = String(cString: sqlite3_column_text(statement, 0))
                let hicriDate = String(cString: sqlite3_column_text(statement, 1))
                let miladiDate = String(cString: sqlite3_column_text(statement, 2))
                let dayOfWeek = String(cString: sqlite3_column_text(statement, 3))
                let isImportant = sqlite3_column_int(statement, 4) != 0
                
                results.append(ReligiousDay(name: name, hicriDate: hicriDate, miladiDate: miladiDate, dayOfWeek: dayOfWeek, isImportant: isImportant))
            }
        }
        sqlite3_finalize(statement)
        return results
    }
    
    // MARK: - Zikirmatik (Dhikr) Yazma/Okuma
    func fetchActiveDhikr() -> Dhikr? {
        let query = "SELECT id, title, count, target FROM user_dhikrs LIMIT 1"
        var statement: OpaquePointer?
        var activeDhikr: Dhikr?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_ROW {
                if let idPtr = sqlite3_column_text(statement, 0) {
                    let idString = String(cString: idPtr)
                    let title = String(cString: sqlite3_column_text(statement, 1))
                    let count = Int(sqlite3_column_int(statement, 2))
                    let target = Int(sqlite3_column_int(statement, 3))
                    
                    activeDhikr = Dhikr(id: UUID(uuidString: idString) ?? UUID(), title: title, count: count, target: target)
                }
            }
        }
        sqlite3_finalize(statement)
        return activeDhikr
    }
    
    func saveActiveDhikr(_ dhikr: Dhikr) {
        let query = "INSERT OR REPLACE INTO user_dhikrs (id, title, count, target) VALUES (?, ?, ?, ?)"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (dhikr.id.uuidString as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (dhikr.title as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 3, Int32(dhikr.count))
            if let target = dhikr.target {
                sqlite3_bind_int(statement, 4, Int32(target))
            } else {
                sqlite3_bind_null(statement, 4)
            }
            
            if sqlite3_step(statement) != SQLITE_DONE {
                print("❌ Dhikr error")
            }
        }
        sqlite3_finalize(statement)
    }
    
    // MARK: - Kuran-ı Kerim Motoru
    var currentAuthorId: Int {
        let id = UserDefaults.standard.integer(forKey: "selectedQuranAuthorId")
        return id == 0 ? 11 : id
    }
    
    func fetchAuthors() -> [QuranAuthor] {
        let query = "SELECT id, name, description, language FROM authors WHERE language IN ('tr', 'en') ORDER BY language DESC, name ASC"
        var statement: OpaquePointer?
        var results = [QuranAuthor]()
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                let namePtr = sqlite3_column_text(statement, 1)
                let name = namePtr != nil ? String(cString: namePtr!) : ""
                let descPtr = sqlite3_column_text(statement, 2)
                let description = descPtr != nil ? String(cString: descPtr!) : ""
                let langPtr = sqlite3_column_text(statement, 3)
                let language = langPtr != nil ? String(cString: langPtr!) : ""
                results.append(QuranAuthor(id: id, name: name, description: description, language: language))
            }
        }
        sqlite3_finalize(statement)
        return results
    }
    
    func fetchSurahs() -> [QuranChapter] {
        let query = "SELECT id, name, name_translation_tr, verse_count, page_number FROM surahs ORDER BY id ASC"
        var statement: OpaquePointer?
        var results = [QuranChapter]()
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                let namePtr = sqlite3_column_text(statement, 1)
                let name = namePtr != nil ? String(cString: namePtr!) : ""
                let meaningPtr = sqlite3_column_text(statement, 2)
                let meaning = meaningPtr != nil ? String(cString: meaningPtr!) : ""
                let verseCount = Int(sqlite3_column_int(statement, 3))
                let pageNumber = Int(sqlite3_column_int(statement, 4))
                results.append(QuranChapter(id: id, name: name, meaning: meaning, verseCount: verseCount, pageNumber: pageNumber))
            }
        }
        sqlite3_finalize(statement)
        return results
    }
    
    func fetchVersesForPage(page: Int) -> [QuranVerse] {
        let query = """
        SELECT v.id, v.surah_id, v.verse_number, v.verse_diyanet, v.transcription, t.text
        FROM verses v
        LEFT JOIN translations t ON v.id = t.verse_id AND t.author_id = ?
        WHERE v.page = ?
        ORDER BY v.id ASC
        """
        var statement: OpaquePointer?
        var results = [QuranVerse]()
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(currentAuthorId))
            sqlite3_bind_int(statement, 2, Int32(page))
            
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                let surahId = Int(sqlite3_column_int(statement, 1))
                let verseNumberInSurah = Int(sqlite3_column_int(statement, 2))
                let arabicPtr = sqlite3_column_text(statement, 3)
                let arabicText = arabicPtr != nil ? String(cString: arabicPtr!) : ""
                let transcriptionPtr = sqlite3_column_text(statement, 4)
                let transcriptionText = transcriptionPtr != nil ? String(cString: transcriptionPtr!) : ""
                let meaningPtr = sqlite3_column_text(statement, 5)
                let meaningText = meaningPtr != nil ? String(cString: meaningPtr!) : "Meal bulunamadı."
                
                results.append(QuranVerse(id: id, surahId: surahId, verseNumberInSurah: verseNumberInSurah, text: arabicText, transcription: transcriptionText, translation: meaningText, pageNumber: page))
            }
        }
        sqlite3_finalize(statement)
        return results
    }
    
    // MARK: - Hadisler
    func fetchHadithOfTheDay() -> Hadith? {
        let query = "SELECT id, hadith_no, content FROM hadiths ORDER BY RANDOM() LIMIT 1"
        var statement: OpaquePointer?
        var result: Hadith?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                let no = Int(sqlite3_column_int(statement, 1))
                let content = String(cString: sqlite3_column_text(statement, 2))
                
                result = Hadith(id: id, hadithNo: no, content: content)
            }
        }
        sqlite3_finalize(statement)
        return result
    }
    
    func fetchAllHadiths() -> [Hadith] {
        let query = "SELECT id, hadith_no, content FROM hadiths ORDER BY hadith_no ASC"
        var statement: OpaquePointer?
        var results = [Hadith]()
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                let no = Int(sqlite3_column_int(statement, 1))
                let content = String(cString: sqlite3_column_text(statement, 2))
                
                results.append(Hadith(id: id, hadithNo: no, content: content))
            }
        }
        sqlite3_finalize(statement)
        return results
    }
}
