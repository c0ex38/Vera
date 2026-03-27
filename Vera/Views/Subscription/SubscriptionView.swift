import SwiftUI
import StoreKit

struct SubscriptionView: View {
    @StateObject private var storeManager = SubscriptionManager.shared
    @Environment(\.dismiss) var dismiss
    @State private var showDemoProducts = false
    
    var body: some View {
        ZStack {
            // Arkaplan
            Color.themeBackground.ignoresSafeArea()
            
            // Üst Gradient Işığı
            RadialGradient(
                colors: [Color.themePrimary.opacity(0.1), .clear],
                center: .top,
                startRadius: 0,
                endRadius: 500
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Kapat Butonu
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.themeTextSecondary.opacity(0.5))
                    }
                    Spacer()
                    Button("Geri Yükle") {
                        Task { await storeManager.restorePurchases() }
                    }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.themePrimary)
                }
                .padding(.horizontal, 20)
                
                // Header
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.themePrimary.opacity(0.1))
                            .frame(width: 80, height: 80)
                        Image(systemName: "crown.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.yellow)
                            .shadow(color: .yellow.opacity(0.5), radius: 10)
                    }
                    
                    Text("Vera Pro'ya Geç")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundColor(.themeText)
                    
                    Text("İbadetlerinize reklamsız ve kesintisiz odaklanın.")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.themeTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                // Özellikler
                VStack(alignment: .leading, spacing: 16) {
                    ProFeatureRow(icon: "nosign", title: "Sıfır Reklam", subtitle: "Tüm banner ve açılış reklamları kalkar.")
                    ProFeatureRow(icon: "heart.fill", title: "Uygulamaya Destek", subtitle: "Geliştiricileri destekleyin ve reklamsız kullanın.")
                }
                .padding(24)
                .background(Color.themeSurface.opacity(0.5))
                .cornerRadius(24)
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Abonelik Seçenekleri
                if storeManager.isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Ürünler yükleniyor...")
                            .font(.system(size: 14))
                            .foregroundColor(.themeTextSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else if let error = storeManager.fetchError {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.orange)
                        
                        Text(error)
                            .font(.system(size: 14))
                            .foregroundColor(.themeTextSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button(action: {
                            Task { await storeManager.fetchProducts() }
                        }) {
                            Text("Tekrar Dene")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 24)
                                .background(Color.themePrimary)
                                .cornerRadius(12)
                        }
                        
                        #if DEBUG
                        Button("Demo Modunda Göster (Geliştirici)") {
                            // Gerçek ürünler gelmiyorsa bile tasarımı görmeniz için 
                            // manager'da boş olmayan bir liste varmış gibi davranacağız
                            // SubscriptionManager'da Product init edilemediği için 
                            // View üzerinde bir preview modu ekleyebiliriz.
                            showDemoProducts = true
                        }
                        .font(.system(size: 12))
                        .foregroundColor(.themePrimary)
                        .padding(.top, 8)
                        #endif
                    }
                    .padding(.vertical, 20)
                } else if showDemoProducts {
                    // Demo Modu Ürünleri
                    VStack(spacing: 12) {
                        DemoProductRow(title: "Vera Pro Aylık (Demo)", price: "₺39,99", description: "Aylık ödeme planı")
                        DemoProductRow(title: "Vera Pro Yıllık (Demo)", price: "₺399,99", description: "Yıllık avantajlı plan", isYearly: true)
                    }
                    .padding(.horizontal, 24)
                } else {
                    VStack(spacing: 12) {
                        ForEach(storeManager.products.sorted(by: { $0.price < $1.price })) { product in
                            Button(action: {
                                Task {
                                    if try await storeManager.purchase(product) {
                                        dismiss()
                                    }
                                }
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(product.displayName)
                                            .font(.system(size: 18, weight: .bold))
                                        Text(product.description)
                                            .font(.system(size: 12))
                                            .foregroundColor(.themeTextSecondary)
                                    }
                                    Spacer()
                                    Text(product.displayPrice)
                                        .font(.system(size: 18, weight: .black))
                                }
                                .padding(20)
                                .background(
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(product.id.contains("yearly") ? Color.themePrimary.opacity(0.1) : Color.themeSurface)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 18)
                                                .stroke(product.id.contains("yearly") ? Color.themePrimary : Color.clear, lineWidth: 2)
                                        )
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 24)
                }
                
                // Alt Bilgi
                Text("İstediğiniz zaman App Store üzerinden iptal edebilirsiniz.")
                    .font(.system(size: 12))
                    .foregroundColor(.themeTextSecondary)
                    .padding(.bottom, 10)
            }
            .padding(.top, 20)
        }
        .task {
            // Görünüm açıldığında ürünleri tekrar çekelim (Garanti olsun)
            await storeManager.fetchProducts()
        }
    }
}

struct ProFeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.themePrimary)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.themeText)
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.themeTextSecondary)
            }
        }
    }
}

struct DemoProductRow: View {
    let title: String
    let price: String
    let description: String
    var isYearly: Bool = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(.themeTextSecondary)
            }
            Spacer()
            Text(price)
                .font(.system(size: 18, weight: .black))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(isYearly ? Color.themePrimary.opacity(0.1) : Color.themeSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(isYearly ? Color.themePrimary : Color.clear, lineWidth: 2)
                )
        )
    }
}
