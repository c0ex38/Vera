import Foundation
import Combine
import SwiftUI

@MainActor
class QuranPageViewModel: ObservableObject {
    @Published var pageCache: [Int: [QuranVerse]] = [:]
    @Published var availableAuthors: [QuranAuthor] = []
    
    // Centralized preferences
    private let preferences = PreferenceManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    @Published var selectedAuthorId: Int
    
    private let database: DatabaseProvider
    
    init(database: DatabaseProvider? = nil) {
        self.database = database ?? AppDatabaseManager.shared
        self.selectedAuthorId = preferences.selectedQuranAuthorId
        
        Task {
            self.availableAuthors = await self.database.fetchAuthors()
        }
        
        setupBindings()
    }
    
    private func setupBindings() {
        $selectedAuthorId.dropFirst().sink { [weak self] in 
            self?.preferences.selectedQuranAuthorId = $0
        }.store(in: &cancellables)
    }

    var currentAuthorName: String {
        availableAuthors.first(where: { $0.id == selectedAuthorId })?.name ?? "Diyanet İşleri (Yeni)"
    }
    
    func loadPage(_ pageNumber: Int) {
        guard pageNumber >= 1 && pageNumber <= 604 else { return }
        
        if pageCache[pageNumber] != nil {
            return
        }
        
        Task(priority: .userInitiated) {
            let verses = await database.fetchVersesForPage(page: pageNumber, authorId: selectedAuthorId)
            self.pageCache[pageNumber] = verses
        }
    }
    
    func reloadAllPages(currentPage: Int) {
        pageCache.removeAll()
        loadPage(currentPage)
    }
}
