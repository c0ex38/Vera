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
    
    // Centralized preferences
    private let preferences = PreferenceManager.shared
    
    var todayPrayerTime: PrayerTime? {
        return prayerTimes.first(where: {
            VeraDateFormatters.isToday(isoDate: $0.gregorianDateShortIso8601, trDate: $0.gregorianDateShort)
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
        Task {
            let manager = AppDatabaseManager.shared
            self.hadithOfTheDay = await manager.fetchHadithOfTheDay()
        }
        
        if preferences.autoLocationEnabled {
            Task { @MainActor in
                state = .requestingLocation
                locationManager.requestLocation()
            }
        } else {
            if !preferences.savedDistrictID.isEmpty {
                fetchSavedLocationTimes(districtID: preferences.savedDistrictID, locationName: preferences.savedLocationName)
            } else {
                state = .error(L10n.HomeError.autoLocationDisabled)
            }
        }
    }

    func fetchSavedLocationTimes(districtID: String, locationName: String) {
        state = .requestingLocation
        self.resolvedLocationName = locationName
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(locationName) { [weak self] placemarks, _ in
            guard let coordinate = placemarks?.first?.location?.coordinate else { return }
            let lat = coordinate.latitude
            let lon = coordinate.longitude
            
            Task { @MainActor [weak self] in
                self?.preferences.savedLatitude = lat
                self?.preferences.savedLongitude = lon
            }
        }
        
        Task {
            do {
                let times = try await prayerService.getPrayerTimes(districtID: districtID)
                self.prayerTimes = times
                self.state = .success
                notificationManager.scheduleWeekly(times: times)
            } catch {
                self.state = .error(L10n.HomeError.manualLocationFailed(error.localizedDescription))
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
                if !self.preferences.savedDistrictID.isEmpty {
                    self.fetchSavedLocationTimes(districtID: self.preferences.savedDistrictID, locationName: self.preferences.savedLocationName)
                } else {
                    self.state = .error(error)
                }
            }
            .store(in: &cancellables)
            
        // Observe preference changes to restart if autoLocation is toggled
        preferences.$autoLocationEnabled
            .dropFirst()
            .sink { [weak self] enabled in
                self?.start()
            }
            .store(in: &cancellables)
    }
    
    private func matchLocationWithAPI(mapItem: MKMapItem) {
        Task { @MainActor in
            if !prayerTimes.isEmpty && state == .success {
                return
            }
            
            state = .matchingAPI
            
            let placemark = mapItem.placemark
            self.resolvedLocationName = L10n.HomeError.resolvingLocation
            
            let country = placemark.country ?? ""
            let city = placemark.administrativeArea ?? ""
            let district = placemark.subAdministrativeArea ?? placemark.locality ?? ""
            
            do {
                let service = prayerService
                let countries = try await service.getCountries()
                
                guard let finalCountry = locationMatcher.matchCountry(gpsName: country, countries: countries) else {
                    state = .error(L10n.HomeError.turkeyOnly)
                    return
                }
                
                let cities = try await service.getCities(countryID: finalCountry.countryId)
                
                // Anomaly Handle: If there's only one "city" and it's basically the country's name (like UK), 
                // we skip it and go straight to districts (which are actually the cities for those countries).
                var targetCity: City?
                if cities.count == 1, 
                   let first = cities.first, 
                   (first.cityName.isLike(finalCountry.countryName) || first.cityNameEn.isLike(finalCountry.countryNameEn)) {
                    targetCity = first
                } else {
                    targetCity = locationMatcher.matchCity(gpsName: city, cities: cities)
                }
                
                guard let finalCity = targetCity else {
                    state = .error(L10n.HomeError.cityNotFound(city))
                    return
                }
                
                let districts = try await service.getDistricts(cityID: finalCity.cityId)
                let matchedDistrict = locationMatcher.matchDistrict(targetName: district, city: city, districts: districts)
                
                guard let district = matchedDistrict else {
                    state = .error(L10n.HomeError.districtEmpty)
                    return
                }
                
                let times = try await service.getPrayerTimes(districtID: district.districtId)
                let coord = mapItem.placemark.coordinate
                saveLocationSelection(district: district, city: finalCity, lat: coord.latitude, lon: coord.longitude)
                
                self.prayerTimes = times
                self.resolvedLocationName = "\(district.districtName), \(finalCity.cityName)"
                self.state = .success
                notificationManager.scheduleWeekly(times: times)
                
            } catch {
                if !prayerTimes.isEmpty {
                    self.state = .success 
                } else {
                    self.state = .error(L10n.HomeError.apiFailed(error.localizedDescription))
                }
            }
        }
    }
    
    private func saveLocationSelection(district: District, city: City, lat: Double, lon: Double) {
        preferences.savedDistrictID = district.districtId
        preferences.savedLocationName = "\(district.districtName), \(city.cityName)"
        preferences.savedLatitude = lat
        preferences.savedLongitude = lon
    }
}
