import SwiftUI

struct SurahDetailView: View {
    let surah: Surah
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color.themeBackground.ignoresSafeArea()
            
            // Aura Background
            RadialGradient(
                colors: [Color.themePrimary.opacity(0.15), .clear],
                center: .top,
                startRadius: 10,
                endRadius: 600
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                VeraCustomHeader(
                    title: surah.title,
                    subtitle: surah.subtitle,
                    showBackButton: true
                ) {
                    // Right Content actions if any
                    EmptyView()
                }
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // Dev Arapça Okuma Kartı
                        VStack(alignment: .trailing, spacing: 16) {
                            HStack {
                                Text("Arapça Okunuşu")
                                    .font(.system(size: 14, weight: .black, design: .rounded))
                                    .foregroundColor(.themePrimary)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.themePrimary.opacity(0.12))
                                    .clipShape(Capsule())
                                
                                Spacer()
                            }
                            
                            Text(surah.arabicText)
                                // Standard Kuran font fallsback gracefully if Uthman Taha is missing
                                .font(.custom("KFGQPC Uthman Taha Naskh", size: 40, relativeTo: .largeTitle))
                                .font(.system(size: 34, weight: .medium, design: .serif))
                                .foregroundColor(.themeText)
                                .multilineTextAlignment(.trailing)
                                .lineSpacing(16)
                                .padding(.top, 10)
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .background(Color.themeSurface)
                        .cornerRadius(30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30, style: .continuous)
                                .stroke(Color.themePrimary.opacity(0.15), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.04), radius: 15, y: 10)
                        
                        // Türkçe Okunuş Kartı
                        PrayerInfoCard(
                            icon: "mouth",
                            title: "Türkçe Okunuşu",
                            content: surah.turkishReading,
                            tintColor: .themePrimary
                        )
                        
                        // Diyanet Meali Kartı
                        PrayerInfoCard(
                            icon: "text.book.closed.fill",
                            title: "Anlamı (Diyanet Meali)",
                            content: surah.meaning,
                            tintColor: .themeTextSecondary
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 80)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Premium Namaz Bilgi Kartı
struct PrayerInfoCard: View {
    let icon: String
    let title: String
    let content: String
    let tintColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(tintColor.opacity(0.12))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(tintColor)
                }
                
                Text(title)
                    .font(.system(size: 17, weight: .heavy, design: .rounded))
                    .foregroundColor(.themeText)
            }
            
            Text(content)
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundColor(.themeText)
                .lineSpacing(10)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.themeSurface)
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.black.opacity(0.02), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.03), radius: 10, y: 5)
    }
}

#Preview {
    SurahDetailView(surah: Surah(
        title: "İhlas Suresi",
        subtitle: "Mekki",
        arabicText: "بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّح۪يمِ\nقُلْ هُوَ اللّٰهُ اَحَدٌۚ ﴿١﴾ اَللّٰهُ الصَّمَدُۚ ﴿٢﴾ لَمْ يَلِدْ وَلَمْ يُولَدْۙ ﴿٣﴾ وَلَمْ يَكُنْ لَهُ كُفُواً اَحَدٌ ﴿٤﴾",
        turkishReading: "Bismillâhirrahmânirrahîm.\n1. Kul hüvellâhü ehad.\n2. Allâhüssamed.\n3. Lem yelid ve lem yûled.\n4. Ve lem yekün lehû küfüven ehad.",
        meaning: "1. De ki: O, Allah'tır, bir tektir.\n2. Allah Samed'dir.\n3. Ondan çocuk olmamıştır. Kendisi de doğmamıştır.\n4. Hiçbir şey O'na denk ve benzer değildir."
    ))
}
