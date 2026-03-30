import SwiftUI

struct QuickActionsGrid: View {
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text(L10n.Home.quickAccess)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.themeText)
                .padding(.horizontal, 20)
                .padding(.top, UIDevice.current.userInterfaceIdiom == .pad ? 20 : 0)
            }
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                HStack(spacing: 32) {
                    Spacer()
                    actions
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        actions
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                }
            }
        }
    }
    
    @ViewBuilder
    private var actions: some View {
        NavigationLink(destination: QiblaView()) {
            QuickActionCell(title: "Kıble", icon: "safari.fill", color: Color.teal)
        }
        .buttonStyle(ScaleButtonStyle())
        
        NavigationLink(destination: DhikrView()) {
            QuickActionCell(title: "Zikirmatik", icon: "hand.tap.fill", color: Color.orange)
        }
        .buttonStyle(ScaleButtonStyle())
        
        NavigationLink(destination: QuranIndexView()) {
            QuickActionCell(title: "Kuran", icon: "book.pages.fill", color: Color.themePrimary)
        }
        .buttonStyle(ScaleButtonStyle())
        
        NavigationLink(destination: PrayerSurahsListView()) {
            QuickActionCell(title: "Dualar", icon: "hands.sparkles.fill", color: Color.indigo)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Hızlı Erişim Modül Hücresi (iOS Control Center Style)
struct QuickActionCell: View {
    let title: String
    let icon: String // SF Symbol Name
    let color: Color
    
    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                // Gelişmiş Kare/Oval Kapsayıcı
                RoundedRectangle(cornerRadius: UIDevice.current.userInterfaceIdiom == .pad ? 24 : 18)
                    .fill(color.opacity(0.12))
                    .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? 100 : 72, height: UIDevice.current.userInterfaceIdiom == .pad ? 100 : 72)
                
                Image(systemName: icon)
                    .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 44 : 30, weight: .medium))
                    .foregroundStyle(color)
            }
            
            Text(title)
                .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 18 : 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.themeText)
        }
        .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? 110 : 80)
        .contentShape(Rectangle())
        .onTapGesture { } // Affordance for better hit testing if needed, but NavigationLink handles it
    }
}

// MARK: - Premium Button Style for Scale Effect
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
