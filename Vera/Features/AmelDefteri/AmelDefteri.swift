import Foundation

/// Represents a spiritual task (e.g., Five Daily Prayers, Quran Reading)
enum SpiritualTask: String, CaseIterable, Identifiable, Codable {
    case fajr = "fajr"
    case dhuhr = "dhuhr"
    case asr = "asr"
    case maghrib = "maghrib"
    case isha = "isha"
    case quran = "quran"
    case dhikr = "dhikr"
    case fasting = "fasting"
    
    var id: String { self.rawValue }
    
    var title: String {
        switch self {
        case .fajr: return "Sabah Namazı"
        case .dhuhr: return "Öğle Namazı"
        case .asr: return "İkindi Namazı"
        case .maghrib: return "Akşam Namazı"
        case .isha: return "Yatsı Namazı"
        case .quran: return "Kur'an Okuma"
        case .dhikr: return "Günlük Zikir"
        case .fasting: return "Nafile Oruç"
        }
    }
    
    var icon: String {
        switch self {
        case .fajr, .dhuhr, .asr, .maghrib, .isha: return "sun.max.fill"
        case .quran: return "book.closed.fill"
        case .dhikr: return "beads.fill"
        case .fasting: return "moon.fill"
        }
    }
}

/// Represents the user's completion status for a specific task on a specific day
struct DailyProgress: Identifiable, Codable {
    let id: UUID
    let taskId: String
    let date: String // yyyy-MM-dd
    var isCompleted: Bool
    var value: Int // For expandable tasks like pages of Quran
    
    init(id: UUID = UUID(), taskId: String, date: String, isCompleted: Bool = false, value: Int = 0) {
        self.id = id
        self.taskId = taskId
        self.date = date
        self.isCompleted = isCompleted
        self.value = value
    }
}
