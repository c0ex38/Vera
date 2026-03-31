import SwiftUI
#if canImport(GoogleMobileAds)
import GoogleMobileAds
#endif

/// A high-performance SwiftUI wrapper for Google Mobile Ads (AdMob) with Large Adaptive Banner support.
/// Optimized for Google Mobile Ads SDK 11.0+ (Swift-native SPM API).
struct AdBannerView: UIViewRepresentable {
    /// The AdMob Ad Unit ID.
    let adUnitID: String
    
    /// Whether to use the shared preloaded banner from BannerAdManager.
    /// Typically true for the persistent bottom bar, false for on-demand page content.
    var useSharedPreload: Bool = false
    
    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear
        return container
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        #if canImport(GoogleMobileAds)
        // 1. Get the banner (preloaded preferred only if requested)
        let bannerView: BannerView
        if useSharedPreload, let preloaded = BannerAdManager.shared.getPreloadedBanner() {
            bannerView = preloaded
            if bannerView.superview != uiView {
                DebugLog.success("AdMob: Attaching shared preloaded banner to a new view.")
            }
        } else {
            bannerView = context.coordinator.bannerView
            if bannerView.adUnitID == nil {
                bannerView.adUnitID = adUnitID
                bannerView.load(Request())
                DebugLog.log("AdMob: Initializing on-demand banner (\(adUnitID)).")
            }
        }
        
        // 2. Ensure it's in the current container
        if bannerView.superview != uiView {
            // Remove from old parent if any
            bannerView.removeFromSuperview()
            uiView.addSubview(bannerView)
            
            bannerView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                bannerView.centerXAnchor.constraint(equalTo: uiView.centerXAnchor),
                bannerView.centerYAnchor.constraint(equalTo: uiView.centerYAnchor),
                bannerView.widthAnchor.constraint(equalTo: uiView.widthAnchor),
                bannerView.heightAnchor.constraint(equalTo: uiView.heightAnchor)
            ])
        }
        
        // 3. Update RootViewController (Critical for clicks)
        let allScenes = UIApplication.shared.connectedScenes
        if let windowScene = (allScenes.first { $0.activationState == .foregroundActive } ?? allScenes.first) as? UIWindowScene {
            let window = windowScene.windows.first(where: { $0.isKeyWindow }) ?? windowScene.windows.first
            if let rootVC = window?.rootViewController {
                if bannerView.rootViewController != rootVC {
                    bannerView.rootViewController = rootVC
                }
            }
        }
        #endif
    }
    
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
