import SwiftUI

struct ReligiousDaysView: View {
    @StateObject private var viewModel = ReligiousDaysViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    @State private var appearedItems: Set<UUID> = []
    
    var body: some View {
        ZStack {
            // Premium Arkaplan: Yumuşak Gradyan ve Derinlik
            LinearGradient(
                colors: [
                    Color.themeBackground,
                    Color.themePrimary.opacity(0.05),
                    Color.themeBackground
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Premium Standart Başlık
                VeraCustomHeader(
                    title: "Dini Günler",
                    subtitle: "2026 Özel Takvimi",
                    showBackButton: presentationMode.wrappedValue.isPresented
                )
                .padding(.bottom, 8)
                
                // Timeline Listesi
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(viewModel.days.enumerated()), id: \.element.id) { index, day in
                            ReligiousTimelineCell(
                                day: day,
                                isLast: index == viewModel.days.count - 1,
                                index: index
                            )
                            .opacity(appearedItems.contains(day.id) ? 1 : 0)
                            .offset(y: appearedItems.contains(day.id) ? 0 : 20)
                            .onAppear {
                                withAnimation(.easeOut(duration: 0.5).delay(Double(index) * 0.05)) {
                                    _ = appearedItems.insert(day.id)
                                }
                            }
                        }
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 140)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct ReligiousTimelineCell: View {
    let day: ReligiousDay
    let isLast: Bool
    let index: Int
    
    @State private var isPulsing = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            
            // Sol Taraf: Modern Timeline
            VStack(spacing: 0) {
                // Parıldayan Ay Noktası - Altın veya Zümrüt
                ZStack {
                    if day.isImportant {
                        Circle()
                            .fill(Color.themeSecondary.opacity(isPulsing ? 0.4 : 0.15))
                            .frame(width: 32, height: 32)
                            .scaleEffect(isPulsing ? 1.2 : 1.0)
                    }
                    
                    Circle()
                        .strokeBorder(
                            day.isImportant ? Color.themeSecondary : Color.themePrimary.opacity(0.4),
                            lineWidth: day.isImportant ? 2.5 : 1.5
                        )
                        .frame(width: 18, height: 18)
                        .background(
                            Circle()
                                .fill(day.isImportant ? Color.themeSecondary : Color.themeSurface)
                        )
                    
                    if day.isImportant {
                        Image(systemName: "sparkles")
                            .font(.system(size: 8))
                            .foregroundColor(.white)
                    }
                }
                .padding(.top, 12)
                .onAppear {
                    if day.isImportant {
                        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                            isPulsing = true
                        }
                    }
                }
                
                // Aşağıya uzanan zarif çizgi
                if !isLast {
                    Rectangle()
                        .fill(LinearGradient(
                            colors: [
                                day.isImportant ? Color.themeSecondary.opacity(0.8) : Color.themePrimary.opacity(0.3),
                                Color.themePrimary.opacity(0.05)
                            ],
                            startPoint: .top,
                            endPoint: .bottom)
                        )
                        .frame(width: 1.5)
                }
            }
            .frame(width: 32)
            
            // Sağ Taraf: Premium Glassmorphic Kart
            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    // Takvim Tarihi (Modern Leaf Görünümü)
                    VStack(spacing: 0) {
                        // Üst Şerit (Önemli günlerde altın/kırmızı, diğerlerinde yeşil)
                        Rectangle()
                            .fill(day.isImportant ? Color.themeSecondary : Color.themePrimary)
                            .frame(height: 14)
                        
                        VStack(spacing: 2) {
                            let parts = day.miladiDate.split(separator: " ")
                            if parts.count >= 3 {
                                Text(parts[0])
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(.themeText)
                                Text(parts[1].uppercased())
                                    .font(.system(size: 10, weight: .black))
                                    .foregroundColor(.themeTextSecondary)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.themeSurface)
                    }
                    .frame(width: 60, height: 68)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.themePrimary.opacity(0.1), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.05), radius: 5, y: 3)
                    
                    // Detaylar
                    VStack(alignment: .leading, spacing: 6) {
                        Text(day.name)
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(.themeText)
                            .lineLimit(2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 6) {
                                Image(systemName: "moon.stars.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(day.isImportant ? .themeSecondary : .themePrimary)
                                Text(day.hicriDate)
                                    .font(.system(size: 12, weight: .medium))
                            }
                            
                            HStack(spacing: 6) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 10))
                                    .foregroundColor(.themeTextSecondary)
                                Text(day.dayOfWeek)
                                    .font(.system(size: 12, weight: .medium))
                            }
                        }
                        .foregroundColor(.themeTextSecondary)
                    }
                    
                    Spacer()
                    
                    // Önemli Gün İkonu (Opsiyonel)
                    if day.isImportant {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.themeSecondary.opacity(0.5))
                    }
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 22)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.03), radius: 10, y: 5)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(day.isImportant ? Color.themeSecondary.opacity(0.3) : Color.white.opacity(0.5), lineWidth: 1)
                )
            }
            .padding(.bottom, isLast ? 32 : 16)
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    ReligiousDaysView()
}
