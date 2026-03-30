import SwiftUI
import Combine

class NotificationSettingsViewModel: ObservableObject {
    
    private let preferences = PreferenceManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    @Published var notifyFajr: Bool = true
    @Published var notifyDhuhr: Bool = true
    @Published var notifyAsr: Bool = true
    @Published var notifyMaghrib: Bool = true
    @Published var notifyIsha: Bool = true
    
    @Published var reminderEnabled: Bool = false
    @Published var reminderOffset: Int = 15
    
    @Published var adhanSoundEnabled: Bool = true
    @Published var notificationsEnabled: Bool = true
    
    @Published var isSyncing = false
    
    let reminderOptions = [5, 10, 15, 30, 45, 60]
    
    init() {
        // Initialize from preferences
        self.notifyFajr = preferences.notifyFajr
        self.notifyDhuhr = preferences.notifyDhuhr
        self.notifyAsr = preferences.notifyAsr
        self.notifyMaghrib = preferences.notifyMaghrib
        self.notifyIsha = preferences.notifyIsha
        self.reminderEnabled = preferences.reminderEnabled
        self.reminderOffset = preferences.reminderOffset
        self.adhanSoundEnabled = preferences.adhanSoundEnabled
        self.notificationsEnabled = preferences.notificationsEnabled
        
        // Bind changes back to preferences and refresh schedule
        setupBindings()
    }
    
    private func setupBindings() {
        $notifyFajr.sink { [weak self] in self?.preferences.notifyFajr = $0; self?.refresh() }.store(in: &cancellables)
        $notifyDhuhr.sink { [weak self] in self?.preferences.notifyDhuhr = $0; self?.refresh() }.store(in: &cancellables)
        $notifyAsr.sink { [weak self] in self?.preferences.notifyAsr = $0; self?.refresh() }.store(in: &cancellables)
        $notifyMaghrib.sink { [weak self] in self?.preferences.notifyMaghrib = $0; self?.refresh() }.store(in: &cancellables)
        $notifyIsha.sink { [weak self] in self?.preferences.notifyIsha = $0; self?.refresh() }.store(in: &cancellables)
        
        $reminderEnabled.sink { [weak self] in self?.preferences.reminderEnabled = $0; self?.refresh() }.store(in: &cancellables)
        $reminderOffset.sink { [weak self] in self?.preferences.reminderOffset = $0; self?.refresh() }.store(in: &cancellables)
        $adhanSoundEnabled.sink { [weak self] in self?.preferences.adhanSoundEnabled = $0; self?.refresh() }.store(in: &cancellables)
        $notificationsEnabled.sink { [weak self] in self?.preferences.notificationsEnabled = $0 }.store(in: &cancellables)
    }
    
    private func refresh() {
        NotificationManager.shared.refreshCurrentSchedule(using: nil)
    }
    
    func toggleAll(isOn: Bool) {
        notifyFajr = isOn
        notifyDhuhr = isOn
        notifyAsr = isOn
        notifyMaghrib = isOn
        notifyIsha = isOn
    }
    
    func syncWithAPI() {
        let savedDistrictID = preferences.savedDistrictID
        guard !savedDistrictID.isEmpty else { return }
        
        isSyncing = true
        Task {
            do {
                let times = try await PrayerTimeService.shared.getPrayerTimes(districtID: savedDistrictID)
                NotificationManager.shared.scheduleWeekly(times: times)
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                await MainActor.run { isSyncing = false }
            } catch {
                await MainActor.run { isSyncing = false }
            }
        }
    }
}
