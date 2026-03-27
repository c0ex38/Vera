import SwiftUI

struct AboutUsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            VeraCustomHeader(title: "Hakkımızda", subtitle: "Vera Uygulaması") {
                presentationMode.wrappedValue.dismiss()
            }
            
            ScrollView {
                VStack(spacing: UIDevice.current.userInterfaceIdiom == .pad ? 48 : 32) {
                    // Logo ve Başlık
                    VStack(spacing: 16) {
                        Image(systemName: "moon.stars.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? 120 : 80, height: UIDevice.current.userInterfaceIdiom == .pad ? 120 : 80)
                            .foregroundColor(.themePrimary)
                            .shadow(color: .themePrimary.opacity(0.3), radius: 10, y: 5)
                        
                        Text("Vera")
                            .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 60 : 40, weight: .black, design: .rounded))
                            .foregroundColor(.themePrimary)
                        
                        Text("Sadelik ve Huşu")
                            .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 24 : 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.themeTextSecondary)
                            .tracking(2)
                    }
                    .padding(.top, 40)
                    
                    // Misyonumuz
                    VStack(alignment: .leading, spacing: 12) {
                        Label {
                            Text("Misyonumuz")
                                .font(UIDevice.current.userInterfaceIdiom == .pad ? .title2.bold() : .headline)
                                .foregroundColor(.themePrimary)
                        } icon: {
                            Image(systemName: "hand.raised.fill")
                                .foregroundColor(.themePrimary)
                        }
                        
                        Text("Vera, İslami pratiklerinizi günümüz dijital alışkanlıklarıyla harmanlayarak, en sade ve en şık arayüzle size sunmayı hedefler. Amacımız, ibadetlerinizi takip ederken dikkatinizi dağıtmayan, huzurlu bir dijital deneyim sunmaktır.")
                            .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 20 : 15))
                            .foregroundColor(.themeText)
                            .lineSpacing(UIDevice.current.userInterfaceIdiom == .pad ? 8 : 6)
                    }
                    .padding(UIDevice.current.userInterfaceIdiom == .pad ? 32 : 20)
                    .background(Color.themeSurface)
                    .cornerRadius(UIDevice.current.userInterfaceIdiom == .pad ? 28 : 20)
                    .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 40 : 20)
                    
                    // Öne Çıkan Özellikler
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Neler Sunuyoruz?")
                            .font(UIDevice.current.userInterfaceIdiom == .pad ? .title2.bold() : .headline)
                            .foregroundColor(.themePrimary)
                            .padding(.leading, 8)
                        
                        let columns = [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ]
                        
                        if UIDevice.current.userInterfaceIdiom == .pad {
                            LazyVGrid(columns: columns, spacing: 16) {
                                features
                            }
                        } else {
                            VStack(spacing: 12) {
                                features
                            }
                        }
                    }
                    .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 40 : 20)
                    
                    // Teknik Bilgiler ve İletişim
                    VStack(spacing: 16) {
                        InfoRow(title: "Versiyon", value: "1.0.0")
                        InfoRow(title: "Geliştirici", value: "Vera Team")
                    }
                    .padding(UIDevice.current.userInterfaceIdiom == .pad ? 32 : 20)
                    .background(Color.themeSurface)
                    .cornerRadius(UIDevice.current.userInterfaceIdiom == .pad ? 28 : 20)
                    .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 40 : 20)
                    
                    Text("© 2026 Vera App. Tüm Hakları Saklıdır.")
                        .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 16 : 12))
                        .foregroundColor(.themeTextSecondary)
                        .padding(.bottom, 40)
                }
            }
            .background(Color.themeBackground)
        }
        .navigationBarHidden(true)
    }
    
    @ViewBuilder
    private var features: some View {
        FeatureRow(icon: "clock.fill", title: "Hassas Vakitler", description: "Diyanet verileriyle tam uyumlu namaz vakitleri.")
        FeatureRow(icon: "book.fill", title: "Kuran-ı Kerim", description: "Farklı mealler ve kullanıcı dostu okuma deneyimi.")
        FeatureRow(icon: "location.north.fill", title: "Canlı Kıble", description: "Hassas sensörlerle en doğru kıble yönü.")
        FeatureRow(icon: "banknote.fill", title: "Zekat Hesabı", description: "Güncel fetvalara uygun kolay hesaplama motoru.")
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 24 : 20))
                .foregroundColor(.themePrimary)
                .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? 56 : 44, height: UIDevice.current.userInterfaceIdiom == .pad ? 56 : 44)
                .background(Color.themePrimary.opacity(0.1))
                .cornerRadius(UIDevice.current.userInterfaceIdiom == .pad ? 16 : 12)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 18 : 15, weight: .bold))
                    .foregroundColor(.themeText)
                Text(description)
                    .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 15 : 13))
                    .foregroundColor(.themeTextSecondary)
            }
        }
        .padding(UIDevice.current.userInterfaceIdiom == .pad ? 16 : 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.themeSurface)
        .cornerRadius(UIDevice.current.userInterfaceIdiom == .pad ? 20 : 16)
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 18 : 14, weight: .medium))
                .foregroundColor(.themeTextSecondary)
            Spacer()
            Text(value)
                .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 18 : 14, weight: .bold))
                .foregroundColor(.themeText)
        }
    }
}
