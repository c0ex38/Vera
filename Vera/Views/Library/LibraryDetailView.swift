import SwiftUI

struct LibraryDetailView: View {
    let article: LibraryArticle
    @State private var fontSize: CGFloat = 17
    
    var body: some View {
        VStack(spacing: 0) {
            // Kontrol Paneli (Yazı Boyutu vb.)
            HStack {
                Text("Yazı Boyutu")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.themeTextSecondary)
                
                Spacer()
                
                Button(action: { if fontSize > 14 { fontSize -= 1 } }) {
                    Image(systemName: "textformat.size.smaller")
                        .padding(8)
                        .background(Circle().fill(Color.themeSurface))
                }
                
                Button(action: { if fontSize < 30 { fontSize += 1 } }) {
                    Image(systemName: "textformat.size.larger")
                        .padding(8)
                        .background(Circle().fill(Color.themeSurface))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.themeSurface.opacity(0.5))
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // İçerik Başlığı
                    Text(article.title)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.themeText)
                    
                    // Ana Metin
                    Text(article.content)
                        .font(.system(size: fontSize, weight: .regular, design: .serif))
                        .foregroundColor(.themeText)
                        .lineSpacing(8)
                    
                    if let source = article.source {
                        VStack(alignment: .leading, spacing: 4) {
                            Divider()
                            Text("Kaynak: \(source)")
                                .font(.system(size: 12, weight: .regular))
                                .italic()
                                .foregroundColor(.themeTextSecondary)
                        }
                        .padding(.top, 20)
                    }
                    
                    Spacer(minLength: 50)
                }
                .padding(24)
            }
        }
        .background(Color.themeBackground.ignoresSafeArea())
        .navigationTitle("Bilgi Detayı")
        .navigationBarTitleDisplayMode(.inline)
    }
}
