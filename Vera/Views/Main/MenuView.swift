import SwiftUI

struct MenuView: View {
    @State private var navigateToModule = false
    @State private var selectedModule: MenuModule?
    
    // Grid Yapılandırması (3 Sütun)
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Derin Tema Arkaplanı
                Color.themeBackground.ignoresSafeArea()
                
                // Nefes Alan Arkaplan Işığı (Hafif bir aura)
                RadialGradient(
                    colors: [Color.themePrimary.opacity(0.15), .clear],
                    center: .top,
                    startRadius: 50,
                    endRadius: 400
                )
                .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Spacer(minLength: 10)
                    
                    // Tam Merkezlenmiş Premium Header
                    VStack(spacing: 6) {
                        Text(L10n.Menu.title)
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .foregroundColor(.themePrimary)
                            .shadow(color: Color.themePrimary.opacity(0.3), radius: 10, y: 5)
                        
                        Text(L10n.Menu.subtitle)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.themeTextSecondary)
                            .tracking(0.5)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    // Menü Grid'i (Glassmorphic, 3 Sütun)
                    ScrollView(showsIndicators: false) {
                        LazyVGrid(columns: columns, spacing: 16) {
                            menuItem(module: .zikir, title: L10n.Menu.zikir, icon: "hand.tap.default.fill", color: .orange, subtitle: L10n.Menu.zikirSub)
                            menuItem(module: .imsakiye, title: L10n.Menu.imsakiye, icon: "calendar.badge.clock", color: .indigo, subtitle: L10n.Menu.imsakiyeSub)
                            menuItem(module: .alarms, title: L10n.Menu.alarms, icon: "alarm.fill", color: .red, subtitle: L10n.Menu.alarmsSub)
                            menuItem(module: .surahs, title: L10n.Menu.surahs, icon: "book.fill", color: .brown, subtitle: L10n.Menu.surahsSub)
                            menuItem(module: .esma, title: L10n.Menu.esma, icon: "sparkles", color: .purple, subtitle: L10n.Menu.esmaSub)
                            menuItem(module: .quran, title: L10n.Menu.quran, icon: "book.pages.fill", color: .teal, subtitle: L10n.Menu.quranSub)
                            menuItem(module: .mosques, title: L10n.Menu.mosques, icon: "mappin.circle.fill", color: .green, subtitle: L10n.Menu.mosquesSub)
                            menuItem(module: .zakat, title: L10n.Menu.zakat, icon: "banknote.fill", color: .yellow, subtitle: L10n.Menu.zakatSub)
                            menuItem(module: .library, title: L10n.Menu.library, icon: "books.vertical.fill", color: .blue, subtitle: L10n.Menu.librarySub)
                            menuItem(module: .hadiths, title: L10n.Menu.hadiths, icon: "text.quote", color: .cyan, subtitle: L10n.Menu.hadithsSub)
                            menuItem(module: .sermon, title: L10n.Menu.sermon, icon: "quote.bubble.fill", color: .teal, subtitle: L10n.Menu.sermonSub)
                            menuItem(module: .settings, title: L10n.Menu.settings, icon: "gearshape.fill", color: .gray, subtitle: L10n.Menu.settingsSub)
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    Spacer(minLength: 60)
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $navigateToModule) {
                if let module = selectedModule {
                    destinationView(for: module)
                }
            }
        }
    }
    
    @ViewBuilder
    private func menuItem(module: MenuModule, title: String, icon: String, color: Color, subtitle: String) -> some View {
        Button(action: {
            handleModuleSelection(module)
        }) {
            VStack(spacing: 12) {
                // Ikon Alanı (Glassmorphic Circle)
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(color)
                }
                
                VStack(spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.themeText)
                        .lineLimit(1)
                    
                    Text(subtitle)
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(.themeTextSecondary)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.themeSurface.opacity(0.4))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.03), radius: 10, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func handleModuleSelection(_ module: MenuModule) {
        selectedModule = module
        
        // Interstitial Reklam Tetikleyicisi
        InterstitialAdManager.shared.showAdIfAvailable {
            navigateToModule = true
        }
    }
    
    @ViewBuilder
    private func destinationView(for module: MenuModule) -> some View {
        switch module {
        case .zikir:
            DhikrView()
        case .imsakiye:
            MonthlyImsakiyeView()
        case .alarms:
            NotificationSettingsView()
        case .surahs:
             PrayerSurahsListView()
        case .esma:
            EsmaulHusnaListView()
        case .quran:
            QuranIndexView()
        case .mosques:
            NearbyMosquesView()
        case .zakat:
            ZakatHomeView()
        case .library:
            LibraryListView()
        case .hadiths:
            HadithListView()
        case .sermon:
            SermonListView()
        case .settings:
            SettingsView()
        }
    }
}

enum MenuModule: String, CaseIterable {
    case zikir, imsakiye, alarms, surahs, esma, quran, mosques, zakat, library, hadiths, sermon, settings
}

#Preview {
    MenuView()
}
