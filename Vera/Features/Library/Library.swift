import Foundation

struct LibraryCategory: Identifiable, Codable {
    let id: String
    let name: String
    let icon: String?
    let color: String?
    var items: [LibraryItem]
}

struct LibraryItem: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let arabic: String?
    let transcription: String?
    let meaning: String?
    
    // Additional field for SQLite-sourced items
    var categoryId: String? = nil
    
    // Steps for instructional content (e.g. Abdest, Namaz)
    var steps: [InstructionStep]? = nil
}

struct InstructionStep: Identifiable, Codable, Hashable {
    var id: String { "\(stepNumber)" }
    let stepNumber: Int
    let title: String
    let description: String
    let imageName: String?
}
