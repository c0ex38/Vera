import Foundation

struct EsmaulHusna: Identifiable, Hashable, Codable, Sendable {
    var id: UUID = UUID()
    let order: Int
    let arabic: String
    let turkishReading: String
    let meaningText: String
    let descriptionText: String
    
    enum CodingKeys: String, CodingKey {
        case order
        case arabic
        case turkishReading
        case meaningText
        case descriptionText
    }
}
