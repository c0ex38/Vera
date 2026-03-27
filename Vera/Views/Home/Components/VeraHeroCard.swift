import SwiftUI

struct VeraHeroCard: View {
    @ObservedObject var countdownManager: PrayerCountdownManager
    var animateOrbs: Bool
    
    var body: some View {
        ZStack {
            // Canlı Frost Glassmorphism
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .stroke(LinearGradient(colors: [Color.white.opacity(0.5), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                )
            
            VStack(alignment: .center, spacing: 20) {
                // Üst Etiket
                HStack(spacing: 8) {
                    Image(systemName: iconForNextPrayer(countdownManager.nextPrayer))
                        .font(.system(size: 20))
                        .foregroundColor(.themePrimary)
                    
                    Text(countdownManager.isPrayerTime ? L10n.Hero.prayerEntered(prayer: countdownManager.nextPrayerName.uppercased()) : L10n.Hero.timeRemaining(to: countdownManager.nextPrayerName.uppercased()))
                        .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 20 : 13, weight: .black, design: .rounded))
                        .foregroundColor(.themeTextSecondary)
                        .kerning(1.2)
                }
                
                // Devasa Hassas Sayaç
                Text(countdownManager.timeRemainingString)
                    .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 96 : 64, weight: .light, design: .rounded))
                    .foregroundColor(.themePrimary)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .multilineTextAlignment(.center)
                
                // Mevcut Vakit Bilgisi
                HStack(spacing: 6) {
                    Text(L10n.Hero.currentPrayer)
                        .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 18 : 13, weight: .medium))
                        .foregroundColor(.themeTextSecondary)
                    Text(countdownManager.currentPrayerName)
                        .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 20 : 14, weight: .bold))
                        .foregroundColor(.themeText)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.themeSurface.opacity(0.6))
                        .clipShape(Capsule())
                }
            }
            .frame(maxWidth: .infinity)
            .padding(28)
        }
        .cornerRadius(32)
        .shadow(color: Color.themePrimary.opacity(0.2), radius: 25, y: 15)
        .offset(y: animateOrbs ? -8 : 8)
    }
    
    private func iconForNextPrayer(_ type: PrayerType?) -> String {
        return type?.iconName ?? "clock.fill"
    }
}
