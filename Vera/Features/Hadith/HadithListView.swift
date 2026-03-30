import SwiftUI

struct HadithListView: View {
    @State private var hadiths: [Hadith] = []
    @State private var searchText: String = ""
    @State private var isLoading: Bool = true
    @State private var isMoreLoading: Bool = false
    @State private var canLoadMore: Bool = true
    @State private var totalCount: Int = 0
    @State private var offset: Int = 0
    private let limit: Int = 20
    
    // Arama için debounce/throttle simülasyonu (Simple version for SwiftUI)
    @State private var searchTask: Task<Void, Never>? = nil
    
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
                        .onChange(of: searchText) { oldValue, newValue in
                            handleSearchChange(newValue)
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: { 
                            searchText = ""
                            loadInitialHadiths()
                        }) {
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
                } else if hadiths.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "quote.bubble")
                            .font(.system(size: 44))
                            .foregroundColor(.themeTextSecondary.opacity(0.3))
                        Text(searchText.isEmpty ? "Hadisler yüklenemedi." : "Arama sonucu bulunamadı.")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.themeTextSecondary)
                    }
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 16) {
                            ForEach(Array(hadiths.enumerated()), id: \.element.id) { index, hadith in
                                NavigationLink(destination: HadithPageView(hadiths: hadiths, selectedIndex: index)) {
                                    HadithRow(hadith: hadith)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .onAppear {
                                    // Sayfanın en sonuna gelindiğinde ve arama yapılmıyorken yeni sayfa yükle
                                    if index == hadiths.count - 1 && canLoadMore && searchText.isEmpty {
                                        loadMoreHadiths()
                                    }
                                }
                            }
                            
                            if isMoreLoading && searchText.isEmpty {
                                ProgressView()
                                    .padding(.vertical, 20)
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
            if hadiths.isEmpty {
                loadInitialHadiths()
            }
        }
    }
    
    private func loadInitialHadiths() {
        isLoading = true
        offset = 0
        canLoadMore = true
        
        Task {
            let manager = AppDatabaseManager.shared
            self.totalCount = await manager.fetchHadithCount()
            let initialHadiths = await manager.fetchHadithsPaged(offset: 0, limit: limit)
            
            await MainActor.run {
                self.hadiths = initialHadiths
                self.offset = initialHadiths.count
                self.canLoadMore = self.offset < totalCount
                self.isLoading = false
            }
        }
    }
    
    private func loadMoreHadiths() {
        guard !isMoreLoading && canLoadMore else { return }
        isMoreLoading = true
        
        Task {
            let manager = AppDatabaseManager.shared
            let nextBatch = await manager.fetchHadithsPaged(offset: offset, limit: limit)
            
            await MainActor.run {
                self.hadiths.append(contentsOf: nextBatch)
                self.offset += nextBatch.count
                self.canLoadMore = self.offset < totalCount
                self.isMoreLoading = false
            }
        }
    }
    
    private func handleSearchChange(_ query: String) {
        searchTask?.cancel()
        
        if query.isEmpty {
            loadInitialHadiths()
            return
        }
        
        searchTask = Task {
            // Küçük bir bekleme (debounce)
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 saniye
            if Task.isCancelled { return }
            
            let manager = AppDatabaseManager.shared
            let results = await manager.searchHadiths(query: query)
            
            await MainActor.run {
                self.hadiths = results
                self.canLoadMore = false // Arama sonuçlarında pagination devre dışı
                self.isLoading = false
            }
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
