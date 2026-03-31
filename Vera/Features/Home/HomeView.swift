import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: HomeViewModel
    @StateObject private var countdownManager = PrayerCountdownManager()
    
    // Centralized preferences
    private let preferences = PreferenceManager.shared
    
    @State private var showSettings = false
    @State private var showPicker = false
    @State private var showImsakiye = false
    
    // Recovery for app reactivation
    @Environment(\.scenePhase) var scenePhase
    
    // MARK: - Computed Properties
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let weekday = Calendar.current.component(.weekday, from: Date())
        
        // Friday special
        if weekday == 6 && hour >= 6 && hour < 15 {
            return L10n.Home.greetingFriday
        }
        
        switch hour {
        case 5..<12: return L10n.Home.greetingMorning
        case 12..<18: return L10n.Home.greetingDay
        case 18..<22: return L10n.Home.greetingEvening
        default: return L10n.Home.greetingNight
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.themeBackground.ignoresSafeArea()
                
                // Zarif Statik Arkaplan (Ambient Glow)
                ZStack {
                    Circle()
                        .fill(Color.themePrimary.opacity(0.12))
                        .frame(width: 400, height: 400)
                        .blur(radius: 80)
                        .offset(x: 150, y: -200)
                    
                    Circle()
                        .fill(Color.orange.opacity(0.08))
                        .frame(width: 300, height: 300)
                        .blur(radius: 60)
                        .offset(x: -100, y: 300)
                }
                .ignoresSafeArea()
                
                if viewModel.state == .success {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 32) { // Spacing refined
                            headerView
                            VeraHeroCard(countdownManager: countdownManager)
                            
                            if let hadith = viewModel.hadithOfTheDay {
                                HadithCard(hadith: hadith)
                            }
                            
                            VStack(spacing: 20) {
                                HStack(alignment: .bottom) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(L10n.Home.title)
                                            .font(.system(size: 22, weight: .bold, design: .rounded))
                                            .foregroundStyle(.themeText)
                                        
                                        Rectangle()
                                            .fill(Color.themePrimary.opacity(0.3))
                                            .frame(width: 40, height: 4)
                                            .clipShape(.rect(cornerRadius: 2))
                                    }
                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                                
                                timesGrid
                                imsakiyeButton
                                
                                // Ad Section
                                #if canImport(GoogleMobileAds)
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text(L10n.Home.sponsored)
                                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                                .foregroundStyle(.themeTextSecondary.opacity(0.7))
                                                .kerning(1.0)
                                            Spacer()
                                        }
                                        .padding(.horizontal, 24)
                                        
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                                .fill(Color.themeSurface.opacity(0.4))
                                            
                                            AdBannerView(adUnitID: AppEnvironment.shared.admobBannerID, useSharedPreload: false)
                                                .padding(.vertical, 8)
                                                .frame(minHeight: 60)
                                        }
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                                .stroke(Color.themePrimary.opacity(0.05), lineWidth: 1)
                                        )
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.top, 8)
                                #endif
                            }
                            
                            DiscoverySection()
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 140)
                    }
                } else if viewModel.state == .requestingLocation || viewModel.state == .matchingAPI {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text(L10n.Home.loading)
                            .font(.headline)
                            .foregroundStyle(.themeTextSecondary)
                    }
                } else if case .error(let msg) = viewModel.state {
                    ErrorStateView(
                        iconName: "exclamationmark.triangle.fill",
                        message: msg,
                        buttonTitle: L10n.Home.retry,
                        action: {
                            viewModel.fetchSavedLocationTimes(districtID: preferences.savedDistrictID, locationName: preferences.savedLocationName)
                        }
                    )
                } else {
                    ProgressView()
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showSettings) {
                NavigationStack { SettingsView() }
            }
            .sheet(isPresented: $showPicker, onDismiss: {
                if !preferences.savedDistrictID.isEmpty {
                    viewModel.fetchSavedLocationTimes(districtID: preferences.savedDistrictID, locationName: preferences.savedLocationName)
                }
            }) {
                LocationPickerView()
            }
            .sheet(isPresented: $showImsakiye) {
                MonthlyImsakiyeView()
            }
            .onAppear {
                if !preferences.savedDistrictID.isEmpty && viewModel.prayerTimes.isEmpty {
                    viewModel.fetchSavedLocationTimes(districtID: preferences.savedDistrictID, locationName: preferences.savedLocationName)
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
    }
    
    // MARK: - Subviews
    private var headerView: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(.themeText)
                
                // Location Button
                Button(action: { showPicker = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 10))
                        Text(viewModel.resolvedLocationName.isEmpty ? preferences.savedLocationName : viewModel.resolvedLocationName)
                            .font(.system(size: 14, weight: .bold))
                            .lineLimit(1)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                            .opacity(0.8)
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.themePrimary)
                    .clipShape(Capsule())
                    .shadow(color: .themePrimary.opacity(0.3), radius: 5, y: 3)
                }
            }
            
            Spacer()
            
            // Settings Icon Circle
            Button(action: { showSettings = true }) {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.themeText)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.themeSurface)
                            .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 5)
                    )
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var timesGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: UIDevice.current.userInterfaceIdiom == .pad ? 6 : 3), spacing: 12) {
            if let today = viewModel.todayPrayerTime {
                CompactPrayerCell(type: .imsak, time: today.imsakTime, isActive: countdownManager.nextPrayer == .imsak)
                CompactPrayerCell(type: .sunrise, time: today.sunrise, isActive: countdownManager.nextPrayer == .sunrise)
                CompactPrayerCell(type: .dhuhr, time: today.dhuhr, isActive: countdownManager.nextPrayer == .dhuhr)
                CompactPrayerCell(type: .asr, time: today.asr, isActive: countdownManager.nextPrayer == .asr)
                CompactPrayerCell(type: .maghrib, time: today.maghrib, isActive: countdownManager.nextPrayer == .maghrib)
                CompactPrayerCell(type: .isha, time: today.isha, isActive: countdownManager.nextPrayer == .isha)
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
            .foregroundStyle(.themePrimary)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.themePrimary.opacity(0.1))
            .clipShape(.rect(cornerRadius: 20))
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
}


// Preview stub if needed
#Preview {
    HomeView()
}
