import SwiftUI

struct SermonListView: View {
    @StateObject private var viewModel = SermonViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("Haftalık Hutbe Arşivi")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                    
                    Spacer()
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                }
                .foregroundColor(.themeText)
                .padding(.horizontal, 20)
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.system(size: 13))
                        .foregroundColor(.red.opacity(0.8))
                        .padding(.horizontal, 20)
                }
                
                VStack(spacing: 12) {
                    ForEach(viewModel.sermons) { sermon in
                        NavigationLink(destination: WebViewContainer(url: URL(string: sermon.pdfURL)!, title: sermon.title)) {
                            sermonCard(sermon: sermon)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
                
                // Kaynak Bilgisi
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.themePrimary)
                    Text("Hutbe içerikleri Diyanet İşleri Başkanlığı'ndan (dinhizmetleri.diyanet.gov.tr) otomatik olarak güncellenmektedir.")
                        .font(.system(size: 11))
                        .foregroundColor(.themeTextSecondary)
                }
                .padding(16)
                .frame(maxWidth: .infinity)
                .background(Color.themeSurface.opacity(0.5))
                .cornerRadius(12)
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            .padding(.vertical, 20)
        }
        .refreshable {
            await viewModel.refreshSermons()
        }
        .task {
            await viewModel.refreshSermons()
        }
        .background(Color.themeBackground.ignoresSafeArea())
        .navigationTitle("Haftanın Hutbesi")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func sermonCard(sermon: Sermon) -> some View {
        HStack(spacing: 16) {
            // Tarih İkonu
            VStack(spacing: 2) {
                Text(sermon.date.prefix(2))
                    .font(.system(size: 18, weight: .bold))
                Text(getMonthAbbreviation(sermon.date))
                    .font(.system(size: 10, weight: .medium))
                    .textCase(.uppercase)
            }
            .foregroundColor(.white)
            .frame(width: 50, height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.themePrimary)
            )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(sermon.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.themeText)
                    .lineLimit(2)
                
                Text(sermon.date)
                    .font(.system(size: 12))
                    .foregroundColor(.themeTextSecondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.themeTextSecondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.themeSurface)
                .shadow(color: .black.opacity(0.04), radius: 10, y: 5)
        )
    }
    
    private func getMonthAbbreviation(_ date: String) -> String {
        let components = date.components(separatedBy: ".")
        guard components.count >= 2 else { return "AY" }
        let month = components[1]
        
        switch month {
        case "01": return "OCA"
        case "02": return "ŞUB"
        case "03": return "MAR"
        case "04": return "NİS"
        case "05": return "MAY"
        case "06": return "HAZ"
        case "07": return "TEM"
        case "08": return "AĞU"
        case "09": return "EYL"
        case "10": return "EKİ"
        case "11": return "KAS"
        case "12": return "ARA"
        default: return "AY"
        }
    }
}

// WebViewContainer for PDF viewing
struct WebViewContainer: View {
    let url: URL
    let title: String
    
    var body: some View {
        WebView(url: url)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
    }
}
