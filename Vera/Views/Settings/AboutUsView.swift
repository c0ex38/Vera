import SwiftUI

struct AboutUsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            VeraCustomHeader(title: "Hakkımızda", subtitle: "Vera Uygulaması") {
                presentationMode.wrappedValue.dismiss()
            }
            
            ScrollView {
                VStack(spacing: 32) {
                    // Logo ve Başlık
                    VStack(spacing: 16) {
                        Image(systemName: "moon.stars.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.themePrimary)
                            .shadow(color: .themePrimary.opacity(0.3), radius: 10, y: 5)
                        
                        Text("Vera")
                            .font(.system(size: 40, weight: .black, design: .rounded))
                            .foregroundColor(.themePrimary)
                        
                        Text("Sadelik ve Huşu")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.themeTextSecondary)
                            .tracking(2)
                    }
                    .padding(.top, 40)
                    
                    // Misyonumuz
                    VStack(alignment: .leading, spacing: 12) {
                        Label {
                            Text("Misyonumuz")
                                .font(.headline)
                                .foregroundColor(.themePrimary)
                        } icon: {
                            Image(systemName: "hand.raised.fill")
                                .foregroundColor(.themePrimary)
                        }
                        
                        Text("Vera, İslami pratiklerinizi günümüz dijital alışkanlıklarıyla harmanlayarak, en sade ve en şık arayüzle size sunmayı hedefler. Amacımız, ibadetlerinizi takip ederken dikkatinizi dağıtmayan, huzurlu bir dijital deneyim sunmaktır.")
                            .font(.system(size: 15))
                            .foregroundColor(.themeText)
                            .lineSpacing(6)
                    }
                    .padding(20)
                    .background(Color.themeSurface)
                    .cornerRadius(20)
                    .padding(.horizontal)
                    
                    // Öne Çıkan Özellikler
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Neler Sunuyoruz?")
                            .font(.headline)
                            .foregroundColor(.themePrimary)
                            .padding(.leading, 8)
                        
                        FeatureRow(icon: "clock.fill", title: "Hassas Vakitler", description: "Diyanet verileriyle tam uyumlu namaz vakitleri.")
                        FeatureRow(icon: "book.fill", title: "Kuran-ı Kerim", description: "Farklı mealler ve kullanıcı dostu okuma deneyimi.")
                        FeatureRow(icon: "location.north.fill", title: "Canlı Kıble", description: "Hassas sensörlerle en doğru kıble yönü.")
                        FeatureRow(icon: "banknote.fill", title: "Zekat Hesabı", description: "Güncel fetvalara uygun kolay hesaplama motoru.")
                    }
                    .padding(.horizontal)
                    
                    // Teknik Bilgiler ve İletişim
                    VStack(spacing: 12) {
                        InfoRow(title: "Versiyon", value: "1.0.0")
                        InfoRow(title: "Geliştirici", value: "Vera Team")
                        InfoRow(title: "Veri Kaynağı", value: "Diyanet İşleri")
                        InfoRow(title: "E-Posta", value: "info@verapp.com")
                    }
                    .padding(20)
                    .background(Color.themeSurface)
                    .cornerRadius(20)
                    .padding(.horizontal)
                    
                    Text("© 2026 Vera App. Tüm Hakları Saklıdır.")
                        .font(.system(size: 12))
                        .foregroundColor(.themeTextSecondary)
                        .padding(.bottom, 40)
                }
            }
            .background(Color.themeBackground)
        }
        .navigationBarHidden(true)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.themePrimary)
                .frame(width: 44, height: 44)
                .background(Color.themePrimary.opacity(0.1))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.themeText)
                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(.themeTextSecondary)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.themeSurface)
        .cornerRadius(16)
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.themeTextSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.themeText)
        }
    }
}
