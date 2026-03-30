import SwiftUI

struct PrayerSurahsListView: View {
    @StateObject private var viewModel = PrayerSurahsViewModel()
    @Environment(\.presentationMode) var presentationMode
    
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
                    title: "Namaz Duaları ve Sureleri",
                    subtitle: "Okunuşları, Anlamları ve Faziletleri",
                    showBackButton: presentationMode.wrappedValue.isPresented
                )
                .padding(.bottom, 10)
                
                ScrollView(showsIndicators: false) {
                    let columns = [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ]
                    
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        LazyVGrid(columns: columns, spacing: 16) {
                            surahListRows
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 10)
                        .padding(.bottom, 120)
                    } else {
                        LazyVStack(spacing: 16) {
                            surahListRows
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        .padding(.bottom, 120)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private var surahListRows: some View {
        ForEach(Array(viewModel.surahs.enumerated()), id: \.element.id) { index, surah in
            NavigationLink(destination: SurahDetailView(surah: surah)) {
                SurahPremiumRowView(surah: surah, index: index + 1)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

// MARK: - Premium Namaz Suresi Satırı
struct SurahPremiumRowView: View {
    let surah: Surah
    let index: Int
    
    var body: some View {
        HStack(spacing: 16) {
            
            // Sıra Numarası Rozeti
            ZStack {
                Circle()
                    .fill(Color.themePrimary.opacity(0.12))
                    .frame(width: 48, height: 48)
                
                Text("\(index)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.themePrimary)
                    .shadow(color: Color.themePrimary.opacity(0.3), radius: 5, y: 2)
            }
            
            // Başlıklar
            VStack(alignment: .leading, spacing: 6) {
                Text(surah.title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.themeText)
                    .lineLimit(1)
                
                Text(surah.subtitle)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.themeTextSecondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // İkon
            ZStack {
                Circle()
                    .fill(Color.themeBackground)
                    .frame(width: 32, height: 32)
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.themePrimary.opacity(0.8))
            }
        }
        .padding(16)
        .background(Color.themeSurface)
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.black.opacity(0.02), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.04), radius: 10, y: 5)
    }
}

#Preview {
    PrayerSurahsListView()
}
