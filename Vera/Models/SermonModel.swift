import Foundation

struct Sermon: Identifiable, Hashable {
    let id = UUID()
    let date: String
    let title: String
    let pdfURL: String
    let audioURL: String?
}
