import SwiftUI

/// Genel amaçlı, estetik tasarımlı hata / uyarı gösterim ekranı
struct ErrorStateView: View {
    var iconName: String = "exclamationmark.triangle.fill"
    var iconColor: Color = .orange
    var message: String
    var buttonTitle: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: iconName)
                .font(.system(size: 60))
                .foregroundColor(iconColor)
            
            Text(message)
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.themeText)
                .padding(.horizontal)
            
            if let buttonTitle = buttonTitle, let action = action {
                Button(action: action) {
                    Text(buttonTitle)
                        .fontWeight(.bold)
                }
                .buttonStyle(.borderedProminent)
                .tint(.themePrimary)
                .padding(.top, 8)
            }
        }
    }
}

#Preview {
    ErrorStateView(
        iconName: "location.slash.fill",
        message: "Cihazınız pusula desteklemiyor.",
        buttonTitle: "Tekrar Dene",
        action: {}
    )
}
