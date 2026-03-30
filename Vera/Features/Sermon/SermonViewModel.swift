import SwiftUI
import Combine

@MainActor
class SermonViewModel: ObservableObject {
    @Published var sermons: [Sermon] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let sermonService: SermonServiceProvider
    
    init(sermonService: SermonServiceProvider? = nil) {
        self.sermonService = sermonService ?? SermonService.shared
        self.sermons = []
    }
    
    func refreshSermons() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetched = try await sermonService.fetchLatestSermons()
            if !fetched.isEmpty {
                // Tarihe göre sırala (Yeni en üstte)
                self.sermons = fetched.sorted { s1, s2 in
                    let d1 = s1.date.components(separatedBy: ".").reversed().joined()
                    let d2 = s2.date.components(separatedBy: ".").reversed().joined()
                    return d1 > d2
                }
            }
        } catch {
            DebugLog.error("Sermon Fetch Error: \(error)")
            self.errorMessage = L10n.Sermon.errorUpdate
        }
        
        isLoading = false
    }
}
