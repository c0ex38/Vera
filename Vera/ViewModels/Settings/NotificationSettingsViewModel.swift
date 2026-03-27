import SwiftUI
import Combine

class NotificationSettingsViewModel: ObservableObject {
    @AppStorage("notifyFajr") var notifyFajr: Bool = true { didSet { refresh() } }
    @AppStorage("notifyDhuhr") var notifyDhuhr: Bool = true { didSet { refresh() } }
    @AppStorage("notifyAsr") var notifyAsr: Bool = true { didSet { refresh() } }
    @AppStorage("notifyMaghrib") var notifyMaghrib: Bool = true { didSet { refresh() } }
    @AppStorage("notifyIsha") var notifyIsha: Bool = true { didSet { refresh() } }
    
    @AppStorage("reminderEnabled") var reminderEnabled: Bool = false { didSet { refresh() } }
    @AppStorage("reminderOffset") var reminderOffset: Int = 15 { didSet { refresh() } }
    
    @AppStorage("adhanSoundEnabled") var adhanSoundEnabled: Bool = true { didSet { refresh() } }
    @AppStorage("notificationsEnabled") var notificationsEnabled: Bool = true
    
    let reminderOptions = [5, 10, 15, 30, 45, 60]
    
    private func refresh() {
        NotificationManager.shared.refreshCurrentSchedule()
    }
    
    func toggleAll(isOn: Bool) {
        notifyFajr = isOn
        notifyDhuhr = isOn
        notifyAsr = isOn
        notifyMaghrib = isOn
        notifyIsha = isOn
    }
    
    func scheduleTestNotification() {
        NotificationManager.shared.scheduleTestNotification()
    }
    
    @Published var isSyncing = false
    
    func syncWithAPI() {
        let savedDistrictID = UserDefaults.standard.string(forKey: "savedDistrictID") ?? ""
        guard !savedDistrictID.isEmpty else { return }
        
        isSyncing = true
        Task {
            do {
                let times = try await PrayerTimeService.shared.getPrayerTimes(districtID: savedDistrictID)
                NotificationManager.shared.scheduleWeekly(times: times)
                try? await Task.sleep(nanoseconds: 1_000_000_000) // Hafif gecikme (UI hissi için)
                await MainActor.run { isSyncing = false }
            } catch {
                await MainActor.run { isSyncing = false }
            }
        }
    }
}
