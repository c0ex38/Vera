import Foundation

/// Çevre Değişkenleri Yöneticisi (.env Equivalent Reader)
/// Config.xcconfig içerisindeki gizli ortam değişkenlerini Info.plist üzerinden Type-Safe olarak okur.
struct AppEnvironment: EnvironmentProvider {
    static let shared = AppEnvironment()
    
    /// Google AdMob Uygulama Kimliği (App ID)
    let admobAppID: String
    
    /// Google AdMob Afiş Kimliği (Banner Unit ID)
    let admobBannerID: String
    
    /// Google AdMob Açılış Ekranı Reklam Kimliği (App Open Unit ID)
    let admobAppOpenID: String
    
    /// Ezan Vakti API Ana Sunucu Adresi
    let apiBaseURL: String

    private init() {
        guard let infoDictionary = Bundle.main.infoDictionary else {
            fatalError("Kritik Hata: Info.plist okunamadı. Yapılandırma bozuk.")
        }
        
        self.admobAppID = infoDictionary["GADApplicationIdentifier"] as? String ?? ""
        self.admobBannerID = infoDictionary["AdMobBannerID"] as? String ?? ""
        self.admobAppOpenID = infoDictionary["AdMobAppOpenID"] as? String ?? "ca-app-pub-3565786409265176/2231812288"
        self.apiBaseURL = infoDictionary["ApiBaseUrl"] as? String ?? ""
        
        #if DEBUG
        if self.admobBannerID.isEmpty || self.apiBaseURL.isEmpty {
            print("⚠️ UYARI: Config.xcconfig değişkenleri (AdMobBannerID veya ApiBaseUrl) boş! Lütfen çevresel yapılandırmaları kontrol edin.")
        }
        #endif
    }
}
