import Foundation
import MapKit

/// A specialized service that matches MapKit/GPS location components with Diyanet API IDs.
/// Logic is extracted from HomeViewModel to ensure better testability and Single Responsibility.
protocol LocationMatching: Sendable {
    func matchCountry(gpsName: String, countries: [Country]) -> Country?
    func matchCity(gpsName: String, cities: [City]) -> City?
    func matchDistrict(targetName: String, city: String, districts: [District]) -> District?
}

struct LocationMatcher: LocationMatching {
    
    func matchCountry(gpsName: String, countries: [Country]) -> Country? {
        let mappedName = mapCountryName(gpsName)
        return countries.first(where: { 
            $0.countryName.isLike(mappedName) || $0.countryNameEn.isLike(mappedName)
        })
    }
    
    func matchCity(gpsName: String, cities: [City]) -> City? {
        let cleanName = gpsName
            .replacingOccurrences(of: " Province", with: "")
            .replacingOccurrences(of: " City", with: "")
            .replacingOccurrences(of: " State of", with: "")
        
        let matched = cities.first(where: { 
            $0.cityName.isLike(cleanName) || $0.cityNameEn.isLike(cleanName)
        })
        
        return matched ?? cities.first
    }
    
    func matchDistrict(targetName: String, city: String, districts: [District]) -> District? {
        let cleanTarget = targetName
            .replacingOccurrences(of: " District", with: "")
            .replacingOccurrences(of: " City", with: "")
            .replacingOccurrences(of: " County", with: "")
        
        // 1. Direct match (Tightened)
        var finalDistrict = districts.first(where: { 
            $0.districtName.isLike(cleanTarget) || $0.districtNameEn.isLike(cleanTarget)
        })
        
        // 2. Fallback: If no match, try checking if the city name is a district (Very common)
        if finalDistrict == nil {
            finalDistrict = districts.first(where: { $0.districtName.isLike(city) })
        }
        
        // 3. Last Fallback: First district in list
        return finalDistrict ?? districts.first
    }
    
    // MARK: - Private Mappings
    
    private func mapCountryName(_ name: String) -> String {
        switch name.lowercased() {
        case "turkey", "türkiye", "turkiye":
            return "TURKIYE"
        default:
            return name
        }
    }
}

