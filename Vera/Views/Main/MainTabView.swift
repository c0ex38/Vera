import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    private let haptic = UIImpactFeedbackGenerator(style: .soft)
    
    init() {
        // Eski iOS versiyonlarında Native TabBar'ı gizleme garantisi
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Ana İçerik
            TabView(selection: $selectedTab) {
                HomeView()
                    .tag(0)
                    .toolbar(.hidden, for: .tabBar) // iOS 16+
                
                QuranPageView()
                    .tag(1)
                    .toolbar(.hidden, for: .tabBar)
                
                QiblaView()
                    .tag(2)
                    .toolbar(.hidden, for: .tabBar)
                
                ReligiousDaysView()
                    .tag(3)
                    .toolbar(.hidden, for: .tabBar)
                
                MenuView()
                    .tag(4)
                    .toolbar(.hidden, for: .tabBar)
            }
            .padding(.bottom, subscriptionManager.isPro ? 70 : 130) // Layout Pro durumuna göre değişir
            
            // Alt Panel (Tab Bar + Reklam) - Kullanıcı isteğine göre sıralandı
            VStack(spacing: 0) {
                // 1. Özel Tab Bar Butonları (Üstte)
                HStack(spacing: 0) {
                    TabBarButton(icon: "house.fill", title: L10n.Tab.home, isSelected: selectedTab == 0) {
                        switchTo(tab: 0)
                    }
                    TabBarButton(icon: "book.fill", title: L10n.Tab.quran, isSelected: selectedTab == 1) {
                        switchTo(tab: 1)
                    }
                    TabBarButton(icon: "location.north.fill", title: L10n.Tab.qibla, isSelected: selectedTab == 2) {
                        switchTo(tab: 2)
                    }
                    TabBarButton(icon: "calendar.badge.exclamationmark", title: L10n.Tab.religiousDays, isSelected: selectedTab == 3) {
                        switchTo(tab: 3)
                    }
                    TabBarButton(icon: "square.grid.2x2.fill", title: L10n.Tab.menu, isSelected: selectedTab == 4) {
                        switchTo(tab: 4)
                    }
                }
                .padding(.top, 14)
                .padding(.bottom, 12)
                
                // 2. Reklam Katmanı (Sadece Pro Değilse)
                if !subscriptionManager.isPro {
                    ZStack {
                        #if canImport(GoogleMobileAds)
                        AdBannerView(adUnitID: AppEnvironment.shared.admobBannerID)
                            .frame(height: 60)
                            .clipped() // Reklamın etrafa taşmasını yasaklar
                        #else
                        // SDK yoksa yer tutucu
                        VStack(spacing: 2) {
                            Text("Google Ads Alanı")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.themeTextSecondary)
                            Text("(SDK Entegrasyonu Bekleniyor)")
                                .font(.system(size: 8))
                                .foregroundColor(.themeTextSecondary.opacity(0.6))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color.themePrimary.opacity(0.04))
                        #endif
                    }
                    .overlay(
                        Rectangle()
                            .frame(height: 0.5)
                            .foregroundColor(Color.themePrimary.opacity(0.1)),
                        alignment: .top
                    )
                }
                
                // 3. Safe Area (Home Indicator) Alt Boşluğu (En Altta)
                Spacer()
                    .frame(height: 20) // Reklam altta olduğu için bu boşluk biraz azaltıldı
            }
            .background(.ultraThinMaterial)
            .shadow(color: .black.opacity(0.04), radius: 10, y: -5)
            .overlay(
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(Color.themePrimary.opacity(0.15)),
                alignment: .top
            )
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }
    
    private func switchTo(tab: Int) {
        if selectedTab != tab {
            haptic.impactOccurred()
            // Make page navigation absolutely instantaneous (0ms lag)
            selectedTab = tab
        }
    }
}

struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 21, weight: isSelected ? .bold : .medium))
                    .scaleEffect(isSelected ? 1.15 : 0.95)
                    .foregroundColor(isSelected ? .themePrimary : .themeTextSecondary.opacity(0.45))
                
                if isSelected {
                    Text(title)
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(.themePrimary)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            // Preserve the smooth icon scaling and text transition only for the button itself
            .animation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.5), value: isSelected)
        }
    }
}
