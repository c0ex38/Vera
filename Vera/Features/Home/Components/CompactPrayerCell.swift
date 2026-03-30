import SwiftUI

struct CompactPrayerCell: View {
    let type: PrayerType
    let time: String
    let isActive: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: type.iconName)
                .font(.system(size: 18))
                .foregroundColor(isActive ? .white : .themePrimary.opacity(0.8))
                .padding(.bottom, 2)
            
            Text(type.localizedName)
                .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 15 : 13, weight: .bold, design: .rounded))
                .foregroundColor(isActive ? .white.opacity(0.9) : .themeTextSecondary)
            
            Text(time)
                .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 22 : 17, weight: .heavy, design: .rounded))
                .foregroundColor(isActive ? .white : .themeText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.themeSurface.opacity(isActive ? 1 : 0.4))
                
                if isActive {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(LinearGradient(colors: [.themePrimary, .themePrimary.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))
                }
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(isActive ? Color.clear : Color.themePrimary.opacity(0.05), lineWidth: 1)
        )
        .scaleEffect(isActive ? 1.05 : 1.0)
        .shadow(color: isActive ? Color.themePrimary.opacity(0.3) : .black.opacity(0.02), radius: isActive ? 10 : 4, y: isActive ? 5 : 2)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isActive)
    }
}
