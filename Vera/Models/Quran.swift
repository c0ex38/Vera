import Foundation

// MARK: - SQLite Data Models

struct QuranAuthor: Identifiable, Hashable, Sendable {
    let id: Int
    let name: String
    let description: String
    let language: String
}

struct QuranChapter: Identifiable, Codable, Hashable, Sendable {
    let id: Int
    let name: String
    let meaning: String
    let verseCount: Int
    let pageNumber: Int
}

struct QuranVerse: Identifiable, Codable, Hashable, Sendable {
    let id: Int
    let surahId: Int
    let verseNumberInSurah: Int
    let text: String
    let transcription: String
    let translation: String
    let pageNumber: Int
    
    static func == (lhs: QuranVerse, rhs: QuranVerse) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

