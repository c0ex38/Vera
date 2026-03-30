import SwiftUI

struct NotificationSettingsView: View {
    @StateObject private var viewModel = NotificationSettingsViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.themeBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Premium Header
                VeraCustomHeader(title: "Alarmlar", subtitle: "Ezan ve Vakit Hatırlatıcıları") {
                    dismiss()
                }
                .padding(.bottom, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // UYARI: BİLDİRİMLER GENEL KAPALIYSA
                        if !viewModel.notificationsEnabled {
                            VStack(spacing: 12) {
                                HStack(spacing: 15) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundStyle(.orange)
                                        .font(.system(size: 24))
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Bildirimler Kapalı")
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                            .foregroundStyle(.themeText)
                                        Text("Ana ayarlardan bildirimleri kapatmışsınız. Hiçbir alarm veya ezan sesi çalmayacaktır.")
                                            .font(.system(size: 13))
                                            .foregroundStyle(.themeTextSecondary)
                                    }
                                }
                                .padding()
                                .background(Color.orange.opacity(0.1))
                                .clipShape(.rect(cornerRadius: 15))
                                
                                Button(action: {
                                    dismiss()
                                }) {
                                    Text("Ana Ayarlara Git")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(.themePrimary)
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
                                            .foregroundStyle(.gray)
                                            .font(.system(size: 16, weight: .semibold))
                                    }
                                    
                                    Text("Uyarı Zamanı")
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundStyle(.themeText.opacity(viewModel.notificationsEnabled ? 1 : 0.5))
                                    
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
                                                .foregroundStyle(.themeTextSecondary)
                                            Image(systemName: "chevron.up.chevron.down")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundStyle(.themeTextSecondary.opacity(0.6))
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.themeBackground)
                                        .clipShape(.rect(cornerRadius: 8))
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
                                        .foregroundStyle(.themePrimary.opacity(viewModel.notificationsEnabled ? 1 : 0.5))
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
                                        .foregroundStyle(.red.opacity(viewModel.notificationsEnabled ? 0.8 : 0.4))
                                    Spacer()
                                }
                                .padding(.vertical, 14)
                            }
                            .disabled(!viewModel.notificationsEnabled)
                            
                            CustomDivider()
                            
                            Button(action: {
                                viewModel.syncWithAPI()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                        .font(.system(size: 20))
                                        .foregroundStyle(.green.opacity(viewModel.notificationsEnabled ? 1 : 0.4))
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Vakitleri API ile Eşitle")
                                            .font(.system(size: 15, weight: .bold, design: .rounded))
                                        Text("Haftalık bildirimleri sunucudan tazele")
                                            .font(.system(size: 11))
                                            .foregroundStyle(.themeTextSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    if viewModel.isSyncing {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(.green.opacity(viewModel.notificationsEnabled ? 0.6 : 0.2))
                                    }
                                }
                                .foregroundStyle(.themeText.opacity(viewModel.notificationsEnabled ? 1 : 0.5))
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
        .toolbar(.hidden, for: .navigationBar)
        .preferredColorScheme(PreferenceManager.shared.appTheme == 1 ? .light : (PreferenceManager.shared.appTheme == 2 ? .dark : nil))
    }
}

#Preview {
    NotificationSettingsView()
}
