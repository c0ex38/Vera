import SwiftUI
import Combine
import WidgetKit

@MainActor
class SettingsViewModel: ObservableObject {
    
    // Centralized preferences
    private let preferences = PreferenceManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    @Published var notificationsEnabled: Bool
    @Published var appTheme: Int
    @Published var autoLocationEnabled: Bool
    @Published var appLanguage: String
    @Published var selectedQuranAuthorId: Int
    
    @Published var savedDistrictID: String
    @Published var savedLocationName: String
    
    // Contact form fields
    @Published var contactName: String = ""
    @Published var contactEmail: String = ""
    @Published var contactMessage: String = ""
    @Published var isShowingAlert: Bool = false
    @Published var isShowingResetConfirmation: Bool = false
    
    @Published var availableAuthors: [QuranAuthor] = []
    
    private let database: DatabaseProvider
    
    init(database: DatabaseProvider? = nil) {
        self.database = database ?? AppDatabaseManager.shared
        
        // Initialize from preferences
        self.notificationsEnabled = preferences.notificationsEnabled
        self.appTheme = preferences.appTheme
        self.autoLocationEnabled = preferences.autoLocationEnabled
        self.appLanguage = preferences.appLanguage
        self.selectedQuranAuthorId = preferences.selectedQuranAuthorId
        self.savedDistrictID = preferences.savedDistrictID
        self.savedLocationName = preferences.savedLocationName
        
        setupBindings()
    }
    
    private func setupBindings() {
        $notificationsEnabled.dropFirst().sink { [weak self] in self?.preferences.notificationsEnabled = $0 }.store(in: &cancellables)
        $appTheme.dropFirst().sink { [weak self] in self?.preferences.appTheme = $0 }.store(in: &cancellables)
        $autoLocationEnabled.dropFirst().sink { [weak self] in self?.preferences.autoLocationEnabled = $0 }.store(in: &cancellables)
        $appLanguage.dropFirst().sink { [weak self] in self?.preferences.appLanguage = $0 }.store(in: &cancellables)
        $selectedQuranAuthorId.dropFirst().sink { [weak self] in self?.preferences.selectedQuranAuthorId = $0 }.store(in: &cancellables)
        $savedDistrictID.dropFirst().sink { [weak self] in self?.preferences.savedDistrictID = $0 }.store(in: &cancellables)
        $savedLocationName.dropFirst().sink { [weak self] in self?.preferences.savedLocationName = $0 }.store(in: &cancellables)
    }
    
    func loadAuthors() {
        Task {
            self.availableAuthors = await database.fetchAuthors()
        }
    }
    
    func submitContactForm() {
        isShowingAlert = true
    }
    
    func resetAllData() {
        Task {
            await AppDatabaseManager.shared.reset()
            PreferenceManager.shared.resetAll()
            
            // After reset, we might want to refresh current state if needed
            // For now, most features will reload on next view appear
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }
    }
}
