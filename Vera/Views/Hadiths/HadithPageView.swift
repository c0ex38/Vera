import SwiftUI

struct HadithPageView: View {
    let hadiths: [Hadith]
    @State var selectedIndex: Int
    
    var body: some View {
        ZStack {
            Color.themeBackground.ignoresSafeArea()
            
            // Dekoratif Arkaplan
            VStack {
                Circle()
                    .fill(Color.themePrimary.opacity(0.15))
                    .frame(width: 300, height: 300)
                    .blur(radius: 80)
                    .offset(x: -100, y: -150)
                
                Spacer()
                
                Circle()
                    .fill(Color.themePrimary.opacity(0.1))
                    .frame(width: 250, height: 250)
                    .blur(radius: 70)
                    .offset(x: 100, y: 100)
            }
            .ignoresSafeArea()
            
            TabView(selection: $selectedIndex) {
                ForEach(0..<hadiths.count, id: \.self) { index in
                    HadithCardView(hadith: hadiths[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            // Alt Bilgi (Sayfa Sayısı)
            VStack {
                Spacer()
                HStack {
                    Text("\(selectedIndex + 1) / \(hadiths.count)")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(.themeTextSecondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.themeSurface.opacity(0.4))
                        .clipShape(Capsule())
                }
                .padding(.bottom, 40)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    UIPasteboard.general.string = hadiths[selectedIndex].content
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                }) {
                    Image(systemName: "doc.on.doc")
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                if let url = URL(string: "https://apps.apple.com/app/id6741160100") {
                    ShareLink(item: "\(hadiths[selectedIndex].content)\n\n\(L10n.Hadith.title) - Vera App\n\(url.absoluteString)") {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
    }
}

struct HadithCardView: View {
    let hadith: Hadith
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "quote.bubble.fill")
                .font(.system(size: 40))
                .foregroundColor(.themePrimary)
                .opacity(0.8)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    Text("#\(hadith.hadithNo)")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundColor(.themePrimary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Color.themePrimary.opacity(0.1))
                        .clipShape(Capsule())
                    
                    Text(hadith.content)
                        .font(.system(size: 22, weight: .medium, design: .serif))
                        .multilineTextAlignment(.center)
                        .lineSpacing(10)
                        .foregroundColor(.themeText)
                        .padding(.horizontal, 10)
                }
                .padding(.vertical, 20)
            }
        }
        .padding(30)
        .frame(maxWidth: .infinity)
        .frame(height: UIScreen.main.bounds.height * 0.65)
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(Color.themeSurface.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .padding(20)
        .shadow(color: Color.black.opacity(0.1), radius: 25, x: 0, y: 15)
    }
}
