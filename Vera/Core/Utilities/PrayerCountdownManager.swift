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
    @Published var progress: Double = 0.0
    
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
            if let parsedTime = VeraDateFormatters.time.date(from: prayer.1) {
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
        if next == nil, let imsakTime = VeraDateFormatters.time.date(from: times.imsakTime) {
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
            
            // Mevcut (İçinde Bulunulan) Vakti ve Önceki Zamanı Bulma
            let prayerTypes = PrayerType.allCases
            var prevDate: Date? = nil
            
            if let nextIndex = prayerTypes.firstIndex(of: next.type) {
                let currentIndex = (nextIndex - 1 + prayerTypes.count) % prayerTypes.count
                let currentType = prayerTypes[currentIndex]
                self.currentPrayer = currentType
                self.currentPrayerName = currentType.localizedName
                
                // Önceki vaktin tarihini hesaplayalım (Toplam süre için)
                let prevTimeStr = prayers.first(where: { $0.type == currentType })?.time ?? times.imsakTime
                if let parsedPrev = VeraDateFormatters.time.date(from: prevTimeStr) {
                    var comps = calendar.dateComponents([.year, .month, .day], from: now)
                    let tComps = calendar.dateComponents([.hour, .minute], from: parsedPrev)
                    comps.hour = tComps.hour
                    comps.minute = tComps.minute
                    comps.second = 0
                    
                    // Eğer şu anki vaki İmsak ise ama "next" de İmsak ise (gece yarısından sonra), prev dün akşamki Yatsı olmalı.
                    // Ya da basitleştirelim:
                    if let d = calendar.date(from: comps) {
                        prevDate = d > next.date ? calendar.date(byAdding: .day, value: -1, to: d) : d
                    }
                }
            }
            
            let diff = next.date.timeIntervalSince(now)
            self.isPrayerTime = diff <= 0
            
            // Progress Hesaplama
            if let start = prevDate {
                let totalDuration = next.date.timeIntervalSince(start)
                let elapsed = now.timeIntervalSince(start)
                self.progress = max(0, min(1.0, elapsed / totalDuration))
            } else {
                self.progress = 0
            }
            
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
            self.progress = 0
        }
    }
}
