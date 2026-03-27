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
    
    var body: some View {
        ZStack {
            Color.themeBackground.ignoresSafeArea()
            
            VStack {
                if isLoading {
                    ProgressView()
                } else {
                    List {
                        ForEach(filteredHadiths) { hadith in
                            HadithRow(hadith: hadith)
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.plain)
                    .searchable(text: $searchText, prompt: L10n.Hadith.searchPlaceholder)
                }
            }
        }
        .navigationTitle(L10n.Hadith.title)
        .navigationBarTitleDisplayMode(.large)
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
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("#\(hadith.hadithNo)")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.themePrimary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.themePrimary.opacity(0.1))
                    .clipShape(Capsule())
                
                Spacer()
                
                Button(action: {
                    UIPasteboard.general.string = hadith.content
                }) {
                    Image(systemName: "doc.on.doc")
                        .foregroundColor(.themeTextSecondary)
                }
            }
            
            Text(hadith.content)
                .font(.veraContent)
                .foregroundColor(.themeText)
                .lineSpacing(4)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.themeSurface.opacity(0.6))
        )
        .padding(.horizontal, 4)
        .padding(.vertical, 8)
    }
}
