import SwiftUI

struct HadithListView: View {
    @State private var hadiths: [Hadith] = []
    @State private var searchText: String = ""
    @State private var isLoading: Bool = true
    
    var filteredHadiths: [Hadith] {
        if searchText.isEmpty {
            return hadiths
        } else {
            return hadiths.filter { 
                $0.content.localizedCaseInsensitiveContains(searchText) ||
                "\($0.hadithNo)".contains(searchText)
            }
        }
    }
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color.themeBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Özel Header
                VeraCustomHeader(title: L10n.Hadith.title)
                    .padding(.bottom, 10)
                
                // Özel Arama Çubuğu
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.themeTextSecondary)
                        .font(.system(size: 16, weight: .bold))
                    
                    TextField(L10n.Hadith.searchPlaceholder, text: $searchText)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.themeText)
                    
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.themeTextSecondary)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.themeSurface.opacity(0.4))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
                
                if isLoading {
                    Spacer()
                    ProgressView()
                        .tint(.themePrimary)
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 16) {
                            ForEach(Array(filteredHadiths.enumerated()), id: \.element.id) { index, hadith in
                                NavigationLink(destination: HadithPageView(hadiths: filteredHadiths, selectedIndex: index)) {
                                    HadithRow(hadith: hadith)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 4)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            loadHadiths()
        }
    }
    
    private func loadHadiths() {
        Task {
            let manager = AppDatabaseManager.shared
            // We need to implement fetchAllHadiths in AppDatabaseManager
            self.hadiths = await manager.fetchAllHadiths()
            self.isLoading = false
        }
    }
}

struct HadithRow: View {
    let hadith: Hadith
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "number")
                        .font(.system(size: 10, weight: .bold))
                    Text("\(hadith.hadithNo)")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                }
                .foregroundColor(.themePrimary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.themePrimary.opacity(0.1))
                .clipShape(Capsule())
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.themeTextSecondary.opacity(0.5))
            }
            
            Text(hadith.content)
                .font(.system(size: 16, weight: .medium, design: .serif))
                .foregroundColor(.themeText)
                .lineSpacing(5)
                .lineLimit(4)
                .multilineTextAlignment(.leading)
            
            HStack {
                Spacer()
                Image(systemName: "quote.bubble.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.themePrimary.opacity(0.3))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.themeSurface.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
    }
}
