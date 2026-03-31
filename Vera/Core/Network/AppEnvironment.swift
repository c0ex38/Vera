import Foundation

/// Çevre Değişkenleri Yöneticisi (.env Equivalent Reader)
/// Config.xcconfig içerisindeki gizli ortam değişkenlerini Info.plist üzerinden Type-Safe olarak okur.
struct AppEnvironment: EnvironmentProvider {
    nonisolated static let shared = AppEnvironment()
    
    /// Google AdMob Uygulama Kimliği (App ID)
    let admobAppID: String
    
    /// Google AdMob Afiş Kimliği (Banner Unit ID)
    let admobBannerID: String
    
    /// Google AdMob Açılış Ekranı Reklam Kimliği (App Open Unit ID)
    let admobAppOpenID: String
    
    /// Google AdMob Geçiş Reklamı Kimliği (Interstitial Unit ID)
    let admobInterstitialID: String
    
    /// Ezan Vakti API Ana Sunucu Adresi
    let apiBaseURL: String

    private init() {
        guard let infoDictionary = Bundle.main.infoDictionary else {
            fatalError("Kritik Hata: Info.plist okunamadı. Yapılandırma bozuk.")
        }
        
        self.admobAppID = infoDictionary["GADApplicationIdentifier"] as? String ?? ""
        self.apiBaseURL = infoDictionary["ApiBaseUrl"] as? String ?? ""
        
        #if DEBUG
        // Official Google AdMob Test IDs (iOS)
        // These IDs are safe for use during development and ensure 100% fill rate in simulators.
        debugPrint("AdMob: Running in DEBUG mode. Overriding real IDs with Test IDs.")
        self.admobAppOpenID = "ca-app-pub-3940256099942544/9257395915"
        self.admobBannerID = "ca-app-pub-3940256099942544/2934735716"
        self.admobInterstitialID = "ca-app-pub-3940256099942544/4411468910"
        #else
        self.admobBannerID = infoDictionary["AdMobBannerID"] as? String ?? ""
        self.admobAppOpenID = infoDictionary["AdMobAppOpenID"] as? String ?? ""
        self.admobInterstitialID = infoDictionary["AdMobInterstitialID"] as? String ?? ""
        #endif
        
        #if DEBUG
        if self.admobBannerID.isEmpty || self.apiBaseURL.isEmpty {
            DebugLog.warning("Config.xcconfig değişkenleri (AdMobBannerID veya ApiBaseUrl) boş! Lütfen çevresel yapılandırmaları kontrol edin.")
        }
        #endif
    }
}
