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
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.surahs) { chapter in
                            NavigationLink(destination: QuranPageView(initialPage: chapter.pageNumber)) {
                                HStack {
                                    ZStack {
                                        Image(systemName: "star.fill")
                                            .font(.system(size: 32))
                                            .foregroundColor(.themeSurface)
                                            .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
                                        Text("\(chapter.id)")
                                            .font(.caption)
                                            .bold()
                                            .foregroundColor(.themeText)
                                    }
                                    .frame(width: 44, height: 44)
                                    
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(chapter.name)
                                            .font(.headline)
                                            .foregroundColor(.themeText)
                                        
                                        Text("\(chapter.verseCount) \(L10n.Quran.verse) • \(L10n.Quran.page): \(chapter.pageNumber)")
                                            .font(.caption)
                                            .foregroundColor(.themeTextSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.gray.opacity(0.4))
                                }
                                .padding()
                                .background(Color.themeSurface)
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.03), radius: 5, y: 3)
                            }
                            // Modern Spring Effect
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
            }
        }
        .background(Color.themeBackground)
        .navigationBarHidden(true)
        .onAppear {
            viewModel.loadSurahs()
        }
    }
}

