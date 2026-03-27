import Foundation

/// Ezan vakti API'si ile haberleşen ve verileri yerel JSON dosyalarında önbellekleyen (cache) servis.
final class PrayerTimeService: PrayerTimeServiceProvider, @unchecked Sendable {
    nonisolated static let shared = PrayerTimeService()
    
    private let baseURL = AppEnvironment.shared.apiBaseURL
    
    private init() {} // Sadece tek bir instance (singleton) olmalı

    
    // MARK: - Ülkeler, Şehirler, İlçeler (Constant Data)
    /// Ülkeleri getirir. Varsa yerel JSON dosyasından okur, yoksa API'den çekip JSON'a kaydeder.
    func getCountries() async throws -> [Country] {
        let allCountries: [Country] = try await fetchOrLoadJSON(endpoint: "/ulkeler", filename: "ulkeler.json")
        // Yalnızca Türkiye'yi (ID: 2) döndür (API sorunları nedeniyle şimdilik kısıtlandı)
        return allCountries.filter { $0.countryId == "2" }
    }
    
    /// Belirtilen ülkenin şehirlerini getirir. (Yerel JSON önbellekli)
    func getCities(countryID: String) async throws -> [City] {
        return try await fetchOrLoadJSON(endpoint: "/sehirler/\(countryID)", filename: "sehirler_\(countryID).json")
    }
    
    /// Belirtilen şehrin ilçelerini getirir. (Yerel JSON önbellekli)
    func getDistricts(cityID: String) async throws -> [District] {
        return try await fetchOrLoadJSON(endpoint: "/ilceler/\(cityID)", filename: "ilceler_\(cityID).json")
    }
    
    // MARK: - Namaz Vakitleri (Dynamic Data)
    /// Seçilen ilçe ID'sine göre 30 günlük namaz vakitlerini getirir.
    func getPrayerTimes(districtID: String) async throws -> [PrayerTime] {
        let filename = "vakitler_\(districtID).json"
        var times: [PrayerTime] = try await fetchOrLoadJSON(endpoint: "/vakitler/\(districtID)", filename: filename)
        
        // Önbellekteki verinin süresi geçmiş mi kontrol et (Bugünün tarihi listede yoksa eskimiştir)
        let date = Date()
        let isoFormatter = DateFormatter()
        isoFormatter.dateFormat = "yyyy-MM-dd"
        let todayIso = isoFormatter.string(from: date)
        
        let trFormatter = DateFormatter()
        trFormatter.dateFormat = "dd.MM.yyyy"
        let todayTr = trFormatter.string(from: date)
        
        let hasToday = times.contains(where: {
            $0.gregorianDateShortIso8601.starts(with: todayIso) ||
            ($0.gregorianDateShort ?? "").starts(with: todayTr)
        })
        
        if !hasToday {
            // Önbelleği temizle ve tekrar API'den çek
            print("[\(filename)] süresi dolmuş veya bugünü içermiyor. Silinip yenisi indiriliyor...")
            let fileURL = getDocumentsDirectory().appendingPathComponent(filename)
            try? FileManager.default.removeItem(at: fileURL)
            
            times = try await fetchOrLoadJSON(endpoint: "/vakitler/\(districtID)", filename: filename)
        }
        
        return times
    }
    
    // MARK: - Generic Dışa Aktar/Çek (Cache Mechanism)
    /// Verilen URL'e gider. Eğer cihazda `filename` ile dosya varsa, internete çıkmadan direkt onu okur. (JSON Caching)
    private func fetchOrLoadJSON<T: Codable>(endpoint: String, filename: String) async throws -> T {
        let fileURL = getDocumentsDirectory().appendingPathComponent(filename)
        
        // 1. Adım: Yerel dosyayı kontrol et, varsa onu oku (1 Kere Çekme Mantığı)
        if FileManager.default.fileExists(atPath: fileURL.path),
           let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode(T.self, from: data) {
            
            // Successfully loaded from cache
            return decoded
        }
        
        // 2. Adım: Cihazda yoksa (ilk açılış), internetten çek
        guard let url = URL(string: baseURL + endpoint) else {
            throw VeraError.networkError("Bağlantı adresi hatalı (\(endpoint))")
        }
        
        // Cihazda yoksa (ilk açılış), internetten çek
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15
        let session = URLSession(configuration: configuration)
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw VeraError.networkError("Sunucu yanıt vermiyor (HTTP \( (response as? HTTPURLResponse)?.statusCode ?? 0 ))")
            }
            
            // Sonraki kullanımlar için cihaza JSON olarak kaydet
            try? data.write(to: fileURL)
            
            // 4. Adım: Datayı parse et ve döndür
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                return decoded
            } catch {
                throw VeraError.networkError("Veri formatı uyumsuz: \(error.localizedDescription)")
            }
        } catch let error as VeraError {
            throw error
        } catch {
            if (error as NSError).code == NSURLErrorTimedOut {
                throw VeraError.timeoutError
            }
            throw VeraError.networkError(error.localizedDescription)
        }
    }

    
    // MARK: - Helper Cihaz Dosya Yolu
    private func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
