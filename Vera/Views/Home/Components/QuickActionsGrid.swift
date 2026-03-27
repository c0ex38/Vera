import SwiftUI

struct QuickActionsGrid: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Hızlı Erişim")
                .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 28 : 20, weight: .bold, design: .rounded))
                .foregroundColor(.themeText)
                .padding(.horizontal, 20)
                .padding(.top, UIDevice.current.userInterfaceIdiom == .pad ? 20 : 0)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    NavigationLink(destination: QiblaView()) {
                        QuickActionCell(title: "Kıble", icon: "safari.fill", color: Color.teal)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    NavigationLink(destination: DhikrView()) {
                        QuickActionCell(title: "Zikirmatik", icon: "hand.tap.fill", color: Color.orange)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    NavigationLink(destination: QuranIndexView()) {
                        QuickActionCell(title: "Kuran", icon: "book.pages.fill", color: Color.themePrimary)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    NavigationLink(destination: PrayerSurahsListView()) {
                        QuickActionCell(title: "Dualar", icon: "hands.sparkles.fill", color: Color.indigo)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
            }
        }
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
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 18 : 13, weight: .semibold, design: .rounded))
                .foregroundColor(.themeText)
        }
        .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? 110 : 80)
    }
}
