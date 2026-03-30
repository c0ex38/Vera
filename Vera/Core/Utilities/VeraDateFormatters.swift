import Foundation

/// Uygulama genelinde tekrar tekrar oluşturulmak yerine tek bir yerde tanımlanan DateFormatter'lar.
/// DateFormatter oluşturmak maliyetli bir işlemdir; bu yapı performansı artırır ve kod tekrarını önler.
enum VeraDateFormatters {
    
    // MARK: - Formatters (Computed for safety in actors)
    
    /// ISO 8601 tarih formatı (yyyy-MM-dd). API ve veritabanı karşılaştırmaları için.
    nonisolated static var iso: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }
    
    /// Türkçe tarih formatı (dd.MM.yyyy). Diyanet API'sinin alternatif tarih formatı.
    nonisolated static var tr: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "dd.MM.yyyy"
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "tr_TR")
        return f
    }
    
    /// Saat formatı (HH:mm). Namaz vakitlerini parse etmek için.
    nonisolated static var time: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }
    
    // MARK: - Helpers (Thread-safe)
    
    /// Bugünün tarih string'lerini döndürür (ISO ve TR formatları).
    nonisolated static func todayStrings() -> (iso: String, tr: String) {
        let now = Date()
        return (iso.string(from: now), tr.string(from: now))
    }
    
    /// Verilen PrayerTime'ın bugünün tarihine ait olup olmadığını kontrol eder.
    /// API'nin tutarsız tarih formatları nedeniyle hem ISO hem TR formatını dener.
    nonisolated static func isToday(isoDate: String, trDate: String?) -> Bool {
        let today = todayStrings()
        return isoDate.starts(with: today.iso) || (trDate ?? "").starts(with: today.tr)
    }
}
