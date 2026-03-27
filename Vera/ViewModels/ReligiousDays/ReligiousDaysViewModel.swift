import Foundation
import Combine

@MainActor
class ReligiousDaysViewModel: ObservableObject {
    @Published var days: [ReligiousDay] = []
    
    private let database: DatabaseProvider
    
    init(database: DatabaseProvider? = nil) {
        self.database = database ?? AppDatabaseManager.shared
        loadDays()
    }

    
    private func loadDays() {
        Task {
            days = await database.fetchReligiousDays()
        }
    }

}

