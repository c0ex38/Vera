import SwiftUI
#if canImport(GoogleMobileAds)
import GoogleMobileAds
#endif

/// A high-performance SwiftUI wrapper for Google Mobile Ads (AdMob) with Large Adaptive Banner support.
/// Optimized for Google Mobile Ads SDK 11.0+ (Swift-native SPM API).
struct AdBannerView: UIViewRepresentable {
    /// The AdMob Ad Unit ID.
    let adUnitID: String
    
    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        
        #if canImport(GoogleMobileAds)
        // Check for preloaded banner first
        let bannerView: BannerView
        if let preloaded = BannerAdManager.shared.getPreloadedBanner() {
            bannerView = preloaded
            DebugLog.success("AdMob: Reusing preloaded banner.")
        } else {
            // Fallback: Create and load normally
            bannerView = context.coordinator.bannerView
            bannerView.adUnitID = adUnitID
            
            // Calculate Large Adaptive Size (Modern Swift API)
            let allScenes = UIApplication.shared.connectedScenes
            let windowScene = (allScenes.first { $0.activationState == .foregroundActive } ?? allScenes.first) as? UIWindowScene
            if let windowScene = windowScene {
                let adWidth = windowScene.screen.bounds.width
                if adWidth > 0 {
                    bannerView.adSize = largeAnchoredAdaptiveBanner(width: adWidth)
                }
            }
            
            let request = Request()
            let extras = Extras()
            extras.additionalParameters = ["npa": "1"]
            request.register(extras)
            bannerView.load(request)
            DebugLog.log("AdMob: Loading on-demand banner (no preload found).")
        }
        
        // Find the correct WindowScene and RootViewController regardless of activation state during app launch
        let allScenes = UIApplication.shared.connectedScenes
        let windowScene = (allScenes.first { $0.activationState == .foregroundActive } ?? allScenes.first) as? UIWindowScene
        
        if let windowScene = windowScene {
           let window = windowScene.windows.first(where: { $0.isKeyWindow }) ?? windowScene.windows.first
           if let rootVC = window?.rootViewController {
               bannerView.rootViewController = rootVC
           }
        }
        
        // Final fallback if adSize was never set (only for fresh loads)
        if bannerView.adSize.size.width == 0 {
            bannerView.adSize = largeAnchoredAdaptiveBanner(width: 320)
        }
        
        // Add to container and center
        container.addSubview(bannerView)
        container.clipsToBounds = true
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        // Center the banner to prevent it from leaking upwards and overlapping the custom Tab Bar
        NSLayoutConstraint.activate([
            bannerView.topAnchor.constraint(equalTo: container.topAnchor),
            bannerView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            bannerView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            bannerView.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        #endif
        
        return container
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject {
        #if canImport(GoogleMobileAds)
        fileprivate let bannerView = BannerView()
        #endif
        
        override init() {
            super.init()
            #if canImport(GoogleMobileAds)
            bannerView.delegate = self
            #endif
        }
    }
}

#if canImport(GoogleMobileAds)
extension AdBannerView.Coordinator: BannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        DebugLog.success("AdMob: Banner ad received.")
    }
    
    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
        DebugLog.error("AdMob: Failed to load ad: \(error.localizedDescription)")
    }
}
#endif
