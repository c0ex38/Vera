import Foundation
import CoreLocation
import Combine
import SwiftUI
import MapKit

@MainActor
class HomeViewModel: ObservableObject {
    @Published var state: ViewState = .idle
    @Published var prayerTimes: [PrayerTime] = []
    @Published var resolvedLocationName: String = ""
    @Published var hadithOfTheDay: Hadith? = nil
    
    // Uygulama genelinde sadece bugünü bulabilmek için yardımcı hesaplanmış değişken
    var todayPrayerTime: PrayerTime? {
        let date = Date()
        
        let isoFormatter = DateFormatter()
        isoFormatter.dateFormat = "yyyy-MM-dd"
        let todayIso = isoFormatter.string(from: date)
        
        let trFormatter = DateFormatter()
        trFormatter.dateFormat = "dd.MM.yyyy"
        let todayTr = trFormatter.string(from: date)
        
        return prayerTimes.first(where: {
            $0.gregorianDateShortIso8601.starts(with: todayIso) ||
            ($0.gregorianDateShort ?? "").starts(with: todayTr)
        }) ?? prayerTimes.first
    }
    
    private let prayerService: PrayerTimeServiceProvider
    private let locationMatcher: LocationMatching
    private let locationManager: LocationProvider
    private let notificationManager: NotificationProvider
    private var cancellables = Set<AnyCancellable>()
    
    enum ViewState: Equatable {
        case idle
        case requestingLocation
        case matchingAPI
        case success
        case error(String)
    }
    
    @AppStorage("autoLocationEnabled") private var autoLocationEnabled: Bool = true
    @AppStorage("savedDistrictID") private var savedDistrictID: String = ""
    @AppStorage("savedLocationName") private var savedLocationName: String = ""
    @AppStorage("savedLatitude") private var savedLatitude: Double = 0.0
    @AppStorage("savedLongitude") private var savedLongitude: Double = 0.0
    
    init(
        prayerService: PrayerTimeServiceProvider? = nil,
        locationMatcher: LocationMatching? = nil,
        locationManager: LocationProvider? = nil,
        notificationManager: NotificationProvider? = nil
    ) {
        self.prayerService = prayerService ?? PrayerTimeService.shared
        self.locationMatcher = locationMatcher ?? LocationMatcher()
        self.locationManager = locationManager ?? LocationManager.shared
        self.notificationManager = notificationManager ?? NotificationManager.shared
        
        setupBindings()
    }

    func start() {
        // Günün hadisini yükle
        Task {
            let manager = AppDatabaseManager.shared
            self.hadithOfTheDay = await manager.fetchHadithOfTheDay()
        }
        
        if autoLocationEnabled {
            state = .requestingLocation
            locationManager.requestLocation()
        } else {
            // Konum kapalıysa sadece offline kaydedilen bölgeyi yüklemeye çalışır
            if !savedDistrictID.isEmpty {
                fetchSavedLocationTimes(districtID: savedDistrictID, locationName: savedLocationName)
            } else {
                state = .error("Otomatik konum kapalı. Lütfen manuel konum seçin veya Ayarlar sekmesinden konumu aktif edin.")
            }
        }
    }

    func fetchSavedLocationTimes(districtID: String, locationName: String) {
        state = .requestingLocation
        self.resolvedLocationName = locationName
        
        // Manuel seçim yapıldığında koordinatları da bulmaya çalışalım (Global Sync için)
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(locationName) { [weak self] placemarks, _ in
            if let coordinate = placemarks?.first?.location?.coordinate {
                Task { @MainActor in
                    self?.savedLatitude = coordinate.latitude
                    self?.savedLongitude = coordinate.longitude
                }
            }
        }
        
        Task {
            do {
                let times = try await prayerService.getPrayerTimes(districtID: districtID)
                self.prayerTimes = times
                self.state = .success
                notificationManager.scheduleWeekly(times: times)
            } catch {
                self.state = .error("Manuel Konum Vakti Alınamadı: \(error.localizedDescription)")
            }
        }
    }
    
    private func setupBindings() {
        locationManager.mapItemPublisher
            .compactMap { $0 }
            .sink { [weak self] mapItem in
                self?.matchLocationWithAPI(mapItem: mapItem)
            }
            .store(in: &cancellables)
            
        locationManager.errorMessagePublisher
            .compactMap { $0 }
            .sink { [weak self] error in
                guard let self = self else { return }
                if !self.savedDistrictID.isEmpty {
                    self.fetchSavedLocationTimes(districtID: self.savedDistrictID, locationName: self.savedLocationName)
                } else {
                    self.state = .error(error)
                }
            }
            .store(in: &cancellables)
    }
    
    private func matchLocationWithAPI(mapItem: MKMapItem) {
        // Eğer zaten bir lokasyonumuz varsa ve vakitler yüklüyse, tablar arası geçişte tekrar tetiklemeyelim.
        // Sadece uygulama ilk açıldığında veya manuel yenileme istendiğinde çalışmalı.
        if !prayerTimes.isEmpty && state == .success {
            print("DEBUG: Skipping redundant location match (already success)")
            return
        }
        
        state = .matchingAPI
        
        let placemark = mapItem.placemark
        self.resolvedLocationName = "Konum belirleniyor..." 
        
        let country = placemark.country ?? ""
        let city = placemark.administrativeArea ?? ""
        let district = placemark.subAdministrativeArea ?? placemark.locality ?? ""
        
        print("DEBUG: Matching GPS Location: \(country)/\(city)/\(district)")
        
        Task {
            do {
                let service = prayerService

                // 1. Ülke Eşleştirme
                let countries = try await service.getCountries()
                guard let finalCountry = locationMatcher.matchCountry(gpsName: country, countries: countries),
                      finalCountry.countryId == "2" else {
                    state = .error("Sistem şimdilik sadece Türkiye sınırları içerisinde çalışmaktadır.")
                    return
                }
                
                // 2. Şehir Eşleştirme
                let cities = try await service.getCities(countryID: finalCountry.countryId)
                guard let finalCity = locationMatcher.matchCity(gpsName: city, cities: cities) else {
                    state = .error("API üzerinde '\(city)' şehri bulunamadı.")
                    return
                }
                
                // 3. İlçe Eşleştirme
                let districts = try await service.getDistricts(cityID: finalCity.cityId)
                let matchedDistrict = locationMatcher.matchDistrict(targetName: district, city: city, districts: districts)
                
                guard let district = matchedDistrict else {
                    state = .error("API: İlçe listesi boş döndü.")
                    return
                }
                
                print("🎯 API Algılanan Lokasyon: \(finalCountry.countryName)/\(finalCity.cityName)/\(district.districtName) (ID: \(district.districtId))")
                
                // 4. Vakitleri Çek ve Kaydet
                let times = try await service.getPrayerTimes(districtID: district.districtId)
                
                // Koordinatları da kaydet (Global Sync)
                let coord = mapItem.placemark.coordinate
                saveLocationSelection(district: district, city: finalCity, lat: coord.latitude, lon: coord.longitude)
                
                self.prayerTimes = times
                self.resolvedLocationName = "\(district.districtName), \(finalCity.cityName)"
                self.state = .success
                notificationManager.scheduleWeekly(times: times)
                
            } catch {
                // Eğer zaten vakitlerimiz varsa, bir API hatası durumunda success state'ini bozmayalım (sessiz hata)
                if !prayerTimes.isEmpty {
                    print("DEBUG API SILENT ERROR: \(error.localizedDescription)")
                    self.state = .success 
                } else {
                    self.state = .error("API Hatası: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func saveLocationSelection(district: District, city: City, lat: Double, lon: Double) {
        self.savedDistrictID = district.districtId
        self.savedLocationName = "\(district.districtName), \(city.cityName)"
        self.savedLatitude = lat
        self.savedLongitude = lon
    }
}
