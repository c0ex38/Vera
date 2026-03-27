import Foundation
import UserNotifications
import SwiftUI
import Combine

@MainActor
final class NotificationManager: ObservableObject, @unchecked Sendable, NotificationProvider {
    nonisolated static let shared = NotificationManager()
    
    @Published var isAuthorized: Bool = false
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true
    
    // Granular Preferences
    @AppStorage("notifyFajr") private var notifyFajr: Bool = true
    @AppStorage("notifyDhuhr") private var notifyDhuhr: Bool = true
    @AppStorage("notifyAsr") private var notifyAsr: Bool = true
    @AppStorage("notifyMaghrib") private var notifyMaghrib: Bool = true
    @AppStorage("notifyIsha") private var notifyIsha: Bool = true
    
    @AppStorage("reminderEnabled") private var reminderEnabled: Bool = false
    @AppStorage("reminderOffset") private var reminderOffset: Int = 15
    @AppStorage("adhanSoundEnabled") private var adhanSoundEnabled: Bool = true
    
    nonisolated private init() {
        Task { @MainActor in
            await NotificationManager.shared.updateAuthorizationStatus()
        }
    }
    
    func requestAuthorization() async -> Bool {
        do {
            let options: UNAuthorizationOptions = [.alert, .sound, .badge]
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: options)
            self.isAuthorized = granted
            print("Bildirim İzni: \(granted ? "Verildi" : "Reddedildi")")
            return granted
        } catch {
            print("Bildirim İzni Hatası: \(error.localizedDescription)")
            self.isAuthorized = false
            return false
        }
    }
    
    func updateAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        self.isAuthorized = (settings.authorizationStatus == .authorized)
    }
    
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    func schedulePrayerNotification(for prayerName: String, at date: Date, useAdhanSound: Bool = true) {
        guard notificationsEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "\(prayerName) Vakti"
        content.body = "\(prayerName) vakti girdi. Haydi namaza!"
        
        if useAdhanSound {
            content.sound = UNNotificationSound(named: UNNotificationSoundName("ezan.wav"))
        } else {
            content.sound = .default
        }
        
        addBrandingAttachment(to: content)
        
        guard date > Date() else { return }
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: "prayer_\(prayerName)_\(date.timeIntervalSince1970)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Ezan Bildirim zamanlama hatası: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleReminderNotification(for prayerName: String, at prayerDate: Date, offsetMinutes: Int) {
        guard notificationsEnabled else { return }
        
        guard let reminderDate = Calendar.current.date(byAdding: .minute, value: -offsetMinutes, to: prayerDate) else { return }
        guard reminderDate > Date() else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "\(prayerName) Vaktine Yaklaşıyor"
        content.body = "\(prayerName) vaktine \(offsetMinutes) dakika kaldı. Abdestinizi alıp hazırlanabilirsiniz."
        
        content.sound = .default
        
        addBrandingAttachment(to: content)
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: "reminder_\(prayerName)_\(prayerDate.timeIntervalSince1970)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        print("Tüm bildirimler silindi.")
    }
    
    func scheduleWeekly(times: [PrayerTime]) {
        guard notificationsEnabled else {
            cancelAllNotifications()
            return
        }
        
        cancelAllNotifications()
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Sadece bugünden itibaren olan verileri al (iOS 64 limitine takılmamak için)
        // Bir gün öncesini de dahil ederek zaman dilimi kaymalarını tolere edelim
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today) ?? today
        
        let futureTimes = times.filter { time in
            guard let date = time.dateObj else { return false }
            return calendar.startOfDay(for: date) >= yesterday
        }.prefix(7)
        
        for time in futureTimes {
            guard let date = time.dateObj else { continue }
            
            scheduleIfEnabled(name: "İmsak", timeStr: time.imsakTime, baseDate: date, enabled: notifyFajr)
            scheduleIfEnabled(name: "Öğle", timeStr: time.dhuhr, baseDate: date, enabled: notifyDhuhr)
            scheduleIfEnabled(name: "İkindi", timeStr: time.asr, baseDate: date, enabled: notifyAsr)
            scheduleIfEnabled(name: "Akşam", timeStr: time.maghrib, baseDate: date, enabled: notifyMaghrib)
            scheduleIfEnabled(name: "Yatsı", timeStr: time.isha, baseDate: date, enabled: notifyIsha)
        }
        
        print("\(futureTimes.count) günlük bildirimler başarıyla planlandı.")
    }
    
    func refreshCurrentSchedule() {
        let savedDistrictID = UserDefaults.standard.string(forKey: "savedDistrictID") ?? ""
        guard !savedDistrictID.isEmpty else { return }
        
        Task {
            do {
                let times = try await PrayerTimeService.shared.getPrayerTimes(districtID: savedDistrictID)
                self.scheduleWeekly(times: times)
            } catch {
                print("Bildirim tazeleme hatası: \(error.localizedDescription)")
            }
        }
    }
    
    private func scheduleIfEnabled(name: String, timeStr: String, baseDate: Date, enabled: Bool) {
        guard enabled else { return }
        
        let components = timeStr.split(separator: ":")
        guard components.count == 2,
              let hour = Int(components[0]),
              let minute = Int(components[1]) else { return }
        
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: baseDate)
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        guard let finalDate = Calendar.current.date(from: dateComponents) else { return }
        
        schedulePrayerNotification(for: name, at: finalDate, useAdhanSound: adhanSoundEnabled)
        
        if reminderEnabled {
            scheduleReminderNotification(for: name, at: finalDate, offsetMinutes: reminderOffset)
        }
    }
    
    private func addBrandingAttachment(to content: UNMutableNotificationContent) {
        if let logoURL = Bundle.main.url(forResource: "NotificationLogo", withExtension: "png") {
            if let attachment = try? UNNotificationAttachment(identifier: "logo", url: logoURL, options: nil) {
                content.attachments = [attachment]
            }
        }
    }
}
