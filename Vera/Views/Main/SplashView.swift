import SwiftUI

struct SplashView: View {
    @State private var pulseAnimation = false
    
    var body: some View {
        ZStack {
            Color.themeBackground.ignoresSafeArea()
            
            VStack(spacing: 24) {
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.themePrimary)
                    .scaleEffect(pulseAnimation ? 1.05 : 0.95)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: pulseAnimation)
                
                Text("Vera")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundColor(.themeSecondary)
            }
        }
        .onAppear {
            pulseAnimation = true
            #if canImport(GoogleMobileAds)
            AppOpenAdManager.shared.requestAppOpenAd()
            #endif
        }
    }
}

#Preview {
    SplashView()
}
