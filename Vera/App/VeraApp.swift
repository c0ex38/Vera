import SwiftUI
#if canImport(GoogleMobileAds)
import GoogleMobileAds
#endif

@main
struct VeraApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @AppStorage("appTheme") private var appTheme: Int = 0 // 0: System, 1: Light, 2: Dark
    
    @StateObject private var container: DependencyContainer
    @StateObject private var homeViewModel: HomeViewModel
    @StateObject private var adManager = AppOpenAdManager.shared
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
        MobileAds.shared.requestConfiguration.maxAdContentRating = GADMaxAdContentRating.general
        MobileAds.shared.start(completionHandler: nil)
        #endif
        
        #if DEBUG
        print("🚀 Vera Debug Mode Started")
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if !adManager.isSplashFinished {
                    SplashView()
                } else if hasCompletedOnboarding {
                    MainTabView()
                } else {
                    OnboardingView()
                }
            }
            .environmentObject(homeViewModel)
            .environmentObject(container)
            .preferredColorScheme(appTheme == 1 ? ColorScheme.light : (appTheme == 2 ? ColorScheme.dark : nil))
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
