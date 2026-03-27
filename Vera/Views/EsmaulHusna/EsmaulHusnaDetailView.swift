import SwiftUI

struct EsmaulHusnaDetailView: View {
    let esma: EsmaulHusna
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color.themeBackground.ignoresSafeArea()
            
            // Premium Aura
            RadialGradient(
                colors: [Color.themePrimary.opacity(0.15), .clear],
                center: .top,
                startRadius: 10,
                endRadius: 500
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                VeraCustomHeader(
                    title: "Esmaül Hüsna Detayı",
                    subtitle: "\(esma.order). İsim",
                    showBackButton: true
                ) {
                    EmptyView()
                }
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // Dev Arapça Şaheser Kartı
                        VStack(spacing: 20) {
                            Text(esma.arabic)
                                .font(.system(size: 80, weight: .bold, design: .serif))
                                .foregroundColor(.themePrimary)
                                .shadow(color: Color.themePrimary.opacity(0.3), radius: 12, y: 8)
                                .multilineTextAlignment(.center)
                                .padding(.top, 24)
                            
                            Text(esma.turkishReading)
                                .font(.system(size: 32, weight: .black, design: .rounded))
                                .foregroundColor(.themeText)
                                .padding(.bottom, 24)
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color.themeSurface)
                        .cornerRadius(30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30, style: .continuous)
                                .stroke(Color.themePrimary.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.05), radius: 15, y: 10)
                        
                        // Kısa Anlamı Kartı
                        InfoBlockCard(icon: "sparkles", title: "Kısa Anlamı", content: esma.meaningText)
                        
                        // Detaylı Açıklaması Kartı (Geniş Okuma Alanı)
                        InfoBlockCard(icon: "text.book.closed.fill", title: "Derin Manası", content: esma.descriptionText)
                        
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 60)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Premium Bilgi Bloğu Kartı
struct InfoBlockCard: View {
    let icon: String
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.themePrimary.opacity(0.15))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.themePrimary)
                }
                
                Text(title)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.themeText)
            }
            
            Text(content)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.themeTextSecondary)
                .lineSpacing(8)
                .fixedSize(horizontal: false, vertical: true) // Tam okunabilirlik
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        // Kart Dokusu
        .background(Color.themeSurface)
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.black.opacity(0.02), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.03), radius: 8, y: 4)
    }
}

#Preview {
    // EsmaulHusnaDetailView(esma: EsmaulHusnaData.all[0])
}
