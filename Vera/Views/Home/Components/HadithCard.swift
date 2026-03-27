import SwiftUI

struct HadithCard: View {
    let hadith: Hadith
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "quote.opening")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.themePrimary.opacity(0.6))
                
                Text(L10n.Home.hadithOfTheDay)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.themePrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.themePrimary.opacity(0.1))
                    .clipShape(Capsule())
                
                Spacer()
                
                Text("#\(hadith.hadithNo)")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(.themeTextSecondary)
            }
            
            Text(hadith.content)
                .font(.veraContent)
                .foregroundColor(.themeText)
                .lineSpacing(4)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            
            HStack {
                Spacer()
                Image(systemName: "quote.closing")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.themePrimary.opacity(0.6))
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.themeSurface.opacity(0.4))
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.themePrimary.opacity(0.1), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
    }
}
