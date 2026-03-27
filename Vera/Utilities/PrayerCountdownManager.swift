import Foundation
import Combine
import SwiftUI

@MainActor
class PrayerCountdownManager: ObservableObject {
    @Published var nextPrayer: PrayerType? = nil
    @Published var nextPrayerName: String = L10n.Home.loading
    @Published var timeRemainingString: String = "00:00:00"
    @Published var currentPrayer: PrayerType? = nil
    @Published var currentPrayerName: String = L10n.Home.loading
    @Published var isPrayerTime: Bool = false
    
    private var timer: AnyCancellable?
    private var prayerTimes: PrayerTime?
    
    func startCountdown(with times: PrayerTime) {
        self.prayerTimes = times
        updateCountdown() // İlk değeri atayalım gecikme olmadan
        
        timer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.updateCountdown()
                }
            }
    }
    
    func stopCountdown() {
        timer?.cancel()
        timer = nil
    }
    
    private func updateCountdown() {
        guard let times = prayerTimes else { return }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        let calendar = Calendar.current
        let now = Date()
        
        // Cihazın kendi zaman dilimine göre işlem yapacağız. 
        // Namaz vakitleri sadece düz metin (15:23 vb.) olduğu için Timezone farkını bu noktada çözüyoruz.
        let prayers: [(type: PrayerType, time: String)] = [
            (.imsak, times.imsakTime),
            (.sunrise, times.sunrise),
            (.dhuhr, times.dhuhr),
            (.asr, times.asr),
            (.maghrib, times.maghrib),
            (.isha, times.isha)
        ]
        
        var next: (type: PrayerType, date: Date)? = nil
        
        // İlgili saatleri bugünün tarihine Date olarak ekleyip kıyaslıyoruz.
        for prayer in prayers {
            if let parsedTime = formatter.date(from: prayer.1) {
                var components = calendar.dateComponents([.year, .month, .day], from: now)
                let timeComponents = calendar.dateComponents([.hour, .minute], from: parsedTime)
                components.hour = timeComponents.hour
                components.minute = timeComponents.minute
                components.second = 0
                
                if let prayerDate = calendar.date(from: components), prayerDate > now {
                    next = (prayer.type, prayerDate)
                    break
                }
            }
        }
        
        // Bütün vakitler geçildiyse, yarına (İmsak) kaldık.
        if next == nil, let imsakTime = formatter.date(from: times.imsakTime) {
            var components = calendar.dateComponents([.year, .month, .day], from: now)
            let timeComponents = calendar.dateComponents([.hour, .minute], from: imsakTime)
            components.hour = timeComponents.hour
            components.minute = timeComponents.minute
            components.second = 0
            if let day = components.day {
                components.day = day + 1 // Yara geçiş
            }
            if let tomorrowImsak = calendar.date(from: components) {
                next = (.imsak, tomorrowImsak)
            }
        }
        
        if let next = next {
            self.nextPrayer = next.type
            self.nextPrayerName = next.type.localizedName
            
            // Mevcut (İçinde Bulunulan) Vakti Hesaplama
            let prayerTypes = PrayerType.allCases
            if let nextIndex = prayerTypes.firstIndex(of: next.type) {
                let currentIndex = (nextIndex - 1 + prayerTypes.count) % prayerTypes.count
                let currentType = prayerTypes[currentIndex]
                self.currentPrayer = currentType
                self.currentPrayerName = currentType.localizedName
            }
            
            let diff = next.date.timeIntervalSince(now)
            self.isPrayerTime = diff <= 0
            
            let totalSeconds = max(0, Int(diff))
            let hours = totalSeconds / 3600
            let minutes = (totalSeconds % 3600) / 60
            let seconds = totalSeconds % 60
            
            self.timeRemainingString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            self.nextPrayer = nil
            self.nextPrayerName = L10n.Home.loading
            self.timeRemainingString = "00:00:00"
            self.isPrayerTime = false
        }
    }
}
