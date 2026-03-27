import Foundation
import SwiftUI
import Combine

@MainActor
class LocationPickerViewModel: ObservableObject {
    @Published var countries: [Country] = []
    @Published var cities: [City] = []
    @Published var districts: [District] = []
    
    @Published var selectedCountry: Country?
    @Published var selectedCity: City?
    @Published var selectedDistrict: District?
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    @Published var step: PickerStep = .country
    
    private let prayerService: PrayerTimeServiceProvider
    
    enum PickerStep {
        case country
        case city
        case district
    }
    
    init(prayerService: PrayerTimeServiceProvider? = nil) {
        self.prayerService = prayerService ?? PrayerTimeService.shared
        loadCountries()
    }

    
    func loadCountries() {
        isLoading = true
        Task {
            do {
                countries = try await prayerService.getCountries()
                isLoading = false
            } catch {
                errorMessage = "Ülkeler yüklenemedi: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
    
    func selectCountry(_ country: Country) {
        selectedCountry = country
        selectedCity = nil
        selectedDistrict = nil
        step = .city
        
        isLoading = true
        Task {
            do {
                cities = try await prayerService.getCities(countryID: country.countryId)
                
                // Diyanet API "İngiltere" gibi ülkelerde "Şehir" olarak tek Dummy şehir döndürür. O yüzden atla.
                if cities.count == 1, let dummyCity = cities.first {
                    selectCity(dummyCity)
                } else {
                    isLoading = false
                }
            } catch {
                errorMessage = "Şehirler yüklenemedi: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
    
    func selectCity(_ city: City) {
        selectedCity = city
        selectedDistrict = nil
        step = .district
        
        isLoading = true
        Task {
            do {
                districts = try await prayerService.getDistricts(cityID: city.cityId)
                isLoading = false
            } catch {
                errorMessage = "İlçeler yüklenemedi: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }

    
    func selectDistrict(_ district: District) {
        selectedDistrict = district
    }
    
    func goBack() {
        if step == .district {
            step = (selectedCity != nil && cities.count > 1) ? .city : .country
        } else if step == .city {
            step = .country
        }
    }
}
