import Foundation

// String arama kolaylaştırıcısı (Örn: "Istanbul" ile "İSTANBUL" u diacritic-insensitive eşleştirmek için)
extension String {
    func isLike(_ other: String) -> Bool {
        let options: String.CompareOptions = [.diacriticInsensitive, .caseInsensitive]
        let lhs = self.folding(options: options, locale: .current)
        let rhs = other.folding(options: options, locale: .current)
        return lhs == rhs
    }
}
