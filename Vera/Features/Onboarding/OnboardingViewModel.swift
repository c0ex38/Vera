import Foundation
import SwiftUI
import Combine

@MainActor
class OnboardingViewModel: ObservableObject {
    
    // Centralized preferences
    private let preferences = PreferenceManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    @Published var alarmFajr: Bool
    @Published var alarmSunrise: Bool
    @Published var alarmDhuhr: Bool
    @Published var alarmAsr: Bool
    @Published var alarmMaghrib: Bool
    @Published var alarmIsha: Bool
    
    @Published var reminderMinutes: Int
    @Published var enableReminders: Bool
    
    @Published var permissionGranted: Bool = false
    @Published var countdownManager = PrayerCountdownManager()
    @Published var isFetchingPreview = false
    
    private let prayerService: PrayerTimeServiceProvider
    
    init(prayerService: PrayerTimeServiceProvider? = nil) {
        self.prayerService = prayerService ?? PrayerTimeService.shared
        
        // Initialize from preferences
        self.alarmFajr = preferences.alarmFajr
        self.alarmSunrise = preferences.alarmSunrise
        self.alarmDhuhr = preferences.alarmDhuhr
        self.alarmAsr = preferences.alarmAsr
        self.alarmMaghrib = preferences.alarmMaghrib
        self.alarmIsha = preferences.alarmIsha
        self.reminderMinutes = preferences.reminderOffset
        self.enableReminders = preferences.reminderEnabled
        
        setupBindings()
    }
    
    private func setupBindings() {
        $alarmFajr.receive(on: DispatchQueue.main).sink { [weak self] in self?.preferences.alarmFajr = $0 }.store(in: &cancellables)
        $alarmSunrise.receive(on: DispatchQueue.main).sink { [weak self] in self?.preferences.alarmSunrise = $0 }.store(in: &cancellables)
        $alarmDhuhr.receive(on: DispatchQueue.main).sink { [weak self] in self?.preferences.alarmDhuhr = $0 }.store(in: &cancellables)
        $alarmAsr.receive(on: DispatchQueue.main).sink { [weak self] in self?.preferences.alarmAsr = $0 }.store(in: &cancellables)
        $alarmMaghrib.receive(on: DispatchQueue.main).sink { [weak self] in self?.preferences.alarmMaghrib = $0 }.store(in: &cancellables)
        $alarmIsha.receive(on: DispatchQueue.main).sink { [weak self] in self?.preferences.alarmIsha = $0 }.store(in: &cancellables)
        $reminderMinutes.receive(on: DispatchQueue.main).sink { [weak self] in self?.preferences.reminderOffset = $0 }.store(in: &cancellables)
        $enableReminders.receive(on: DispatchQueue.main).sink { [weak self] in self?.preferences.reminderEnabled = $0 }.store(in: &cancellables)
    }

    func fetchPreviewPrayerTimes(districtID: String) {
        if isFetchingPreview { return }
        isFetchingPreview = true
        Task {
            do {
                let timesArray = try await prayerService.getPrayerTimes(districtID: districtID)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let todayString = dateFormatter.string(from: Date())
                
                let todayPrayer = timesArray.first(where: {
                    return $0.gregorianDateShortIso8601.starts(with: todayString)
                }) ?? timesArray.first
                
                if let today = todayPrayer {
                    self.countdownManager.startCountdown(with: today)
                }
                self.isFetchingPreview = false
            } catch {
                DebugLog.error("Önizleme vakitleri çekilemedi: \(error)")
                self.isFetchingPreview = false
            }
        }
    }
    
    func requestPermissions() {
        Task {
            let granted = await NotificationManager.shared.requestAuthorization()
            self.permissionGranted = granted
        }
    }
    
    func disableAllNotifications() {
        alarmFajr = false
        alarmSunrise = false
        alarmDhuhr = false
        alarmAsr = false
        alarmMaghrib = false
        alarmIsha = false
        enableReminders = false
    }
}
