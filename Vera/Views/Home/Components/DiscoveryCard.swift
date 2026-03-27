import SwiftUI

struct DiscoveryCard: View {
    let suggestion: HomeSuggestion
    @State private var navigateToDetail = false
    
    var body: some View {
        ZStack {
            // Glassmorphic Card
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .stroke(LinearGradient(colors: [suggestion.color.opacity(0.4), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                )
            
            VStack(alignment: .leading, spacing: 18) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(suggestion.color.opacity(0.15))
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: suggestion.icon)
                            .font(.system(size: 22))
                            .foregroundColor(suggestion.color)
                    }
                    
                    Text(suggestion.title)
                        .font(.veraCardHeader)
                        .foregroundColor(.themeTextSecondary)
                        .kerning(1.2)
                    
                    Spacer()
                }
                
                Text(suggestion.content)
                    .font(.veraContent)
                    .foregroundColor(.themeText)
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)
                
                Button(action: {
                    InterstitialAdManager.shared.showAdIfAvailable {
                        navigateToDetail = true
                    }
                }) {
                    HStack {
                        Text(suggestion.actionTitle)
                            .font(.veraAction)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(suggestion.color)
                            .shadow(color: suggestion.color.opacity(0.3), radius: 10, y: 5)
                    )
                }
                .navigationDestination(isPresented: $navigateToDetail) {
                    destinationFor(suggestion.type)
                }
            }
            .padding(28)
        }
    }
    
    @ViewBuilder
    private func destinationFor(_ type: HomeSuggestion.SuggestionType) -> some View {
        switch type {
        case .quran: QuranIndexView()
        case .dhikr: DhikrView()
        case .esma: EsmaulHusnaListView()
        case .mosques: NearbyMosquesView()
        case .zakat: ZakatHomeView()
        case .hadith: HadithListView()
        case .dua: PrayerSurahsListView() // Dualar bu liste içinde
        }
    }
}
