import Foundation
import Combine
import SwiftUI

@MainActor
class QuranPageViewModel: ObservableObject {
    @Published var pageCache: [Int: [QuranVerse]] = [:]
    @Published var availableAuthors: [QuranAuthor] = []
    
    @AppStorage("selectedQuranAuthorId") var selectedAuthorId: Int = 11
    
    private let database: DatabaseProvider
    
    init(database: DatabaseProvider? = nil) {
        self.database = database ?? AppDatabaseManager.shared
        Task {
            self.availableAuthors = await self.database.fetchAuthors()
        }
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
            let verses = await database.fetchVersesForPage(page: pageNumber)
            self.pageCache[pageNumber] = verses
        }
    }

    
    func reloadAllPages(currentPage: Int) {
        pageCache.removeAll()
        loadPage(currentPage)
    }
}

