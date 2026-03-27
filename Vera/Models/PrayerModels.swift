import Foundation

// MARK: - Country Model
struct Country: Codable, Identifiable, Sendable {
    var id: String { countryId }
    let countryName: String
    let countryNameEn: String
    let countryId: String
    
    enum CodingKeys: String, CodingKey {
        case countryName = "UlkeAdi"
        case countryNameEn = "UlkeAdiEn"
        case countryId = "UlkeID"
    }
}

// MARK: - City Model
struct City: Codable, Identifiable, Sendable {
    var id: String { cityId }
    let cityName: String
    let cityNameEn: String
    let cityId: String
    
    enum CodingKeys: String, CodingKey {
        case cityName = "SehirAdi"
        case cityNameEn = "SehirAdiEn"
        case cityId = "SehirID"
    }
}

// MARK: - District Model
struct District: Codable, Identifiable, Sendable {
    var id: String { districtId }
    let districtName: String
    let districtNameEn: String
    let districtId: String
    
    enum CodingKeys: String, CodingKey {
        case districtName = "IlceAdi"
        case districtNameEn = "IlceAdiEn"
        case districtId = "IlceID"
    }
}

// MARK: - Prayer Time Model
struct PrayerTime: Codable, Identifiable, Equatable, Sendable {

    var id: String { gregorianDateShortIso8601 }
    
    let hijriDateShort: String?
    let hijriDateShortIso8601: String?
    let hijriDateLong: String?
    let hijriDateLongIso8601: String?
    let moonPhaseUrl: String?
    let gregorianDateShort: String?
    let gregorianDateShortIso8601: String
    let gregorianDateLong: String?
    let gregorianDateLongIso8601: String?
    let greenwichMeanTime: Double?
    
    // Core Prayers
    let imsakTime: String
    let sunrise: String
    let sunRiseTime: String?
    let sunSetTime: String?
    let dhuhr: String
    let asr: String
    let maghrib: String
    let isha: String
    let qiblaTime: String?
    
    // Helper to get Date object from various formats (API inconsistent)
    var dateObj: Date? {
        // 1. Try ISO8601 (yyyy-MM-dd)
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withFullDate]
        if let date = isoFormatter.date(from: gregorianDateShortIso8601) {
            return date
        }
        
        // 2. Fallback: Try DD.MM.YYYY (Current API Bug)
        let fallbackFormatter = DateFormatter()
        fallbackFormatter.dateFormat = "dd.MM.yyyy"
        return fallbackFormatter.date(from: gregorianDateShortIso8601)
    }
    
    enum CodingKeys: String, CodingKey {
        case hijriDateShort = "HicriTarihKisa"
        case hijriDateShortIso8601 = "HicriTarihKisaIso8601"
        case hijriDateLong = "HicriTarihUzun"
        case hijriDateLongIso8601 = "HicriTarihUzunIso8601"
        case moonPhaseUrl = "AyinSekliURL"
        case gregorianDateShort = "MiladiTarihKisa"
        case gregorianDateShortIso8601 = "MiladiTarihKisaIso8601"
        case gregorianDateLong = "MiladiTarihUzun"
        case gregorianDateLongIso8601 = "MiladiTarihUzunIso8601"
        case greenwichMeanTime = "GreenwichOrtalamaZamani"
        
        case imsakTime = "Imsak"
        case sunrise = "Gunes"
        case sunRiseTime = "GunesDogus"
        case sunSetTime = "GunesBatis"
        case dhuhr = "Ogle"
        case asr = "Ikindi"
        case maghrib = "Aksam"
        case isha = "Yatsi"
        case qiblaTime = "KibleSaati"
    }
}
