import SwiftUI

struct CompactPrayerCell: View {
    let title: String
    let time: String
    let isActive: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(isActive ? .white.opacity(0.9) : .themeTextSecondary)
            
            Text(time)
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundColor(isActive ? .white : .themePrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20).fill(Color.themeSurface)
                if isActive {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(LinearGradient(colors: [Color.themePrimary, Color.themePrimary.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))
                }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: isActive ? Color.themePrimary.opacity(0.4) : .black.opacity(0.03), radius: isActive ? 12 : 5, y: isActive ? 6 : 2)
        .scaleEffect(isActive ? 1.05 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isActive)
    }
}
