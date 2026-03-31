import Foundation

struct Dhikr: Identifiable, Codable, Sendable {

    var id: UUID = UUID()
    var title: String
    var count: Int
    var target: Int?
}

struct DhikrTemplate: Identifiable, Codable, Sendable {
    var id: Int
    var titleKey: String
    var target: Int
}
