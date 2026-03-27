import SwiftUI

struct ReligiousDaysView: View {
    @StateObject private var viewModel = ReligiousDaysViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            // Arkaplan
            Color.themeBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Premium Standart Başlık
                VeraCustomHeader(
                    title: "Dini Günler",
                    subtitle: "2026 Özel Takvimi",
                    showBackButton: presentationMode.wrappedValue.isPresented
                )
                .padding(.bottom, 16)
                
                // Timeline Listesi
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(viewModel.days.enumerated()), id: \.element.id) { index, day in
                            ReligiousTimelineCell(
                                day: day,
                                isLast: index == viewModel.days.count - 1
                            )
                        }
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 140) // NavBar ile çakışmayı önlemek için devasa Padding
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct ReligiousTimelineCell: View {
    let day: ReligiousDay
    let isLast: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            
            // Sol Taraf: Timeline Çizgisi ve Noktası
            VStack(spacing: 0) {
                // Parıldayan Ay Noktası
                ZStack {
                    Circle()
                        .fill(day.isImportant ? Color.themePrimary.opacity(0.3) : Color.clear)
                        .frame(width: 32, height: 32)
                        // Önemli günlerde nefes alan yavaş ışıma
                        .animation(day.isImportant ? .easeInOut(duration: 2).repeatForever(autoreverses: true) : .default, value: day.isImportant)
                    
                    Circle()
                        .strokeBorder(day.isImportant ? Color.themePrimary : Color.themeTextSecondary.opacity(0.3), lineWidth: 2)
                        .frame(width: 16, height: 16)
                    
                    if day.isImportant {
                        Circle()
                            .fill(Color.themePrimary)
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.top, 24)
                
                // Aşağıya uzanan zarif çizgi
                if !isLast {
                    Rectangle()
                        .fill(LinearGradient(
                            colors: [
                                day.isImportant ? Color.themePrimary.opacity(0.6) : Color.themeTextSecondary.opacity(0.15),
                                Color.themeTextSecondary.opacity(0.15)
                            ],
                            startPoint: .top,
                            endPoint: .bottom)
                        )
                        .frame(width: 2)
                        .padding(.top, 8)
                }
            }
            // Zaman Çizgisi Genişliği Sabitlendi
            .frame(width: 40)
            
            // Sağ Taraf: Glassmorphic İçerik Kartı
            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    // Takvim Tarihi (Takvim Yaprağı Görünümü)
                    VStack(spacing: 4) {
                        let parts = day.miladiDate.split(separator: " ")
                        if parts.count >= 3 {
                            Text(parts[0]) // Örn "15"
                                .font(.system(size: 26, weight: .black, design: .rounded))
                                .foregroundColor(day.isImportant ? .white : .themePrimary)
                            Text(parts[1].prefix(3).uppercased()) // Örn "OCA"
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(day.isImportant ? .white.opacity(0.9) : .themeTextSecondary)
                        }
                    }
                    .frame(width: 68, height: 72)
                    .background(
                        ZStack {
                            if day.isImportant {
                                LinearGradient(colors: [Color.themePrimary, Color.themePrimary.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            } else {
                                Color.themeSurface
                            }
                        }
                    )
                    .cornerRadius(18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(day.isImportant ? Color.white.opacity(0.2) : Color.themePrimary.opacity(0.1), lineWidth: 1)
                    )
                    .shadow(color: day.isImportant ? Color.themePrimary.opacity(0.4) : .black.opacity(0.04), radius: 8, y: 4)
                    
                    // Detaylar
                    VStack(alignment: .leading, spacing: 8) {
                        Text(day.name)
                            .font(.system(size: day.isImportant ? 18 : 17, weight: day.isImportant ? .bold : .semibold))
                            .foregroundColor(day.isImportant ? .themeText : .themeTextSecondary)
                        
                        // Alt Detay Satırı
                        HStack(spacing: 8) {
                            HStack(spacing: 4) {
                                Image(systemName: "moon.stars.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(day.isImportant ? .themePrimary : .themeTextSecondary.opacity(0.6))
                                Text(day.hicriDate)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 10))
                                    .foregroundColor(.themeTextSecondary)
                                Text(day.dayOfWeek)
                            }
                        }
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.themeTextSecondary)
                    }
                }
                .padding(16)
                .background(Color.themeSurface)
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(day.isImportant ? Color.themePrimary.opacity(0.2) : Color.clear, lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.03), radius: 10, y: 5)
            }
            .padding(.top, 12)
            .padding(.bottom, isLast ? 24 : 12)
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    ReligiousDaysView()
}
