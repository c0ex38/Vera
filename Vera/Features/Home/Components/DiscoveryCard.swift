import SwiftUI

struct DiscoveryCard: View {
    let suggestion: HomeSuggestion
    @State private var navigateToDetail = false
    
    @State private var isPressing = false
    @State private var animateGlow = false
    
    var body: some View {
        ZStack {
            // Background Atmosphere Glow (Living Atmosphere)
            ZStack {
                Circle()
                    .fill(suggestion.color.opacity(0.15))
                    .frame(width: 250, height: 250)
                    .blur(radius: 70)
                    .offset(x: animateGlow ? 100 : 60, y: animateGlow ? -60 : -20)
                
                Circle()
                    .fill(suggestion.color.opacity(0.1))
                    .frame(width: 200, height: 200)
                    .blur(radius: 60)
                    .offset(x: animateGlow ? -80 : -40, y: animateGlow ? 40 : 80)
            }
            .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: animateGlow)
            .onAppear { animateGlow = true }
            
            // Glassmorphic Card
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.04), radius: 20, x: 0, y: 10)
                .overlay(
                    ZStack {
                        // Light Reflection Stroke (Top-Left)
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.5), .clear, .clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                        
                        // Suggestion Color Stroke
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        suggestion.color.opacity(0.4),
                                        .clear,
                                        suggestion.color.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                )
            
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(suggestion.color.opacity(0.15))
                            .frame(width: 52, height: 52)
                        
                        Image(systemName: suggestion.icon)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(suggestion.color)
                    }
                    .shadow(color: suggestion.color.opacity(0.2), radius: 8, x: 0, y: 4)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(suggestion.title)
                            .font(.system(size: 14, weight: .black, design: .rounded))
                            .foregroundColor(suggestion.color)
                            .kerning(1.5)
                            .textCase(.uppercase)
                        
                        Rectangle()
                            .fill(suggestion.color.opacity(0.3))
                            .frame(width: 30, height: 3)
                            .cornerRadius(1.5)
                    }
                    
                    Spacer()
                }
                
                Text(suggestion.content)
                    .font(.system(size: 18, weight: .medium, design: .serif))
                    .foregroundColor(.themeText)
                    .lineSpacing(6)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isPressing = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isPressing = false
                        InterstitialAdManager.shared.showAdIfAvailable {
                            navigateToDetail = true
                        }
                    }
                }) {
                    HStack(spacing: 12) {
                        Text(suggestion.actionTitle)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 22))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(
                        ZStack {
                            Capsule()
                                .fill(suggestion.color)
                            
                            // subtle shimmer/light highlight
                            Capsule()
                                .stroke(.white.opacity(0.3), lineWidth: 1)
                                .mask(
                                    Capsule()
                                        .fill(LinearGradient(colors: [.white.opacity(0.5), .clear], startPoint: .topLeading, endPoint: .bottomTrailing))
                                )
                        }
                        .shadow(color: suggestion.color.opacity(0.4), radius: 10, y: 5)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .scaleEffect(isPressing ? 0.95 : 1.0)
                .navigationDestination(isPresented: $navigateToDetail) {
                    destinationFor(suggestion.type)
                }
            }
            .padding(28)
        }
        .scaleEffect(isPressing ? 0.98 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isPressing)
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
