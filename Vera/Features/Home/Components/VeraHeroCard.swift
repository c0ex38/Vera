import SwiftUI

struct VeraHeroCard: View {
    @ObservedObject var countdownManager: PrayerCountdownManager
    
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Canlı Frost Glassmorphism
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .stroke(LinearGradient(colors: [Color.white.opacity(0.5), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                )
            
            // Pulse Effect Background
            Circle()
                .fill(Color.themePrimary.opacity(0.05))
                .scaleEffect(pulseScale)
                .frame(width: 200, height: 200)
                .onAppear {
                    withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                        pulseScale = 1.2
                    }
                }
            
            VStack(alignment: .center, spacing: 16) {
                // Üst Etiket
                HStack(spacing: 8) {
                    Image(systemName: iconForNextPrayer(countdownManager.nextPrayer))
                        .font(.system(size: 18))
                        .foregroundColor(.themePrimary)
                    
                    Text(countdownManager.isPrayerTime ? L10n.Hero.prayerEntered(prayer: countdownManager.nextPrayerName.uppercased()) : L10n.Hero.timeRemaining(to: countdownManager.nextPrayerName.uppercased()))
                        .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 18 : 12, weight: .black, design: .rounded))
                        .foregroundColor(.themeTextSecondary)
                        .kerning(1.5)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                
                // Devasa Hassas Sayaç & Ring
                ZStack {
                    // Progress Ring
                    Circle()
                        .stroke(Color.themePrimary.opacity(0.08), lineWidth: 4)
                        .frame(width: 220, height: 220)
                    
                    Circle()
                        .trim(from: 0, to: countdownManager.progress)
                        .stroke(Color.themePrimary, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 220, height: 220)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut, value: countdownManager.progress)

                    Text(countdownManager.timeRemainingString)
                        .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 84 : 54, weight: .ultraLight, design: .rounded))
                        .foregroundColor(.themePrimary)
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .multilineTextAlignment(.center)
                }
                
                // Mevcut Vakit Bilgisi
                HStack(spacing: 6) {
                    Text(L10n.Hero.currentPrayer)
                        .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 16 : 12, weight: .medium))
                        .foregroundColor(.themeTextSecondary)
                    Text(countdownManager.currentPrayerName)
                        .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 18 : 13, weight: .bold))
                        .foregroundColor(.themeText)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.themeSurface.opacity(0.6))
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.03), radius: 5, y: 2)
                }
            }
            .padding(.vertical, 32)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, 20)
        .shadow(color: Color.themePrimary.opacity(0.08), radius: 25, y: 15)
    }
    
    private func iconForNextPrayer(_ type: PrayerType?) -> String {
        return type?.iconName ?? "clock.fill"
    }
}
