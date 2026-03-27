import SwiftUI

struct NotificationSettingsView: View {
    @StateObject private var viewModel = NotificationSettingsViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color.themeBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Premium Header
                VeraCustomHeader(title: "Alarmlar", subtitle: "Ezan ve Vakit Hatırlatıcıları") {
                    presentationMode.wrappedValue.dismiss()
                }
                .padding(.bottom, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // ANA VAKİTLER ALARMLARI
                        SettingsGroup(header: "VAKİT ALARMLARI", footer: "Seçili vakitlerde telefonunuz size özel bildirim veya alarm gönderir.") {
                            PremiumToggleRow(
                                title: "İmsak / Sabah",
                                icon: "sun.and.horizon.fill",
                                iconColor: .orange,
                                isOn: $viewModel.notifyFajr
                            )
                            CustomDivider()
                            PremiumToggleRow(
                                title: "Öğle",
                                icon: "sun.max.fill",
                                iconColor: .yellow,
                                isOn: $viewModel.notifyDhuhr
                            )
                            CustomDivider()
                            PremiumToggleRow(
                                title: "İkindi",
                                icon: "sun.dust.fill",
                                iconColor: .red,
                                isOn: $viewModel.notifyAsr
                            )
                            CustomDivider()
                            PremiumToggleRow(
                                title: "Akşam",
                                icon: "sunset.fill",
                                iconColor: .purple,
                                isOn: $viewModel.notifyMaghrib
                            )
                            CustomDivider()
                            PremiumToggleRow(
                                title: "Yatsı",
                                icon: "moon.stars.fill",
                                iconColor: .indigo,
                                isOn: $viewModel.notifyIsha
                            )
                        }
                        
                        // ÖNCESİ HATIRLATICILAR (REMINDERS)
                        SettingsGroup(header: "ÖNCESİ HATIRLATICILAR") {
                            PremiumToggleRow(
                                title: "Vakit Öncesi Uyarı",
                                icon: "bell.badge.fill",
                                iconColor: .themePrimary,
                                isOn: $viewModel.reminderEnabled
                            )
                            
                            if viewModel.reminderEnabled {
                                CustomDivider()
                                
                                HStack {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .fill(Color.gray.opacity(0.15))
                                            .frame(width: 32, height: 32)
                                        Image(systemName: "timer")
                                            .foregroundColor(.gray)
                                            .font(.system(size: 16, weight: .semibold))
                                    }
                                    
                                    Text("Uyarı Zamanı")
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundColor(.themeText)
                                    
                                    Spacer()
                                    
                                    // Premium Profil Picker
                                    Menu {
                                        ForEach(viewModel.reminderOptions, id: \.self) { minutes in
                                            Button(action: {
                                                viewModel.reminderOffset = minutes
                                            }) {
                                                Text("\(minutes) dakika önce")
                                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                            }
                                        }
                                    } label: {
                                        HStack(spacing: 6) {
                                            Text("\(viewModel.reminderOffset) dk")
                                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                                .foregroundColor(.themeTextSecondary)
                                            Image(systemName: "chevron.up.chevron.down")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(.themeTextSecondary.opacity(0.6))
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.themeBackground)
                                        .cornerRadius(8)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                            }
                        }
                        
                        // SES AYARLARI
                        SettingsGroup(header: "SES TERCİHLERİ") {
                            PremiumToggleRow(
                                title: "Ezan Sesi Çal",
                                icon: "speaker.wave.3.fill",
                                iconColor: .teal,
                                isOn: $viewModel.adhanSoundEnabled
                            )
                        }
                        
                        // HIZLI AKSİYONLAR
                        SettingsGroup(header: "") {
                            Button(action: {
                                withAnimation { viewModel.toggleAll(isOn: true) }
                            }) {
                                HStack {
                                    Spacer()
                                    Text("Tümünü Aktifleştir")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundColor(.themePrimary)
                                    Spacer()
                                }
                                .padding(.vertical, 14)
                            }
                            
                            CustomDivider()
                            
                            Button(action: {
                                withAnimation { viewModel.toggleAll(isOn: false) }
                            }) {
                                HStack {
                                    Spacer()
                                    Text("Tümünü Kapat")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundColor(.red.opacity(0.8))
                                    Spacer()
                                }
                                .padding(.vertical, 14)
                            }
                        }
                        
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 140) // TabBar padding
                }
            }
        }
        .navigationBarHidden(true)
        .preferredColorScheme(UserDefaults.standard.integer(forKey: "appTheme") == 1 ? .light : (UserDefaults.standard.integer(forKey: "appTheme") == 2 ? .dark : nil))
    }
}

// MARK: - Özel Ayarlar Grubu Kutusu
struct SettingsGroup<Content: View>: View {
    let header: String
    var footer: String? = nil
    let content: Content
    
    init(header: String, footer: String? = nil, @ViewBuilder content: () -> Content) {
        self.header = header
        self.footer = footer
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !header.isEmpty {
                Text(header)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.themeTextSecondary.opacity(0.7))
                    .padding(.leading, 16)
                    .padding(.bottom, 2)
            }
            
            VStack(spacing: 0) {
                content
            }
            .background(Color.themeSurface)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.black.opacity(0.04), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.02), radius: 8, y: 4)
            
            if let footer = footer {
                Text(footer)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.themeTextSecondary.opacity(0.6))
                    .padding(.leading, 16)
                    .padding(.top, 4)
            }
        }
    }
}

// MARK: - Özel Bölücü Çizgi
struct CustomDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.themeTextSecondary.opacity(0.1))
            .frame(height: 1)
            .padding(.leading, 64) // İkonu pas geçip yazı hizasından başlar (iOS stili)
    }
}

// MARK: - Premium Toggle Satırı
struct PremiumToggleRow: View {
    let title: String
    let icon: String
    let iconColor: Color
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // İkon Kutusu - iOS Ayarlar Stili
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(iconColor)
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Toggle(isOn: $isOn) {
                Text(title)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.themeText)
            }
            .tint(.themePrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#Preview {
    NotificationSettingsView()
}
