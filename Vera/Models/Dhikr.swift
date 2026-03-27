import Foundation

struct Dhikr: Identifiable, Codable, Sendable {

    var id: UUID = UUID()
    var title: String
    var count: Int
    var target: Int?
}
