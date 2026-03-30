import Foundation
import SwiftUI
import Combine

@MainActor
class QuranIndexViewModel: ObservableObject {
    @Published var surahs: [QuranChapter] = []
    @Published var isLoading: Bool = false
    
    private let database: DatabaseProvider
    
    init(database: DatabaseProvider? = nil) {
        self.database = database ?? AppDatabaseManager.shared
    }

    
    func loadSurahs() {
        isLoading = true
        Task {
            self.surahs = await database.fetchSurahs()
            self.isLoading = false
        }
    }
}
