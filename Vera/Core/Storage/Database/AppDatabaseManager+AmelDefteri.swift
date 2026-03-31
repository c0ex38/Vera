import Foundation
import SQLite3

extension AppDatabaseManager {
    
    /// Fetches all task completions for a specific date (formatted as yyyy-MM-dd)
    func fetchDailyProgress(for date: String) async -> [DailyProgress] {
        let sql = "SELECT id, task_id, is_completed, value FROM daily_progress WHERE date = ?"
        
        return DatabaseHelper.query(db, sql: sql, bindings: { statement in
            sqlite3_bind_text(statement, 1, (date as NSString).utf8String, -1, nil)
        }) { statement in
            let idString = DatabaseHelper.string(for: statement, column: 0)
            let taskId = DatabaseHelper.string(for: statement, column: 1)
            let isCompleted = DatabaseHelper.int(for: statement, column: 2) != 0
            let value = DatabaseHelper.int(for: statement, column: 3)
            
            return DailyProgress(
                id: UUID(uuidString: idString) ?? UUID(),
                taskId: taskId,
                date: date,
                isCompleted: isCompleted,
                value: value
            )
        }
    }
    
    /// Saves or updates a task completion entry
    func saveDailyProgress(_ progress: DailyProgress) async {
        let sql = """
        INSERT OR REPLACE INTO daily_progress (id, task_id, date, is_completed, value)
        VALUES (?, ?, ?, ?, ?)
        """
        
        _ = DatabaseHelper.execute(db, sql: sql) { statement in
            sqlite3_bind_text(statement, 1, (progress.id.uuidString as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (progress.taskId as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 3, (progress.date as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 4, progress.isCompleted ? 1 : 0)
            sqlite3_bind_int(statement, 5, Int32(progress.value))
        }
    }
    
    /// Toggles the completion status of a task for a given day
    func toggleDailyTask(taskId: String, date: String) async {
        let current = await fetchDailyProgress(for: date).first(where: { $0.taskId == taskId })
        
        var newProgress: DailyProgress
        if let existing = current {
            newProgress = existing
            newProgress.isCompleted.toggle()
        } else {
            newProgress = DailyProgress(taskId: taskId, date: date, isCompleted: true)
        }
        
        await saveDailyProgress(newProgress)
    }
}
