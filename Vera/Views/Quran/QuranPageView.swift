import SwiftUI

let surahNames = ["Fâtiha", "Bakara", "Âl-i İmrân", "Nisâ", "Mâide", "En'âm", "A'râf", "Enfâl", "Tevbe", "Yûnus", "Hûd", "Yûsuf", "Ra'd", "İbrâhim", "Hicr", "Nahl", "İsrâ", "Kehf", "Meryem", "Tâhâ", "Enbiyâ", "Hac", "Mü'minûn", "Nûr", "Furkan", "Şuarâ", "Neml", "Kasas", "Ankebût", "Rûm", "Lokmân", "Secde", "Ahzâb", "Sebe'", "Fâtır", "Yâsîn", "Sâffât", "Sâd", "Zümer", "Mü'min", "Fussilet", "Şûrâ", "Zuhruf", "Duhân", "Câsiye", "Ahkâf", "Muhammed", "Fetih", "Hucurât", "Kâf", "Zâriyât", "Tûr", "Necm", "Kamer", "Rahmân", "Vâkıa", "Hadîd", "Mücâdele", "Haşr", "Mümtehine", "Saf", "Cuma", "Münâfikûn", "Tegâbün", "Talâk", "Tahrîm", "Mülk", "Kalem", "Hâkka", "Meâric", "Nûh", "Cin", "Müzzemmil", "Müddessir", "Kıyâme", "İnsan", "Mürselât", "Nebe'", "Nâziât", "Abese", "Tekvîr", "İnfitâr", "Mutaffifîn", "İnşikâk", "Bürûc", "Târık", "A'lâ", "Gâşiye", "Fecr", "Beled", "Şems", "Leyl", "Duhâ", "İnşirâh", "Tîn", "Alak", "Kadr", "Beyyine", "Zilzâl", "Âdiyât", "Kâria", "Tekâsür", "Asr", "Hümeze", "Fîl", "Kureyş", "Mâûn", "Kevser", "Kâfirûn", "Nasr", "Tebbet", "İhlâs", "Felak", "Nâs"]

struct QuranPageView: View {
    @StateObject private var viewModel = QuranPageViewModel()
    @State private var currentPage: Int
    @Environment(\.presentationMode) var presentationMode
    private let haptic = UIImpactFeedbackGenerator(style: .soft)
    
    init(initialPage: Int = 1) {
        _currentPage = State(initialValue: initialPage)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Başlık
            VeraCustomHeader(
                title: "Kuran-ı Kerim",
                subtitle: "Kuran Oku",
                showBackButton: presentationMode.wrappedValue.isPresented
            )
            .padding(.bottom, 8)
            
            // Modern Kontrol Çubuğu (Meal Seçici ve Sayfa Navigasyonu)
            HStack(spacing: 12) {
                // Sayfa Geri
                Button(action: {
                    if currentPage > 1 {
                        haptic.impactOccurred()
                        currentPage -= 1 
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(currentPage > 1 ? .themePrimary : .gray.opacity(0.3))
                        .frame(width: 36, height: 36)
                        .background(Color.themeBackground)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.05), radius: 3, y: 1)
                }
                .disabled(currentPage <= 1)
                
                // Orta Kapsül: Meal Yazar Seçici 
                Menu {
                    ForEach(viewModel.availableAuthors, id: \.id) { author in
                        Button(action: {
                            viewModel.selectedAuthorId = author.id
                            viewModel.reloadAllPages(currentPage: currentPage)
                        }) {
                            HStack {
                                Text(author.name)
                                if viewModel.selectedAuthorId == author.id {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "text.book.closed.fill")
                            .font(.system(size: 12))
                        Text(viewModel.currentAuthorName)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.system(size: 10))
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.themePrimary)
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity, minHeight: 40)
                    .background(Color.themePrimary.opacity(0.08))
                    .clipShape(Capsule())
                }
                
                // Sayfa İleri
                Button(action: {
                    if currentPage < 604 {
                        haptic.impactOccurred()
                        currentPage += 1 
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(currentPage < 604 ? .themePrimary : .gray.opacity(0.3))
                        .frame(width: 36, height: 36)
                        .background(Color.themeBackground)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.05), radius: 3, y: 1)
                }
                .disabled(currentPage >= 604)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
            
            // Mini Sayfa Göstergesi
            Text("Sayfa \(currentPage) / 604")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.themeTextSecondary)
                .padding(.bottom, 12)
            
            // İçerik Sayfası (Kuran)
            ZStack {
                Color.themeBackground.ignoresSafeArea()
                
                TabView(selection: $currentPage) {
                    ForEach(1...604, id: \.self) { pageNum in
                        QuranSinglePageView(pageNumber: pageNum, viewModel: viewModel)
                            .tag(pageNum)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .onChange(of: currentPage) { _, newPage in
                    viewModel.loadPage(newPage)
                }
            }
        }
        .background(Color.themeSurface)
        .navigationBarHidden(true)
        .onAppear {
            viewModel.loadPage(currentPage)
        }
    }
}

struct QuranSinglePageView: View {
    let pageNumber: Int
    @ObservedObject var viewModel: QuranPageViewModel
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 24) {
                if let verses = viewModel.pageCache[pageNumber] {
                    if verses.isEmpty {
                        VStack(spacing: 20) {
                            Text("Bu sayfada ayet bulunamadı.")
                                .foregroundColor(.themeTextSecondary)
                                .padding(.top, 50)
                            
                            Text("⚠️ HATA: vera.sqlite dosyası proje Bundle'ına eklenmemiş olabilir. Lütfen Finder'daki vera.sqlite'ı Vera projesi (Xcode sol panel) içine sürükleyip 'Copy Items if needed' diyerek işaretleyin.")
                                .font(.caption)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    } else {
                        ForEach(verses) { verse in
                            VStack(spacing: 0) {
                                // Sure Başlığı (Eğer Ayet 1 ise)
                                if verse.verseNumberInSurah == 1 {
                                    let surahTitle = verse.surahId >= 1 && verse.surahId <= 114 ? surahNames[verse.surahId - 1] : "Sure \(verse.surahId)"
                                    
                                    HStack {
                                        Spacer()
                                        Text(surahTitle)
                                            .font(.system(size: 26, weight: .heavy, design: .serif))
                                            .foregroundColor(.themePrimary)
                                            .kerning(2)
                                        Spacer()
                                    }
                                    .padding(.vertical, 20)
                                    .background(
                                        Image(systemName: "seal.fill") // Motif havası vermek için
                                            .resizable()
                                            .opacity(0.03)
                                            .foregroundColor(.themePrimary)
                                            .scaledToFill()
                                    )
                                    .background(Color.themePrimary.opacity(0.05))
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.themePrimary.opacity(0.15), lineWidth: 1.5)
                                    )
                                    .padding(.horizontal, 20)
                                    .padding(.bottom, 24)
                                }
                                
                                // Ayet Premium Kartı (Card UI)
                                VStack(alignment: .trailing, spacing: 18) {
                                    
                                    // Üst Kısım: Ayet Numarası (Sol) ve Arapça Metin (Sağ)
                                    HStack(alignment: .top) {
                                        // Zarif Ayet Rozeti
                                        ZStack {
                                            Circle()
                                                .fill(Color.themePrimary.opacity(0.08))
                                                .frame(width: 32, height: 32)
                                            Circle()
                                                .strokeBorder(Color.themePrimary.opacity(0.3), lineWidth: 1)
                                                .frame(width: 32, height: 32)
                                            Text("\(verse.verseNumberInSurah)")
                                                .font(.system(size: 13, weight: .heavy))
                                                .foregroundColor(.themePrimary)
                                        }
                                        .padding(.top, 6)
                                        
                                        Spacer(minLength: 20)
                                        
                                        // Arapça Metin
                                        if !verse.text.isEmpty {
                                            Text(verse.text)
                                                // Sistem varsayılan serif fontu ile Kurani hava verilir
                                                .font(.system(size: 32, weight: .medium, design: .serif))
                                                .multilineTextAlignment(.trailing)
                                                .foregroundColor(.themeText)
                                                .lineSpacing(18)
                                        }
                                    }
                                    
                                    // Okunuşu (Transliteration - İtalik ve Premium Yeşil)
                                    if !verse.transcription.isEmpty {
                                        Text(verse.transcription)
                                            .font(.system(size: 15, weight: .medium, design: .serif))
                                            .italic()
                                            .foregroundColor(.themePrimary.opacity(0.9))
                                            .multilineTextAlignment(.leading)
                                            .lineSpacing(6)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.top, 4)
                                    }
                                    
                                    // Türkçe Çevirisi (Meali - Koyu Gri/Siyah, Okunaklı)
                                    if !verse.translation.isEmpty {
                                        Text(verse.translation)
                                            .font(.system(size: 16, weight: .regular))
                                            .foregroundColor(.themeTextSecondary)
                                            .multilineTextAlignment(.leading)
                                            .lineSpacing(8)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                                .padding(24)
                                .background(Color.themeSurface)
                                .cornerRadius(20)
                                .shadow(color: .black.opacity(0.04), radius: 10, y: 5)
                                .padding(.horizontal, 16)
                            }
                        }
                    }
                }
            }
            .padding(.top, 16)
            .padding(.bottom, 120) // Custom TabBar ve Reklam altında ezilmemesi için padding
        }
    }
}
