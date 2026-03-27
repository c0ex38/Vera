import Foundation
import SwiftUI
import Combine

@MainActor
class OnboardingViewModel: ObservableObject {
    // MARK: - AppStorage Persistence For Alarms
    @AppStorage("alarmFajr") var alarmFajr: Bool = true
    @AppStorage("alarmSunrise") var alarmSunrise: Bool = false
    @AppStorage("alarmDhuhr") var alarmDhuhr: Bool = true
    @AppStorage("alarmAsr") var alarmAsr: Bool = true
    @AppStorage("alarmMaghrib") var alarmMaghrib: Bool = true
    @AppStorage("alarmIsha") var alarmIsha: Bool = true
    
    // MARK: - AppStorage Persistence For Reminders
    @AppStorage("reminderMinutes") var reminderMinutes: Int = 15
    @AppStorage("enableReminders") var enableReminders: Bool = true
    
    @Published var permissionGranted: Bool = false
    
    @Published var countdownManager = PrayerCountdownManager()
    @Published var isFetchingPreview = false
    
    private let prayerService: PrayerTimeServiceProvider
    
    init(prayerService: PrayerTimeServiceProvider? = nil) {
        self.prayerService = prayerService ?? PrayerTimeService.shared
    }

    
    func fetchPreviewPrayerTimes(districtID: String) {
        if countdownManager.nextPrayerName != "Hesaplanıyor..." { return }
        isFetchingPreview = true
        Task {
            do {
                let timesArray = try await prayerService.getPrayerTimes(districtID: districtID)

                // API geçmiş günleri dönmeyeceği için veya Cache sebebiyle 1. eleman her zaman bugün olmayabilir.
                // Bu yüzden "yyyy-MM-dd" formatıyla bugünü listede bulmalıyız.
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
                print("Önizleme vakitleri çekilemedi: \(error)")
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
