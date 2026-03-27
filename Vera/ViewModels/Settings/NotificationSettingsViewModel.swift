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
}
