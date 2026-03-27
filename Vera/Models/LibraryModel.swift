import SwiftUI

/// Kütüphane Kategorisi Modeli
struct LibraryCategory: Identifiable, Hashable {
    let id: String
    let title: String
    let icon: String
    let color: Color
    let description: String
}

/// Kütüphane Makale/Konu Modeli
struct LibraryArticle: Identifiable, Hashable {
    let id: String
    let categoryId: String
    let title: String
    let content: String
    let source: String?
}
