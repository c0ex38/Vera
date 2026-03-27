import SwiftUI

struct MonthlyImsakiyeView: View {
    @EnvironmentObject var viewModel: HomeViewModel
    @Environment(\.presentationMode) var presentationMode
    
    // Konum Bilgileri
    @AppStorage("savedDistrictID") private var savedDistrictID: String = ""
    @AppStorage("savedLocationName") private var savedLocationName: String = ""
    
    @State private var showLocationPicker = false
    
    var body: some View {
        ZStack {
            // Derin Premium Arkaplan
            Color.themeBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Özel Header
                VeraCustomHeader(
                    title: L10n.Home.monthlyImsakiye,
                    subtitle: L10n.Home.monthlyImsakiyeSub,
                    showBackButton: presentationMode.wrappedValue.isPresented
                )
                
                // Konum Seçici Kapsül Buton (Lüks Tasarım)
                Button(action: {
                    showLocationPicker = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 14))
                        Text(savedLocationName.isEmpty ? L10n.Home.selectLocation : savedLocationName)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .lineLimit(1)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .bold))
                            .opacity(0.6)
                    }
                    .foregroundColor(.themePrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.themePrimary.opacity(0.12))
                    .clipShape(Capsule())
                }
                .padding(.bottom, 16)
                .padding(.top, 8)
                
                if viewModel.prayerTimes.isEmpty {
                    Spacer()
                    if viewModel.state == .requestingLocation || viewModel.state == .matchingAPI {
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.2)
                            Text(L10n.Home.loading)
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(.themeTextSecondary)
                        }
                    } else {
                        // Seçim yapılmamışsa veya hata varsa
                        VStack(spacing: 16) {
                            Image(systemName: "location.circle.fill")
                                .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 120 : 80))
                                .foregroundColor(.themePrimary)
                                .opacity(0.5)
                            Text(L10n.Home.waitingLocation)
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(.themeTextSecondary)
                            Button(L10n.Home.selectLocation) {
                                showLocationPicker = true
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.themePrimary)
                        }
                    }
                    Spacer()
                } else {
                    
                    // Şık Tablo Sütun Başlıkları
                    HStack(spacing: 0) {
                        Text(NSLocalizedString("imsakiye_tarih", comment: "").uppercased())
                            .frame(width: 70, alignment: .leading)
                        
                        Divider().background(Color.themeTextSecondary.opacity(0.3)).frame(height: 12).padding(.horizontal, 4)
                        
                        Group {
                            Text(L10n.Prayer.imsak.prefix(3).uppercased()).frame(maxWidth: .infinity)
                            Text(L10n.Prayer.sunrise.prefix(3).uppercased()).frame(maxWidth: .infinity)
                            Text(L10n.Prayer.dhuhr.prefix(3).uppercased()).frame(maxWidth: .infinity)
                            Text(L10n.Prayer.asr.prefix(3).uppercased()).frame(maxWidth: .infinity)
                            Text(L10n.Prayer.maghrib.prefix(3).uppercased()).frame(maxWidth: .infinity)
                            Text(L10n.Prayer.isha.prefix(3).uppercased()).frame(maxWidth: .infinity)
                        }
                    }
                    .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 16 : 11, weight: .bold, design: .rounded))
                    .foregroundColor(.themeTextSecondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.themeSurface)
                    .shadow(color: .black.opacity(0.05), radius: 5, y: 3)
                    .zIndex(1) // Gölgenin listenin üstüne düşmesi için
                    
                    // Liste Alanı (Seamless Table)
                    ScrollView(showsIndicators: false) {
                        ScrollViewReader { proxy in
                            LazyVStack(spacing: 0) {
                                ForEach(Array(viewModel.prayerTimes.enumerated()), id: \.element.gregorianDateShort) { index, day in
                                    ImsakiyeRow(day: day, isEven: index % 2 == 0)
                                        .id(day.gregorianDateShort)
                                }
                            }
                            .padding(.bottom, 120) // TabBar padding
                            .onAppear {
                                // Bugünün hücresine kaydır
                                let formatter = DateFormatter()
                                formatter.dateFormat = "yyyy-MM-dd"
                                let todayString = formatter.string(from: Date())
                                
                                if let todayModel = viewModel.prayerTimes.first(where: { $0.gregorianDateShortIso8601.starts(with: todayString) }) {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        withAnimation(.easeInOut(duration: 0.8)) {
                                            proxy.scrollTo(todayModel.gregorianDateShort, anchor: .center)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            if !savedDistrictID.isEmpty {
                viewModel.fetchSavedLocationTimes(districtID: savedDistrictID, locationName: savedLocationName)
            }
        }
        .sheet(isPresented: $showLocationPicker, onDismiss: {
            // Şehir değiştirildiğinde picker kapandığında tetiklenir
            if !savedDistrictID.isEmpty {
                viewModel.fetchSavedLocationTimes(districtID: savedDistrictID, locationName: savedLocationName)
            }
        }) {
            LocationPickerView()
        }
    }
}

// MARK: - Saf ve Şık Tablo Satırı
struct ImsakiyeRow: View {
    let day: PrayerTime
    let isEven: Bool
    
    // Gün Eşleşme Mantığı (Bugün)
    private var isToday: Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayString = formatter.string(from: Date())
        return day.gregorianDateShortIso8601.starts(with: todayString)
    }
    
    // Tarihten sadece günü (Örn: "24") alıyoruz, yer kaplamaması için
    private var dayNumber: String {
        let parts = day.gregorianDateLong?.split(separator: " ")
        return String(parts?.first ?? "")
    }
    
    // Günü ve Ayı alt alta yazmak için
    private var monthName: String {
        let parts = day.gregorianDateLong?.split(separator: " ")
        if let parts = parts, parts.count > 1 {
            return String(parts[1].prefix(3)).uppercased() // "MAR" vb.
        }
        return ""
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Sol Tarih Bloğu
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(dayNumber)
                        .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 26 : 18, weight: .heavy, design: .rounded))
                        .foregroundColor(isToday ? .white : .themeText)
                    Text(monthName)
                        .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 16 : 11, weight: .bold))
                        .foregroundColor(isToday ? .white.opacity(0.8) : .themeTextSecondary)
                }
                
                // Gün kısaltması: "Pzt", "Sal" vs.
                let parts = day.gregorianDateLong?.split(separator: " ")
                if let parts = parts, parts.count > 2 {
                    Text(String(parts[2].prefix(3)))
                        .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 16 : 11, weight: .medium))
                        .foregroundColor(isToday ? .white.opacity(0.8) : .themePrimary)
                }
            }
            .frame(width: 70, alignment: .leading)
            
            Divider()
                .background(isToday ? Color.white.opacity(0.3) : Color.themeTextSecondary.opacity(0.2))
                .frame(height: 24)
                .padding(.horizontal, 4)
            
            // Vakitler Sütunları
            Group {
                TimeText(time: day.imsakTime, isToday: isToday)
                TimeText(time: day.sunrise, isToday: isToday)
                TimeText(time: day.dhuhr, isToday: isToday)
                TimeText(time: day.asr, isToday: isToday)
                TimeText(time: day.maghrib, isToday: isToday)
                TimeText(time: day.isha, isToday: isToday)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            ZStack {
                if isToday {
                    LinearGradient(
                        colors: [Color.themePrimary.opacity(0.9), Color.themePrimary],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                } else {
                    isEven ? Color.themeBackground : Color.themeSurface
                }
            }
        )
        // Bugün hücresi için üst ve alta hafif vurgu çizgisi
        .overlay(
            VStack {
                if isToday {
                    Rectangle().fill(Color.white.opacity(0.4)).frame(height: 1)
                    Spacer()
                    Rectangle().fill(Color.white.opacity(0.4)).frame(height: 1)
                }
            }
        )
        // Bugün değilse satır aralarına ince ayraç
        .overlay(
            VStack {
                if !isToday {
                    Spacer()
                    Rectangle().fill(Color.themeTextSecondary.opacity(0.05)).frame(height: 1)
                }
            }
        )
        .shadow(color: isToday ? Color.themePrimary.opacity(0.4) : .clear, radius: 10, y: 5)
        .zIndex(isToday ? 2 : 1) // Gölgenin diğer satırlara düşmesi için
    }
}

// MARK: - Saf Vakit Metni
struct TimeText: View {
    let time: String
    let isToday: Bool
    
    var body: some View {
        Text(time)
            .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 18 : 13, weight: isToday ? .heavy : .semibold, design: .rounded))
            .monospacedDigit()
            .foregroundColor(isToday ? .white : .themeText)
            .frame(maxWidth: .infinity)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
    }
}

#Preview {
    // MonthlyImsakiyeView()
}
