import Foundation
import Combine

@MainActor
class EsmaulHusnaViewModel: ObservableObject {
    @Published var esmaulHusnaList: [EsmaulHusna] = []
    
    private let database: DatabaseProvider
    
    init(database: DatabaseProvider? = nil) {
        self.database = database ?? AppDatabaseManager.shared
        loadData()
    }

    
    private func loadData() {
        Task {
            esmaulHusnaList = await database.fetchEsmaulHusna()
        }
    }

}

