import SwiftUI
#if canImport(GoogleMobileAds)
import GoogleMobileAds
#endif

@main
struct VeraApp: App {
    @StateObject private var container: DependencyContainer
    @StateObject private var homeViewModel: HomeViewModel
    @StateObject private var adManager = AppOpenAdManager.shared
    @ObservedObject private var preferences = PreferenceManager.shared
    @Environment(\.scenePhase) private var scenePhase
    
    init() {
        let container = DependencyContainer()
        self._container = StateObject(wrappedValue: container)
        self._homeViewModel = StateObject(wrappedValue: HomeViewModel(
            prayerService: container.prayerService,
            locationManager: container.location,
            notificationManager: container.notification
        ))
        
        // Google Ads Başlatma ve İçerik Filtreleme
        #if canImport(GoogleMobileAds)
        // Dini uygulamalar için maksimum içerik seviyesini (G: Genel İzleyici) olarak kısıtlama
        let adConfig = MobileAds.shared.requestConfiguration
        adConfig.maxAdContentRating = GADMaxAdContentRating.general
        
        MobileAds.shared.start { _ in
            // Reklam SDK'sı hazır olduğunda banner önyüklemesini başlat
            Task { @MainActor in
                BannerAdManager.shared.preloadAd(adUnitID: AppEnvironment.shared.admobBannerID)
            }
        }
        #endif
        
        #if DEBUG
        DebugLog.log("Vera Debug Mode Started")
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if !adManager.isSplashFinished {
                    SplashView()
                } else if preferences.hasCompletedOnboarding {
                    MainTabView()
                } else {
                    OnboardingView()
                }
            }
            .environmentObject(homeViewModel)
            .environmentObject(container)
            .preferredColorScheme(preferences.appTheme == 1 ? ColorScheme.light : (preferences.appTheme == 2 ? ColorScheme.dark : nil))
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                #if canImport(GoogleMobileAds)
                // Yalnızca arkaplandan gelindiğinde reklam tazelemek istenirse diye burayı koruyoruz
                // Açılış reklamı iş yükünü zaten SplashView üstlendi.
                if adManager.isSplashFinished && !adManager.hasShownAdThisLaunch {
                    AppOpenAdManager.shared.requestAppOpenAd()
                }
                #endif
            }
        }
    }
}
