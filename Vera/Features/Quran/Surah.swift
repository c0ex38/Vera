import Foundation

struct Surah: Identifiable, Hashable, Codable, Sendable {
    var id = UUID()
    let title: String
    let subtitle: String
    let arabicText: String
    let turkishReading: String
    let meaning: String
    
    enum CodingKeys: String, CodingKey {
        case title, subtitle, arabicText, turkishReading, meaning
    }
}
