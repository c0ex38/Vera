import SwiftUI

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
                    .foregroundStyle(.themeTextSecondary.opacity(0.7))
                    .padding(.leading, 16)
                    .padding(.bottom, 2)
            }
            
            VStack(spacing: 0) {
                content
            }
            .background(Color.themeSurface)
            .clipShape(.rect(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.black.opacity(0.04), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.02), radius: 8, y: 4)
            
            if let footer = footer {
                Text(footer)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.themeTextSecondary.opacity(0.6))
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
                    .foregroundStyle(.white.opacity(isEnabled ? 1 : 0.6))
            }
            
            Toggle(isOn: $isOn) {
                Text(title)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.themeText.opacity(isEnabled ? 1 : 0.5))
            }
            .tint(.themePrimary)
            .disabled(!isEnabled)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
