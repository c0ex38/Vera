import SwiftUI

struct MenuView: View {
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Derin Tema Arkaplanı
                Color.themeBackground.ignoresSafeArea()
                
                // Nefes Alan Arkaplan Işığı (Hafif bir aura)
                RadialGradient(
                    colors: [Color.themePrimary.opacity(0.15), .clear],
                    center: .top,
                    startRadius: 50,
                    endRadius: 400
                )
                .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Spacer(minLength: 10)
                    
                    // Tam Merkezlenmiş Premium Header
                    VStack(spacing: 6) {
                        Text("Keşfet")
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .foregroundColor(.themePrimary)
                            .shadow(color: Color.themePrimary.opacity(0.3), radius: 10, y: 5)
                        
                        Text("Tüm araçlar ve özellikler")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.themeTextSecondary)
                            .tracking(0.5)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    // Menü Grid'i (Glassmorphic, 3 Sütun)
                    LazyVGrid(columns: columns, spacing: 16) {
                        // Aktif Modüller
                        NavigationLink(destination: DhikrView()) {
                            MenuCard(
                                title: "Zikir",
                                icon: "hand.tap.default.fill", 
                                color: .orange,
                                subtitle: "Tesbih"
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        NavigationLink(destination: MonthlyImsakiyeViewWrapper()) {
                            MenuCard(
                                title: "İmsakiye",
                                icon: "calendar.badge.clock",
                                color: .indigo,
                                subtitle: "30 Günlük"
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        NavigationLink(destination: NotificationSettingsView()) {
                            MenuCard(
                                title: "Alarmlar",
                                icon: "alarm.fill",
                                color: .red,
                                subtitle: "Ezan/Uyarı"
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        NavigationLink(destination: PrayerSurahsListView()) {
                            MenuCard(
                                title: "Sureler",
                                icon: "book.fill",
                                color: .brown,
                                subtitle: "Kur'an"
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        NavigationLink(destination: EsmaulHusnaListView()) {
                            MenuCard(
                                title: "E. Hüsna",
                                icon: "sparkles",
                                color: .purple,
                                subtitle: "99 İsim"
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        NavigationLink(destination: QuranIndexView()) {
                            MenuCard(
                                title: "Kuran",
                                icon: "book.pages.fill",
                                color: .teal,
                                subtitle: "Cüz/Ayet"
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        NavigationLink(destination: NearbyMosquesView()) {
                            MenuCard(
                                title: "Camiler",
                                icon: "mappin.circle.fill",
                                color: .green,
                                subtitle: "Harita"
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        NavigationLink(destination: ZakatHomeView()) {
                            MenuCard(
                                title: "Zekat",
                                icon: "banknote.fill",
                                color: .yellow,
                                subtitle: "Hesapla"
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        NavigationLink(destination: LibraryListView()) {
                            MenuCard(
                                title: "Kütüphane",
                                icon: "books.vertical.fill",
                                color: .blue,
                                subtitle: "Dini Bilgi"
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        NavigationLink(destination: SermonListView()) {
                            MenuCard(
                                title: "Hutbe",
                                icon: "quote.bubble.fill",
                                color: .cyan,
                                subtitle: "Haftalık"
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        NavigationLink(destination: SettingsView()) {
                            MenuCard(
                                title: "Ayarlar",
                                icon: "gearshape.fill",
                                color: .gray,
                                subtitle: "Tercihler"
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 16)
                    
                    Spacer(minLength: 60)
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
    }
}

// MARK: - Ultra-Premium Menü Kartı Tasarımı (Kompakt 3 Sütun)
struct MenuCard: View {
    let title: String
    let icon: String
    let color: Color
    let subtitle: String
    var isComingSoon: Bool = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            // İkon Havuzu (Icon Container)
            ZStack {
                // Şık Gradient Arkaplan
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                isComingSoon ? Color.gray.opacity(0.15) : color.opacity(0.2),
                                isComingSoon ? Color.gray.opacity(0.05) : color.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                
                // Canlı veya Silik İkon
                Image(systemName: icon == "hand.tap.default.fill" ? "hand.tap.fill" : icon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(isComingSoon ? .gray.opacity(0.6) : color)
                    .shadow(color: isComingSoon ? .clear : color.opacity(0.3), radius: 5, y: 3)
            }
            
            // Metin Alanı
            VStack(alignment: .center, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(isComingSoon ? .themeTextSecondary.opacity(0.8) : .themeText)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                
                Text(subtitle)
                    .font(.system(size: 9, weight: .medium, design: .rounded))
                    .foregroundColor(isComingSoon ? .orange.opacity(0.9) : .themeTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, idealHeight: 110)
        // Glassmorphic Zemin
        .background(Color.themeSurface)
        .cornerRadius(20)
        // Işık/Gölge Oyunları
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(isComingSoon ? Color.clear : color.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: isComingSoon ? .clear : .black.opacity(0.05), radius: 8, y: 4)
        .opacity(isComingSoon ? 0.7 : 1.0)
    }
}

// İmsakiye Verilerini Çekip Gösteren Aracı Görünüm
struct MonthlyImsakiyeViewWrapper: View {
    @EnvironmentObject var homeVM: HomeViewModel
    @AppStorage("savedDistrictID") var savedDistrictID: String = ""
    @AppStorage("savedLocationName") var savedLocationName: String = ""
    
    var body: some View {
        Group {
            if homeVM.prayerTimes.isEmpty {
                ZStack {
                    Color.themeBackground.ignoresSafeArea()
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("İmsakiye Yükleniyor...")
                            .font(.headline)
                            .foregroundColor(.themeTextSecondary)
                    }
                }
                .navigationBarHidden(true)
                .onAppear {
                    if !savedDistrictID.isEmpty {
                        homeVM.fetchSavedLocationTimes(districtID: savedDistrictID, locationName: savedLocationName)
                    }
                }
            } else {
                MonthlyImsakiyeView()
                    .navigationBarHidden(true)
            }
        }
    }
}

#Preview {
    MenuView()
}
