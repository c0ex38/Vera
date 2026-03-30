import SwiftUI

struct EsmaulHusnaListView: View {
    @StateObject private var viewModel = EsmaulHusnaViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    // Grid Setup
    @State private var columns = UIDevice.current.userInterfaceIdiom == .pad ? [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ] : [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ZStack {
            // Elegant Deep Background
            Color.themeBackground.ignoresSafeArea()
            
            // Subtly Glowing Aura
            RadialGradient(
                colors: [Color.themePrimary.opacity(0.1), .clear],
                center: .top,
                startRadius: 10,
                endRadius: 500
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                VeraCustomHeader(
                    title: L10n.Esma.title,
                    subtitle: L10n.Esma.subtitle,
                    showBackButton: presentationMode.wrappedValue.isPresented
                )
                .padding(.bottom, 10)
                
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.esmaulHusnaList) { esma in
                            NavigationLink(destination: EsmaulHusnaDetailView(esma: esma)) {
                                EsmaulHusnaGridCard(esma: esma)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 120) // Custom TabBar padding
                }
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Şık Grid (Izgara) Kart Tasarımı
struct EsmaulHusnaGridCard: View {
    let esma: EsmaulHusna
    
    var body: some View {
        VStack(spacing: 12) {
            
            // Üst Kısım: Sıra Numarası ve İnce Ayrım
            HStack {
                Text("\(esma.order)")
                    .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 18 : 14, weight: .black, design: .rounded))
                    .foregroundColor(.themePrimary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.themePrimary.opacity(0.15))
                    .clipShape(Capsule())
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
            
            // Orta Kısım: Arapça Hat
            Text(esma.arabic)
                .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 44 : 34, weight: .medium, design: .serif))
                .foregroundColor(.themePrimary) // Altın rengi veya ana tema
                .shadow(color: Color.themePrimary.opacity(0.4), radius: 8, y: 4)
                .multilineTextAlignment(.center)
                .frame(height: 60) // Hizalamayı korumak için sabit yükseklik
            
            // Alt Kısım: Okunuş ve Kısa Anlam
            VStack(spacing: 4) {
                Text(esma.turkishReading)
                    .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 20 : 15, weight: .bold, design: .rounded))
                    .foregroundColor(.themeText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Text(esma.meaningText)
                    .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 15 : 11, weight: .medium, design: .rounded))
                    .foregroundColor(.themeTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(height: UIDevice.current.userInterfaceIdiom == .pad ? 36 : 28) // Uzun/kısa metinlerin zıplamasını önlemek için
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 16)
        }
        // Premium Arkaplan
        .background(Color.themeSurface)
        .cornerRadius(20)
        // İnce sınır çizgisi
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.themePrimary.opacity(0.15), lineWidth: 1)
        )
        // Kart gölgesi
        .shadow(color: .black.opacity(0.04), radius: 10, y: 5)
    }
}

#Preview {
    EsmaulHusnaListView()
}
