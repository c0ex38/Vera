import SwiftUI

struct HadithCard: View {
    let hadith: Hadith
    
    var body: some View {
        HStack(spacing: 0) {
            // Left Accent Bar
            Rectangle()
                .fill(Color.themePrimary.opacity(0.3))
                .frame(width: 4)
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "quote.opening")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.themePrimary.opacity(0.4))
                    
                    Text(L10n.Home.hadithOfTheDay.uppercased())
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundColor(.themePrimary)
                        .kerning(1.2)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.themePrimary.opacity(0.08))
                        .clipShape(Capsule())
                    
                    Spacer()
                    
                    Text("#\(hadith.hadithNo)")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(.themeTextSecondary.opacity(0.6))
                }
                
                Text(hadith.content)
                    .font(.system(size: 16, weight: .medium, design: .serif))
                    .italic()
                    .foregroundColor(.themeText)
                    .lineSpacing(6)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                HStack {
                    Spacer()
                    Image(systemName: "quote.closing")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.themePrimary.opacity(0.4))
                }
            }
            .padding(20)
            .veraGlassCard(cornerRadius: 24)
        }
        .padding(.horizontal, 20)
        .shadow(color: .black.opacity(0.02), radius: 10, y: 5)
    }
}
