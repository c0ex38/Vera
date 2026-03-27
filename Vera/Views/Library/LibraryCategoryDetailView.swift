import SwiftUI

struct LibraryCategoryDetailView: View {
    let category: LibraryCategory
    let articles: [LibraryArticle]
    
    init(category: LibraryCategory) {
        self.category = category
        self.articles = LibraryData.getArticles(for: category.id)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Kategori Bilgi Başlığı
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(category.color.opacity(0.1))
                            .frame(width: 64, height: 64)
                        Image(systemName: category.icon)
                            .font(.system(size: 28))
                            .foregroundColor(category.color)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(category.title)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.themeText)
                        Text(category.description)
                            .font(.system(size: 14))
                            .foregroundColor(.themeTextSecondary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                Divider()
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                
                // Makale Listesi
                if articles.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(.themeTextSecondary.opacity(0.3))
                        Text("Bu kategoriye henüz içerik eklenmedi.")
                            .font(.system(size: 15))
                            .foregroundColor(.themeTextSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 50)
                } else {
                    VStack(spacing: 12) {
                        ForEach(articles) { article in
                            NavigationLink(destination: LibraryDetailView(article: article)) {
                                articleRow(article: article)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .padding(.vertical, 20)
        }
        .background(Color.themeBackground.ignoresSafeArea())
        .navigationTitle(category.title)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func articleRow(article: LibraryArticle) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(article.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.themeText)
                
                if let source = article.source {
                    Text("Kaynak: \(source)")
                        .font(.system(size: 12))
                        .foregroundColor(.themeTextSecondary)
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.themeTextSecondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.themeSurface)
                .shadow(color: .black.opacity(0.02), radius: 5, y: 3)
        )
    }
}
