import SwiftUI
import Combine
import Foundation
#if canImport(GoogleMobileAds)
import GoogleMobileAds
#endif

/// A singleton manager to preload and reuse AdMob Banner views to eliminate latency.
@MainActor
final class BannerAdManager: NSObject, ObservableObject {
    static let shared = BannerAdManager()
    
    #if canImport(GoogleMobileAds)
    private var preloadedBanner: BannerView?
    #endif
    
    private var adUnitID: String?
    private var isLoading = false
    
    private override init() {
        super.init()
    }
    
    /// Starts preloading the banner ad as early as possible.
    func preloadAd(adUnitID: String) {
        #if canImport(GoogleMobileAds)
        guard self.adUnitID == nil else { return }
        self.adUnitID = adUnitID
        
        if isLoading || preloadedBanner != nil { return }
        isLoading = true
        
        let bannerView = BannerView()
        bannerView.adUnitID = adUnitID
        bannerView.delegate = self
        
        // Use a default responsive size for preloading
        let screenWidth = UIScreen.main.bounds.width
        bannerView.adSize = inlineAdaptiveBanner(width: screenWidth, maxHeight: 60)
        
        let request = Request()
        let extras = Extras()
        extras.additionalParameters = ["npa": "1"]
        request.register(extras)
        
        DebugLog.log("AdMob: Preloading banner ad started for \(adUnitID)...")
        bannerView.load(request)
        self.preloadedBanner = bannerView
        #endif
    }
    
    /// Returns the preloaded banner if available.
    #if canImport(GoogleMobileAds)
    func getPreloadedBanner() -> BannerView? {
        return preloadedBanner
    }
    #endif
}

#if canImport(GoogleMobileAds)
extension BannerAdManager: BannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        isLoading = false
        DebugLog.success("AdMob: Preloaded banner ad received successfully.")
    }
    
    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
        isLoading = false
        DebugLog.warning("AdMob: Failed to preload banner: \(error.localizedDescription)")
        // Reset so it can try again if requested later
        self.preloadedBanner = nil
        self.adUnitID = nil
    }
}
#endif
