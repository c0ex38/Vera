import SwiftUI

struct QuranIndexView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = QuranIndexViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            VeraCustomHeader(title: L10n.Quran.title, subtitle: L10n.Quran.surahs) {
                presentationMode.wrappedValue.dismiss()
            }
            
            if viewModel.isLoading && viewModel.surahs.isEmpty {
                Spacer()
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text(L10n.Quran.loading)
                        .foregroundColor(.themeTextSecondary)
                }
                Spacer()
            } else {
                ScrollView {
                    let columns = [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ]
                    
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        LazyVGrid(columns: columns, spacing: 16) {
                            surahListRows
                        }
                        .padding()
                    } else {
                        LazyVStack(spacing: 12) {
                            surahListRows
                        }
                        .padding()
                    }
                }
            }
        }
        .background(Color.themeBackground)
        .navigationBarHidden(true)
        .onAppear {
            viewModel.loadSurahs()
        }
    }
    
    private var surahListRows: some View {
        ForEach(viewModel.surahs) { chapter in
            NavigationLink(destination: QuranPageView(initialPage: chapter.pageNumber)) {
                HStack {
                    ZStack {
                        Image(systemName: "star.fill")
                            .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 44 : 32))
                            .foregroundColor(.themeSurface)
                            .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
                        Text("\(chapter.id)")
                            .font(UIDevice.current.userInterfaceIdiom == .pad ? .body : .caption)
                            .bold()
                            .foregroundColor(.themeText)
                    }
                    .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? 56 : 44, height: UIDevice.current.userInterfaceIdiom == .pad ? 56 : 44)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(chapter.name)
                            .font(UIDevice.current.userInterfaceIdiom == .pad ? .title3.bold() : .headline)
                            .foregroundColor(.themeText)
                        
                        Text("\(chapter.verseCount) \(L10n.Quran.verse) • \(L10n.Quran.page): \(chapter.pageNumber)")
                            .font(UIDevice.current.userInterfaceIdiom == .pad ? .body : .caption)
                            .foregroundColor(.themeTextSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 18 : 14, weight: .bold))
                        .foregroundColor(.gray.opacity(0.4))
                }
                .padding(UIDevice.current.userInterfaceIdiom == .pad ? 20 : 16)
                .background(Color.themeSurface)
                .cornerRadius(UIDevice.current.userInterfaceIdiom == .pad ? 16 : 12)
                .shadow(color: .black.opacity(0.03), radius: 5, y: 3)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

