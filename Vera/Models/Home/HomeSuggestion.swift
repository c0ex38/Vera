import SwiftUI

struct HomeSuggestion: Identifiable {
    let id = UUID()
    let type: SuggestionType
    let title: String
    let content: String
    let icon: String
    let color: Color
    let actionTitle: String
    
    enum SuggestionType {
        case quran, dhikr, esma, mosques, zakat, hadith, dua
    }
    
    static func random() -> HomeSuggestion {
        let suggestions: [HomeSuggestion] = [
            HomeSuggestion(
                type: .dhikr,
                title: L10n.Suggestions.Dhikr.title,
                content: L10n.Suggestions.Dhikr.content,
                icon: "hand.tap.fill",
                color: .orange,
                actionTitle: L10n.Suggestions.Dhikr.action
            ),
            HomeSuggestion(
                type: .quran,
                title: L10n.Suggestions.Quran.title,
                content: L10n.Suggestions.Quran.content,
                icon: "book.fill",
                color: .themePrimary,
                actionTitle: L10n.Suggestions.Quran.action
            ),
            HomeSuggestion(
                type: .esma,
                title: L10n.Suggestions.Esma.title,
                content: L10n.Suggestions.Esma.content,
                icon: "sparkles",
                color: .purple,
                actionTitle: L10n.Suggestions.Esma.action
            ),
            HomeSuggestion(
                type: .hadith,
                title: L10n.Suggestions.Hadith.title,
                content: L10n.Suggestions.Hadith.content,
                icon: "quote.bubble.fill",
                color: .cyan,
                actionTitle: L10n.Suggestions.Hadith.action
            ),
            HomeSuggestion(
                type: .dua,
                title: L10n.Suggestions.Dua.title,
                content: L10n.Suggestions.Dua.content,
                icon: "hands.sparkles.fill",
                color: .indigo,
                actionTitle: L10n.Suggestions.Dua.action
            ),
            HomeSuggestion(
                type: .mosques,
                title: L10n.Suggestions.Mosques.title,
                content: L10n.Suggestions.Mosques.content,
                icon: "mappin.and.ellipse",
                color: .green,
                actionTitle: L10n.Suggestions.Mosques.action
            ),
            HomeSuggestion(
                type: .zakat,
                title: L10n.Suggestions.Zakat.title,
                content: L10n.Suggestions.Zakat.content,
                icon: "banknote.fill",
                color: .yellow,
                actionTitle: L10n.Suggestions.Zakat.action
            )
        ]
        return suggestions.randomElement() ?? suggestions[0]
    }
    
    static func getMultiple(count: Int) -> [HomeSuggestion] {
        var all = [
            HomeSuggestion(type: .dhikr, title: L10n.Suggestions.Dhikr.title, content: L10n.Suggestions.Dhikr.content, icon: "hand.tap.fill", color: .orange, actionTitle: L10n.Suggestions.Dhikr.action),
            HomeSuggestion(type: .quran, title: L10n.Suggestions.Quran.title, content: L10n.Suggestions.Quran.content, icon: "book.fill", color: .themePrimary, actionTitle: L10n.Suggestions.Quran.action),
            HomeSuggestion(type: .esma, title: L10n.Suggestions.Esma.title, content: L10n.Suggestions.Esma.content, icon: "sparkles", color: .purple, actionTitle: L10n.Suggestions.Esma.action),
            HomeSuggestion(type: .hadith, title: L10n.Suggestions.Hadith.title, content: L10n.Suggestions.Hadith.content, icon: "quote.bubble.fill", color: .cyan, actionTitle: L10n.Suggestions.Hadith.action),
            HomeSuggestion(type: .dua, title: L10n.Suggestions.Dua.title, content: L10n.Suggestions.Dua.content, icon: "hands.sparkles.fill", color: .indigo, actionTitle: L10n.Suggestions.Dua.action)
        ]
        all.shuffle()
        return Array(all.prefix(count))
    }
}
