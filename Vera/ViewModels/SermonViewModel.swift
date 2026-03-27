import SwiftUI
import Combine

@MainActor
class SermonViewModel: ObservableObject {
    @Published var sermons: [Sermon] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Fallback/Initial Data
    private let fallbackSermons: [Sermon] = [
        Sermon(date: "20.03.2026", title: "Ramazan Bayramı", pdfURL: "https://dinhizmetleri.diyanet.gov.tr/Documents/Ramazan%20Bayram%C4%B1.pdf", audioURL: nil),
        Sermon(date: "20.03.2026", title: "Hayatı Ramazan Kılmak", pdfURL: "https://dinhizmetleri.diyanet.gov.tr/Documents/Hayat%C4%B1%20Ramazan%20K%C4%B1lmak.pdf", audioURL: nil),
        Sermon(date: "13.03.2026", title: "Hak ve Hakikatin Temsilcileri: Peygamberler", pdfURL: "https://dinhizmetleri.diyanet.gov.tr/Documents/Hak%20ve%20Hakikatin%20Temsilcileri;%20Peygamberler.pdf", audioURL: nil)
    ]
    
    init() {
        self.sermons = fallbackSermons
    }
    
    func refreshSermons() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetched = try await SermonService.shared.fetchLatestSermons()
            if !fetched.isEmpty {
                // Tarihe göre sırala (Yeni en üstte)
                self.sermons = fetched.sorted { s1, s2 in
                    let d1 = s1.date.components(separatedBy: ".").reversed().joined()
                    let d2 = s2.date.components(separatedBy: ".").reversed().joined()
                    return d1 > d2
                }
            }
        } catch {
            print("Fetch Error: \(error)")
            self.errorMessage = "Hutbeler güncellenemedi. Lütfen internet bağlantınızı kontrol edin."
        }
        
        isLoading = false
    }
}
