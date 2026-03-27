import Foundation

struct Hadith: Codable, Identifiable, Sendable {
    let id: Int
    let hadithNo: Int
    let content: String
}
