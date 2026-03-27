import SwiftUI
import Combine
import Foundation
#if canImport(GoogleMobileAds)
import GoogleMobileAds
#endif

/// Google AdMob "Açılış Ekranı" (App Open Ad) Yöneticisi
/// Uygulama ilk başlatıldığında 1 kez reklam göstermek için tasarlanmıştır.
@MainActor
final class AppOpenAdManager: NSObject, ObservableObject {
    static let shared = AppOpenAdManager()
    
    #if canImport(GoogleMobileAds)
    private var appOpenAd: AppOpenAd?
    #endif
    
    private var isLoadingAd = false
    private var isShowingAd = false
    private var loadTime: Date?
    
    // Uygulama yaşam döngüsü boyunca reklamın sadece 1 kere çıkması için
    @Published var hasShownAdThisLaunch = false
    
    // Açılış ekranının bitip asıl uygulamaya geçişini kontrol eder
    @Published var isSplashFinished = false
    
    private override init() {
        super.init()
    }
    
    /// Reklam yüklemesini başlatır. 
    /// Uygulama başlar başlamaz çağrılmalıdır.
    func requestAppOpenAd() {
        #if canImport(GoogleMobileAds)
        if SubscriptionManager.shared.isPro {
            self.isSplashFinished = true
            return
        }
        
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        if !hasCompletedOnboarding {
            // Onboarding tamamlanmadıysa hiç beklemeden Splash'ı bitir ve reklamı es geç
            self.isSplashFinished = true
            return
        }
        
        // Eğer zaten gösterildiyse tekrar yükleme (kullanıcı isteği: sadece açılışta)
        if hasShownAdThisLaunch { 
            self.isSplashFinished = true
            return 
        }
        if isLoadingAd { return }
        if isAdAvailable() { return }
        
        isLoadingAd = true
        
        // Timeout Mechanizmi (En fazla 3 saniye bekle, gelmezse uygulamayı aç)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            guard let self = self else { return }
            if !self.isShowingAd && self.appOpenAd == nil {
                print("⏳ App Open Ad zaman aşımına uğradı, uygulamaya devam ediliyor.")
                self.hasShownAdThisLaunch = true
                self.isSplashFinished = true
            }
        }
        
        let request = Request()
        let adUnitID = AppEnvironment.shared.admobAppOpenID
        
        AppOpenAd.load(
            with: adUnitID,
            request: request
        ) { ad, error in
            Task { @MainActor in
                AppOpenAdManager.shared.handleAdFetchResult(ad, error: error)
            }
        }
        #else
        self.isSplashFinished = true
        #endif
    }
    
    private func handleAdFetchResult(_ ad: AppOpenAd?, error: Error?) {
        self.isLoadingAd = false
        
        if let error = error {
            print("⚠️ App Open Ad Yüklenemedi: \(error.localizedDescription)")
            self.hasShownAdThisLaunch = true
            self.isSplashFinished = true
            return
        }
        
        // Timeout zaten işlediyse ve Splash bittiyse gelen reklamı gösterme!
        if self.isSplashFinished { return }
        
        self.appOpenAd = ad
        self.appOpenAd?.fullScreenContentDelegate = self
        self.loadTime = Date()
        
        // Yüklenir yüklenmez göstermeye çalış (Çünkü açılışta göstermek istiyoruz)
        self.showAdIfAvailable()
    }
    
    /// Reklam hazırsa ekranda gösterir
    func showAdIfAvailable() {
        #if canImport(GoogleMobileAds)
        // İstek: Sadece uygulama açılırken 1 kere çalışsın
        if hasShownAdThisLaunch { return }
        if isShowingAd { return }
        
        if !isAdAvailable() {
            requestAppOpenAd()
            return
        }
        
        guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let rootViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            // UI tam hazır değilse zaman aşımında kendisi zaten geçecek
            return
        }
        
        var topController = rootViewController
        while let presented = topController.presentedViewController {
            topController = presented
        }
        
        isShowingAd = true // Delegate'den önce manuel kilitleme (Çift gösterimi engeller)
        appOpenAd?.present(from: topController)
        #endif
    }
    
    private func isAdAvailable() -> Bool {
        #if canImport(GoogleMobileAds)
        guard appOpenAd != nil, let loadTime = loadTime else { return false }
        // App Open Ads 4 saat geçerlidir, 4 saat geçtiyse zaman aşımına uğramıştır
        return Date().timeIntervalSince(loadTime) < 4 * 3600
        #else
        return false
        #endif
    }
}

#if canImport(GoogleMobileAds)
extension AppOpenAdManager: FullScreenContentDelegate {
    func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        isShowingAd = true
    }
    
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        appOpenAd = nil
        isShowingAd = false
        hasShownAdThisLaunch = true
        isSplashFinished = true
    }
    
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        appOpenAd = nil
        isShowingAd = false
        hasShownAdThisLaunch = true
        isSplashFinished = true
    }
}
#endif
