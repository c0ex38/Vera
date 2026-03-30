import Foundation
import SQLite3

extension AppDatabaseManager {
    
    /// Fetches all items from the prayer_surahs table to include in the Library.
    func fetchLibraryPrayerSurahs() -> [LibraryItem] {
        let sql = "SELECT id, title, subtitle, arabicText, turkishReading, meaning FROM prayer_surahs ORDER BY id ASC"
        
        return DatabaseHelper.query(db, sql: sql) { statement in
            LibraryItem(
                id: "sql_\(DatabaseHelper.int(for: statement, column: 0))",
                title: DatabaseHelper.string(for: statement, column: 1) ?? "",
                arabic: DatabaseHelper.string(for: statement, column: 3),
                transcription: DatabaseHelper.string(for: statement, column: 4),
                meaning: DatabaseHelper.string(for: statement, column: 5),
                categoryId: "namaz_sureleri"
            )
        }
    }
    
    /// Fetches the dynamically added library categories and their items from the 'library' table.
    func fetchDynamicLibraryCategories() -> [LibraryCategory] {
        let sql = "SELECT category_id, category_name, title, arabic, transcription, meaning, icon, color FROM library ORDER BY id ASC"
        
        let allItems = DatabaseHelper.query(db, sql: sql) { statement in
            let title = DatabaseHelper.string(for: statement, column: 2) ?? ""
            let item = LibraryItem(
                id: "lib_\(title)",
                title: title,
                arabic: DatabaseHelper.string(for: statement, column: 3),
                transcription: DatabaseHelper.string(for: statement, column: 4),
                meaning: DatabaseHelper.string(for: statement, column: 5),
                categoryId: DatabaseHelper.string(for: statement, column: 0),
                steps: nil // We will populate this if it's a guide
            )
            return item
        }
        
        // Group by category and load steps for relevant items
        var categories: [LibraryCategory] = []
        let grouped = Dictionary(grouping: allItems) { $0.categoryId ?? "other" }
        
        for (catId, var items) in grouped {
            // If it's the namaz_rehber category, fetch steps for each item
            if catId == "namaz_rehber" {
                for i in 0..<items.count {
                    items[i].steps = fetchLibrarySteps(for: items[i].title)
                }
            }
            
            let metaSql = "SELECT category_name, icon, color FROM library WHERE category_id = ? LIMIT 1"
            let meta = DatabaseHelper.queryRow(db, sql: metaSql, bindings: { stmt in
                sqlite3_bind_text(stmt, 1, (catId as NSString).utf8String, -1, nil)
            }) { stmt in
                (name: DatabaseHelper.string(for: stmt, column: 0), icon: DatabaseHelper.string(for: stmt, column: 1), color: DatabaseHelper.string(for: stmt, column: 2))
            }
            
            categories.append(LibraryCategory(
                id: catId,
                name: meta?.name ?? "Diğer",
                icon: meta?.icon,
                color: meta?.color,
                items: items
            ))
        }
        
        return categories.sorted { $0.name < $1.name }
    }
    
    /// Fetches instruction steps for a specific library item.
    func fetchLibrarySteps(for itemTitle: String) -> [InstructionStep] {
        let sql = "SELECT step_number, step_title, step_description, image_name FROM library_steps WHERE item_title = ? ORDER BY step_number ASC"
        
        return DatabaseHelper.query(db, sql: sql, bindings: { statement in
            sqlite3_bind_text(statement, 1, (itemTitle as NSString).utf8String, -1, nil)
        }) { statement in
            InstructionStep(
                stepNumber: DatabaseHelper.int(for: statement, column: 0),
                title: DatabaseHelper.string(for: statement, column: 1) ?? "",
                description: DatabaseHelper.string(for: statement, column: 2) ?? "",
                imageName: DatabaseHelper.string(for: statement, column: 3)
            )
        }
    }
}
