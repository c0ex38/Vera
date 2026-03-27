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
                        
                        // UYARI: BİLDİRİMLER GENEL KAPALIYSA
                        if !viewModel.notificationsEnabled {
                            VStack(spacing: 12) {
                                HStack(spacing: 15) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.orange)
                                        .font(.system(size: 24))
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Bildirimler Kapalı")
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                            .foregroundColor(.themeText)
                                        Text("Ana ayarlardan bildirimleri kapatmışsınız. Hiçbir alarm veya ezan sesi çalmayacaktır.")
                                            .font(.system(size: 13))
                                            .foregroundColor(.themeTextSecondary)
                                    }
                                }
                                .padding()
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(15)
                                
                                Button(action: {
                                    presentationMode.wrappedValue.dismiss()
                                }) {
                                    Text("Ana Ayarlara Git")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.themePrimary)
                                }
                            }
                            .padding(.top, 8)
                        }
                        
                        // ANA VAKİTLER ALARMLARI
                        SettingsGroup(header: "VAKİT ALARMLARI", footer: "Seçili vakitlerde telefonunuz size özel bildirim veya alarm gönderir.") {
                            PremiumToggleRow(
                                title: "İmsak / Sabah",
                                icon: "sun.and.horizon.fill",
                                iconColor: .orange,
                                isOn: $viewModel.notifyFajr,
                                isEnabled: viewModel.notificationsEnabled
                            )
                            CustomDivider()
                            PremiumToggleRow(
                                title: "Öğle",
                                icon: "sun.max.fill",
                                iconColor: .yellow,
                                isOn: $viewModel.notifyDhuhr,
                                isEnabled: viewModel.notificationsEnabled
                            )
                            CustomDivider()
                            PremiumToggleRow(
                                title: "İkindi",
                                icon: "sun.dust.fill",
                                iconColor: .red,
                                isOn: $viewModel.notifyAsr,
                                isEnabled: viewModel.notificationsEnabled
                            )
                            CustomDivider()
                            PremiumToggleRow(
                                title: "Akşam",
                                icon: "sunset.fill",
                                iconColor: .purple,
                                isOn: $viewModel.notifyMaghrib,
                                isEnabled: viewModel.notificationsEnabled
                            )
                            CustomDivider()
                            PremiumToggleRow(
                                title: "Yatsı",
                                icon: "moon.stars.fill",
                                iconColor: .indigo,
                                isOn: $viewModel.notifyIsha,
                                isEnabled: viewModel.notificationsEnabled
                            )
                        }
                        
                        // ÖNCESİ HATIRLATICILAR (REMINDERS)
                        SettingsGroup(header: "ÖNCESİ HATIRLATICILAR") {
                            PremiumToggleRow(
                                title: "Vakit Öncesi Uyarı",
                                icon: "bell.badge.fill",
                                iconColor: .themePrimary,
                                isOn: $viewModel.reminderEnabled,
                                isEnabled: viewModel.notificationsEnabled
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
                                        .foregroundColor(.themeText.opacity(viewModel.notificationsEnabled ? 1 : 0.5))
                                    
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
                                    .disabled(!viewModel.notificationsEnabled)
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
                                isOn: $viewModel.adhanSoundEnabled,
                                isEnabled: viewModel.notificationsEnabled
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
                                        .foregroundColor(.themePrimary.opacity(viewModel.notificationsEnabled ? 1 : 0.5))
                                    Spacer()
                                }
                                .padding(.vertical, 14)
                            }
                            .disabled(!viewModel.notificationsEnabled)
                            
                            CustomDivider()
                            
                            Button(action: {
                                withAnimation { viewModel.toggleAll(isOn: false) }
                            }) {
                                HStack {
                                    Spacer()
                                    Text("Tümünü Kapat")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundColor(.red.opacity(viewModel.notificationsEnabled ? 0.8 : 0.4))
                                    Spacer()
                                }
                                .padding(.vertical, 14)
                            }
                            .disabled(!viewModel.notificationsEnabled)
                        }
                        
                        // TEST BÖLÜMÜ
                        SettingsGroup(header: "TEST VE HATA AYIKLAMA", footer: viewModel.notificationsEnabled ? "Butona bastıktan 5 saniye sonra test bildirimi gelecektir. Lütfen uygulamayı arka plana atın." : "Bildirimler kapalı olduğu için test yapılamaz.") {
                            Button(action: {
                                viewModel.scheduleTestNotification()
                            }) {
                                HStack {
                                    Image(systemName: "bell.badge.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.orange.opacity(viewModel.notificationsEnabled ? 1 : 0.4))
                                    Text("Hemen Test Bildirimi Gönder")
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                    Spacer()
                                    Image(systemName: "timer")
                                        .font(.system(size: 12))
                                        .foregroundColor(.themeTextSecondary)
                                    Text("5 sn")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.themeTextSecondary)
                                }
                                .foregroundColor(.themeText.opacity(viewModel.notificationsEnabled ? 1 : 0.5))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                            }
                            .disabled(!viewModel.notificationsEnabled)
                            
                            CustomDivider()
                            
                            Button(action: {
                                viewModel.syncWithAPI()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                        .font(.system(size: 20))
                                        .foregroundColor(.green.opacity(viewModel.notificationsEnabled ? 1 : 0.4))
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Vakitleri API ile Eşitle")
                                            .font(.system(size: 15, weight: .bold, design: .rounded))
                                        Text("Haftalık bildirimleri sunucudan tazele")
                                            .font(.system(size: 11))
                                            .foregroundColor(.themeTextSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    if viewModel.isSyncing {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green.opacity(viewModel.notificationsEnabled ? 0.6 : 0.2))
                                    }
                                }
                                .foregroundColor(.themeText.opacity(viewModel.notificationsEnabled ? 1 : 0.5))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                            }
                            .disabled(!viewModel.notificationsEnabled || viewModel.isSyncing)
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
    var isEnabled: Bool = true
    
    var body: some View {
        HStack(spacing: 16) {
            // İkon Kutusu - iOS Ayarlar Stili
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(iconColor.opacity(isEnabled ? 1 : 0.4))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(isEnabled ? 1 : 0.6))
            }
            
            Toggle(isOn: $isOn) {
                Text(title)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.themeText.opacity(isEnabled ? 1 : 0.5))
            }
            .tint(.themePrimary)
            .disabled(!isEnabled)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#Preview {
    NotificationSettingsView()
}
