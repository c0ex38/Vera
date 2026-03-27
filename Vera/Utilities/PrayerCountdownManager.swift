import Foundation
import Combine
import SwiftUI

@MainActor
class PrayerCountdownManager: ObservableObject {
    @Published var nextPrayerName: String = "Hesaplanıyor..."
    @Published var timeRemainingString: String = "00:00:00"
    @Published var currentPrayerName: String = "Hesaplanıyor..."
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
        let prayers = [
            ("İmsak", times.imsakTime),
            ("Güneş", times.sunrise),
            ("Öğle", times.dhuhr),
            ("İkindi", times.asr),
            ("Akşam", times.maghrib),
            ("Yatsı", times.isha)
        ]
        
        var nextPrayer: (name: String, date: Date)? = nil
        
        // İlgili saatleri bugünün tarihine Date olarak ekleyip kıyaslıyoruz.
        for prayer in prayers {
            if let parsedTime = formatter.date(from: prayer.1) {
                var components = calendar.dateComponents([.year, .month, .day], from: now)
                let timeComponents = calendar.dateComponents([.hour, .minute], from: parsedTime)
                components.hour = timeComponents.hour
                components.minute = timeComponents.minute
                components.second = 0
                
                if let prayerDate = calendar.date(from: components), prayerDate > now {
                    nextPrayer = (prayer.0, prayerDate)
                    break
                }
            }
        }
        
        // Bütün vakitler geçildiyse, yarına (İmsak) kaldık.
        if nextPrayer == nil, let imsakTime = formatter.date(from: times.imsakTime) {
            var components = calendar.dateComponents([.year, .month, .day], from: now)
            let timeComponents = calendar.dateComponents([.hour, .minute], from: imsakTime)
            components.hour = timeComponents.hour
            components.minute = timeComponents.minute
            components.second = 0
            if let day = components.day {
                components.day = day + 1 // Yara geçiş
            }
            if let tomorrowImsak = calendar.date(from: components) {
                nextPrayer = ("İmsak", tomorrowImsak)
            }
        }
        
        if let next = nextPrayer {
            self.nextPrayerName = next.name
            
            // Mevcut (İçinde Bulunulan) Vakti Hesaplama
            let prayerNames = ["İmsak", "Güneş", "Öğle", "İkindi", "Akşam", "Yatsı"]
            if let nextIndex = prayerNames.firstIndex(of: next.name) {
                let currentIndex = (nextIndex - 1 + prayerNames.count) % prayerNames.count
                self.currentPrayerName = prayerNames[currentIndex]
            }
            
            let diff = next.date.timeIntervalSince(now)
            self.isPrayerTime = diff <= 0
            
            let totalSeconds = max(0, Int(diff))
            let hours = totalSeconds / 3600
            let minutes = (totalSeconds % 3600) / 60
            let seconds = totalSeconds % 60
            
            self.timeRemainingString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            self.nextPrayerName = "Bilinmiyor"
            self.timeRemainingString = "00:00:00"
            self.isPrayerTime = false
        }
    }
}
