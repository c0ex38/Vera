import Foundation

struct ReligiousDay: Identifiable, Hashable, Codable, Sendable {
    var id = UUID()
    let name: String
    let hicriDate: String
    let miladiDate: String
    let dayOfWeek: String
    let isImportant: Bool
    
    enum CodingKeys: String, CodingKey {
        case name, hicriDate, miladiDate, dayOfWeek, isImportant
    }
}
