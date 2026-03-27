import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: HomeViewModel
    @StateObject private var countdownManager = PrayerCountdownManager()
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    
    @AppStorage("savedDistrictID") private var savedDistrictID: String = ""
    @AppStorage("savedLocationName") private var savedLocationName: String = ""
    
    @State private var showSettings = false
    @State private var showPicker = false
    @State private var showImsakiye = false
    @State private var animateOrbs = false
    @State private var currentSuggestion: HomeSuggestion?
    
    // Sistem uykudan uyanma takibi
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.themeBackground.ignoresSafeArea()
                
                // Nefes Alan Ambiyans Arkaplanı (Living Background)
                GeometryReader { geo in
                    ZStack {
                        // Üst sağ parlama (Güneş/Ay teması)
                        Circle()
                            .fill(RadialGradient(colors: [Color.themePrimary.opacity(0.4), .clear], center: .center, startRadius: 0, endRadius: geo.size.width * 0.8))
                            .frame(width: geo.size.width * 1.2, height: geo.size.width * 1.2)
                            .offset(x: animateOrbs ? geo.size.width * 0.3 : geo.size.width * 0.5, y: animateOrbs ? -100 : -50)
                            .blur(radius: 80)
                        
                        // Alt sol sıcak parlama
                        Circle()
                            .fill(RadialGradient(colors: [Color.orange.opacity(0.25), .clear], center: .center, startRadius: 0, endRadius: geo.size.width * 0.7))
                            .frame(width: geo.size.width * 1.1, height: geo.size.width * 1.1)
                            .offset(x: animateOrbs ? -100 : -150, y: animateOrbs ? geo.size.height * 0.4 : geo.size.height * 0.5)
                            .blur(radius: 80)
                    }
                    .onAppear {
                        withAnimation(.easeInOut(duration: 8.0).repeatForever(autoreverses: true)) {
                            animateOrbs = true
                        }
                    }
                }
                .ignoresSafeArea()
                
                if viewModel.state == .success {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 32) { // Daha ferah bir genel boşluk
                            headerView
                            VeraHeroCard(countdownManager: countdownManager, animateOrbs: animateOrbs)
                            QuickActionsGrid()
                            
                            VStack(spacing: 16) {
                                HStack {
                                    Text(L10n.Home.title)
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                        .foregroundColor(.themeText)
                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                                
                                timesGrid
                                imsakiyeButton
                                
                                // Vakitler Altı Reklam Alanı (Sadece Pro Değilse)
                                if !subscriptionManager.isPro {
                                    #if canImport(GoogleMobileAds)
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text(L10n.Home.sponsored)
                                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                                .foregroundColor(.themeTextSecondary.opacity(0.7))
                                                .kerning(1.0)
                                            Spacer()
                                        }
                                        .padding(.horizontal, 24)
                                        
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                .fill(Color.themeSurface.opacity(0.4))
                                            
                                            AdBannerView(adUnitID: AppEnvironment.shared.admobBannerID)
                                                .padding(.vertical, 8)
                                                .frame(minHeight: 60)
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.top, 8)
                                    #endif
                                }
                            }
                            
                            if let suggestion = currentSuggestion {
                                DiscoveryCard(suggestion: suggestion)
                            }
                            
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 140) // Custom TabBar boşluğu garantisi
                    }
                } else if viewModel.state == .requestingLocation || viewModel.state == .matchingAPI {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text(L10n.Home.loading)
                            .font(.headline)
                            .foregroundColor(.themeTextSecondary)
                    }
                } else if case .error(let msg) = viewModel.state {
                    ErrorStateView(
                        iconName: "exclamationmark.triangle.fill",
                        message: msg,
                        buttonTitle: L10n.Home.retry,
                        action: {
                            viewModel.fetchSavedLocationTimes(districtID: savedDistrictID, locationName: savedLocationName)
                        }
                    )
                } else {
                    ProgressView() // Idle
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showSettings) {
                NavigationView {
                    SettingsView()
                }
                .navigationViewStyle(.stack)
            }
            .sheet(isPresented: $showPicker, onDismiss: {
                if !savedDistrictID.isEmpty {
                    viewModel.fetchSavedLocationTimes(districtID: savedDistrictID, locationName: savedLocationName)
                }
            }) {
                LocationPickerView()
            }
            .sheet(isPresented: $showImsakiye) {
                MonthlyImsakiyeView()
            }
            .onAppear {
                if currentSuggestion == nil {
                    currentSuggestion = HomeSuggestion.random()
                }
                
                if !savedDistrictID.isEmpty && viewModel.prayerTimes.isEmpty {
                    viewModel.fetchSavedLocationTimes(districtID: savedDistrictID, locationName: savedLocationName)
                } else if let today = viewModel.todayPrayerTime {
                    countdownManager.startCountdown(with: today)
                }
            }
            .onChange(of: viewModel.prayerTimes) { _, _ in
                if let today = viewModel.todayPrayerTime {
                    countdownManager.startCountdown(with: today)
                }
            }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active, let today = viewModel.todayPrayerTime {
                    countdownManager.startCountdown(with: today)
                }
            }
        }
        .navigationViewStyle(.stack)
    }
    
    // MARK: - Subviews
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                // Lokasyon Kapsülü (Premium Pill)
                Button(action: { showPicker = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 14))
                        Text(viewModel.resolvedLocationName.isEmpty ? savedLocationName : viewModel.resolvedLocationName)
                            .font(.system(size: 15, weight: .bold))
                            .lineLimit(1)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .bold))
                            .opacity(0.6)
                    }
                    .foregroundColor(.themePrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.themePrimary.opacity(0.12))
                    .clipShape(Capsule())
                }
                
                // Zarif Tarih Formatı
                if let today = viewModel.todayPrayerTime {
                    Text("\(today.hijriDateLong ?? "") • \(today.gregorianDateLong ?? "")")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.themeTextSecondary)
                        .padding(.leading, 6)
                }
            }
            
            Spacer()
            
            // Ayarlar Butonu
            Button(action: { showSettings = true }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.themeTextSecondary)
                    .frame(width: 48, height: 48)
                    .background(Color.themeSurface)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.05), radius: 8, y: 3)
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var timesGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 14), count: UIDevice.current.userInterfaceIdiom == .pad ? 6 : 3), spacing: 14) {
            if let today = viewModel.todayPrayerTime {
                CompactPrayerCell(title: L10n.Prayer.imsak, time: today.imsakTime, isActive: countdownManager.nextPrayerName == "İmsak")
                CompactPrayerCell(title: L10n.Prayer.sunrise, time: today.sunrise, isActive: countdownManager.nextPrayerName == "Güneş")
                CompactPrayerCell(title: L10n.Prayer.dhuhr, time: today.dhuhr, isActive: countdownManager.nextPrayerName == "Öğle")
                CompactPrayerCell(title: L10n.Prayer.asr, time: today.asr, isActive: countdownManager.nextPrayerName == "İkindi")
                CompactPrayerCell(title: L10n.Prayer.maghrib, time: today.maghrib, isActive: countdownManager.nextPrayerName == "Akşam")
                CompactPrayerCell(title: L10n.Prayer.isha, time: today.isha, isActive: countdownManager.nextPrayerName == "Yatsı")
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var imsakiyeButton: some View {
        Button(action: { showImsakiye = true }) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 18, weight: .semibold))
                Text(L10n.Home.monthlyImsakiye)
                    .font(.system(size: 15, weight: .bold))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundColor(.themePrimary)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.themePrimary.opacity(0.1))
            .cornerRadius(20)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
}


// Preview stub if needed
#Preview {
    HomeView()
}
