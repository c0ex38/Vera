import SwiftUI
import Foundation
import Combine
#if canImport(GoogleMobileAds)
import GoogleMobileAds
#endif

/// Google AdMob "Geçiş Reklamı" (Interstitial Ad) Yöneticisi
@MainActor
final class InterstitialAdManager: NSObject, ObservableObject {
    static let shared = InterstitialAdManager()
    
    #if canImport(GoogleMobileAds)
    private var interstitialAd: InterstitialAd?
    #endif
    
    @Published var isAdReady = false
    private var isLoadingAd = false
    private var isShowingAd = false
    
    // Sıklık Sınırı (Frequency Capping) Değişkenleri
    private var clickCount = 0
    private let threshold = 5 // Her 5 tıklamada bir göster
    
    private var onDismiss: (() -> Void)?
    
    // Injected Dependencies
    private let environmentProvider: EnvironmentProvider
    
    init(
        environmentProvider: EnvironmentProvider? = nil
    ) {
        self.environmentProvider = environmentProvider ?? AppEnvironment.shared
        super.init()
        loadInterstitial()
    }
    
    /// Reklam yüklemesini başlatır
    func loadInterstitial() {
        #if canImport(GoogleMobileAds)
        if isLoadingAd { return }
        if interstitialAd != nil { return }
        
        isLoadingAd = true
        let request = Request()
        let extras = Extras()
        extras.additionalParameters = ["npa": "1"]
        request.register(extras)
        
        let adUnitID = environmentProvider.admobInterstitialID
        
        InterstitialAd.load(
            with: adUnitID,
            request: request
        ) { ad, error in
            // Swift 6: Closure içinde [weak self] yerine direkt static `shared` 
            // kullanarak "capture" hatalarını önlüyoruz.
            Task { @MainActor in
                let manager = InterstitialAdManager.shared
                manager.isLoadingAd = false
                
                if let error = error {
                    DebugLog.warning("Interstitial Ad Yüklenemedi: \(error.localizedDescription)")
                    manager.isAdReady = false
                    return
                }
                
                manager.interstitialAd = ad
                manager.interstitialAd?.fullScreenContentDelegate = manager
                manager.isAdReady = true
            }
        }
        #endif
    }
    
    /// Reklamı göstermeyi dener (Sıklık sınırı AdMob Panelinden yönetilir)
    /// - Parameter completion: Reklam kapandıktan sonra (veya hiç gösterilmediğinde) çalışacak olan blok
    func showAdIfAvailable(completion: @escaping () -> Void) {
        #if canImport(GoogleMobileAds)
        
        if let ad = interstitialAd {
            if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
               let rootViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
                
                var topController = rootViewController
                while let presented = topController.presentedViewController {
                    topController = presented
                }
                
                self.onDismiss = completion
                ad.present(from: topController)
                return
            }
        } else {
            // Reklam hazır değilse yükle
            loadInterstitial()
        }
        #endif
        completion()
    }
}

#if canImport(GoogleMobileAds)
extension InterstitialAdManager: FullScreenContentDelegate {
    @MainActor
    func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        isShowingAd = true
    }
    
    @MainActor
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        interstitialAd = nil
        isShowingAd = false
        isAdReady = false
        onDismiss?()
        onDismiss = nil
        loadInterstitial() // Bir sonraki için şimdiden yükle
    }
    
    @MainActor
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        interstitialAd = nil
        isShowingAd = false
        isAdReady = false
        onDismiss?()
        onDismiss = nil
        loadInterstitial()
    }
}
#endif
