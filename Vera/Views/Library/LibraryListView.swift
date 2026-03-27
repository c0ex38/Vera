import SwiftUI

struct LibraryListView: View {
    let categories = LibraryData.categories
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header (Zaten NavigationView başlığı var ama özel bir giriş ekleyebiliriz)
                Text("İlmihal ve Dini Bilgiler")
                    .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 32 : 24, weight: .bold, design: .rounded))
                    .foregroundColor(.themeText)
                    .padding(.horizontal, 20)
                
                let columns = Array(repeating: GridItem(.flexible(), spacing: 20), count: UIDevice.current.userInterfaceIdiom == .pad ? 3 : 2)
                
                LazyVGrid(columns: columns, spacing: UIDevice.current.userInterfaceIdiom == .pad ? 20 : 16) {
                    ForEach(categories) { category in
                        NavigationLink(destination: LibraryCategoryDetailView(category: category)) {
                            categoryCard(category: category)
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                // Bilgi Kartı
                infoCard
            }
            .padding(.vertical, 20)
        }
        .background(Color.themeBackground.ignoresSafeArea())
        .navigationTitle("Kütüphane")
        .navigationBarTitleDisplayMode(.large)
    }
    
    // MARK: - Category Card Component
    private func categoryCard(category: LibraryCategory) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(category.color.opacity(0.12))
                    .frame(width: 56, height: 56)
                
                Image(systemName: category.icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(category.color)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(category.title)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.themeText)
                
                Text(category.description)
                    .font(.system(size: 13))
                    .foregroundColor(.themeTextSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.themeSurface)
                .shadow(color: .black.opacity(0.03), radius: 10, y: 5)
        )
    }
    
    private var infoCard: some View {
        HStack {
            Image(systemName: "info.circle.fill")
                .foregroundColor(.themePrimary)
            Text("İçerikler güvenilir kaynaklardan ve ilmihallerden derlenmiştir.")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.themeTextSecondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.themePrimary.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
}

// Preview
#Preview {
    NavigationView {
        LibraryListView()
    }
}
