import SwiftUI
import Combine
import WidgetKit

@MainActor
class SettingsViewModel: ObservableObject {
    @AppStorage("notificationsEnabled") var notificationsEnabled: Bool = true {
        didSet {
            // Notifications logic handled in view for now
        }
    }
    
    @AppStorage("appTheme") var appTheme: Int = 0 // 0: System, 1: Light, 2: Dark
    @AppStorage("autoLocationEnabled") var autoLocationEnabled: Bool = true
    @AppStorage("appLanguage") var appLanguage: String = "tr" // For now only "tr"
    
    @AppStorage("selectedQuranAuthorId") var selectedQuranAuthorId: Int = 11
    
    @AppStorage("savedDistrictID")
    var savedDistrictID: String = ""
    
    @AppStorage("savedLocationName")
    var savedLocationName: String = ""
    
    // Contact form fields
    @Published var contactName: String = ""
    @Published var contactEmail: String = ""
    @Published var contactMessage: String = ""
    @Published var isShowingAlert: Bool = false
    
    @Published var availableAuthors: [QuranAuthor] = []
    
    private let database: DatabaseProvider
    
    init(database: DatabaseProvider? = nil) {
        self.database = database ?? AppDatabaseManager.shared
    }
    
    func loadAuthors() {
        Task {
            self.availableAuthors = await database.fetchAuthors()
        }
    }

    
    func submitContactForm() {
        // Here we would typically make an API call, for now we just show a success alert
        isShowingAlert = true
    }
}
