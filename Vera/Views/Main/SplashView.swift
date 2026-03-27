import SwiftUI

struct SplashView: View {
    @State private var iconScale: CGFloat = 0.5
    @State private var textOpacity: Double = 0.0
    @State private var taglineOpacity: Double = 0.0
    @State private var taglineOffset: CGFloat = 10
    @State private var backgroundGradient = false
    
    var body: some View {
        ZStack {
            // Premium Hareketli Arkaplan
            LinearGradient(
                colors: [
                    Color.themeBackground,
                    backgroundGradient ? Color.themePrimary.opacity(0.12) : Color.themeBackground,
                    Color.themeBackground
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                    backgroundGradient.toggle()
                }
            }
            
            VStack(spacing: 32) {
                // Glassmorphic Logo Konteyneri
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 140, height: 140)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: Color.themePrimary.opacity(0.2), radius: 20)
                    
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.themePrimary)
                        .shadow(color: Color.themePrimary.opacity(0.4), radius: 10)
                }
                .scaleEffect(iconScale)
                .rotation3DEffect(
                    .degrees(backgroundGradient ? 10 : -10),
                    axis: (x: 1, y: 1, z: 0)
                )
                
                VStack(spacing: 12) {
                    // Uygulama İsmi
                    Text("Vera")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundColor(.themePrimary)
                        .tracking(2)
                        .opacity(textOpacity)
                        .shadow(color: .black.opacity(0.1), radius: 5, y: 5)
                    
                    // Slogan
                    Text("Huzura Açılan Kapı")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.themeTextSecondary)
                        .opacity(taglineOpacity)
                        .offset(y: taglineOffset)
                        .tracking(1.5)
                }
            }
        }
        .onAppear {
            // Sıralı Animasyon Dizisi
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                iconScale = 1.0
            }
            
            withAnimation(.easeOut(duration: 1.0).delay(0.4)) {
                textOpacity = 1.0
            }
            
            withAnimation(.easeOut(duration: 0.8).delay(0.8)) {
                taglineOpacity = 1.0
                taglineOffset = 0
            }
            
            #if canImport(GoogleMobileAds)
            // Reklam isteği arka planda başlasın
            AppOpenAdManager.shared.requestAppOpenAd()
            #endif
        }
    }
}

#Preview {
    SplashView()
}
