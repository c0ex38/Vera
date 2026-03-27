import Foundation
import Combine

@MainActor
class PrayerSurahsViewModel: ObservableObject {
    @Published var surahs: [Surah] = []
    
    private let database: DatabaseProvider
    
    init(database: DatabaseProvider? = nil) {
        self.database = database ?? AppDatabaseManager.shared
        loadSurahs()
    }

    
    private func loadSurahs() {
        Task {
            surahs = await database.fetchPrayerSurahs()
        }
    }

}

