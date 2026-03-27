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
                title: "Günün Zikri",
                content: "Sübhânallâhi ve bi-hamdihî (Allah'ı hamd ile tesbih ederim)",
                icon: "hand.tap.fill",
                color: .orange,
                actionTitle: "Zikirmatik'i Aç"
            ),
            HomeSuggestion(
                type: .quran,
                title: "Günün Ayeti",
                content: "Şüphesiz güçlükle beraber bir kolaylık vardır. (İnşirah, 5)",
                icon: "book.fill",
                color: .themePrimary,
                actionTitle: "Kuran-ı Kerim Oku"
            ),
            HomeSuggestion(
                type: .esma,
                title: "Esmaül Hüsna",
                content: "Er-Rahmân: Dünyada bütün mahlukata şefkat gösteren, mü'min kafir ayırt etmeden herkesi rızıklandıran.",
                icon: "sparkles",
                color: .purple,
                actionTitle: "99 İsim'i İncele"
            ),
            HomeSuggestion(
                type: .hadith,
                title: "Günün Hadisi",
                content: "Bizi aldatan bizden değildir. (Müslim, Îmân, 164)",
                icon: "quote.bubble.fill",
                color: .cyan,
                actionTitle: "Hadisleri Keşfet"
            ),
            HomeSuggestion(
                type: .dua,
                title: "Günün Duası",
                content: "Rabbim! ilmimi artır. (Tâhâ, 114)",
                icon: "hands.sparkles.fill",
                color: .indigo,
                actionTitle: "Duaları Oku"
            ),
            HomeSuggestion(
                type: .mosques,
                title: "Cami Bul",
                content: "Çevrenizdeki camileri ve mescitleri harita üzerinden hızlıca bulun.",
                icon: "mappin.and.ellipse",
                color: .green,
                actionTitle: "Haritayı Aç"
            ),
            HomeSuggestion(
                type: .zakat,
                title: "Zekat Hesabı",
                content: "Varlıklarınızın zekat miktarını Diyanet fetvalarına uygun şekilde hesaplayın.",
                icon: "banknote.fill",
                color: .yellow,
                actionTitle: "Hesaplamaya Başla"
            )
        ]
        return suggestions.randomElement() ?? suggestions[0]
    }
    
    static func getMultiple(count: Int) -> [HomeSuggestion] {
        var all = [
            HomeSuggestion(type: .dhikr, title: "Günün Zikri", content: "Sübhânallâhi ve bi-hamdihî (Allah'ı hamd ile tesbih ederim)", icon: "hand.tap.fill", color: .orange, actionTitle: "Zikirmatik'i Aç"),
            HomeSuggestion(type: .quran, title: "Günün Ayeti", content: "Şüphesiz güçlükle beraber bir kolaylık vardır. (İnşirah, 5)", icon: "book.fill", color: .themePrimary, actionTitle: "Kuran-ı Kerim Oku"),
            HomeSuggestion(type: .esma, title: "Esmaül Hüsna", content: "Er-Rahmân: Dünyada bütün mahlukata şefkat gösteren, mü'min kafir ayırt etmeden herkesi rızıklandıran.", icon: "sparkles", color: .purple, actionTitle: "99 İsim'i İncele"),
            HomeSuggestion(type: .hadith, title: "Günün Hadisi", content: "Bizi aldatan bizden değildir. (Müslim, Îmân, 164)", icon: "quote.bubble.fill", color: .cyan, actionTitle: "Kütüphane'yi Aç"),
            HomeSuggestion(type: .dua, title: "Günün Duası", content: "Rabbim! ilmimi artır. (Tâhâ, 114)", icon: "hands.sparkles.fill", color: .indigo, actionTitle: "Duaları Oku")
        ]
        all.shuffle()
        return Array(all.prefix(count))
    }
}
