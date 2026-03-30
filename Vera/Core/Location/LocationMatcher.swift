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
        let mappedNames = mapCountryNameVariants(gpsName)
        
        // 1. Try to find any match from mapped variants
        for name in mappedNames {
            if let matched = countries.first(where: { 
                $0.countryName.isLike(name) || $0.countryNameEn.isLike(name) || 
                $0.countryName.contains(name) || name.contains($0.countryName)
            }) {
                return matched
            }
        }
        
        // 2. Fallback: Direct search if no variant matched
        return countries.first(where: { 
            $0.countryName.isLike(gpsName) || $0.countryNameEn.isLike(gpsName)
        })
    }
    
    func matchCity(gpsName: String, cities: [City]) -> City? {
        let cleanName = gpsName
            .replacingOccurrences(of: " Province", with: "")
            .replacingOccurrences(of: " City", with: "")
            .replacingOccurrences(of: " State of", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        let matched = cities.first(where: { 
            $0.cityName.isLike(cleanName) || $0.cityNameEn.isLike(cleanName) ||
            $0.cityName.contains(cleanName) || cleanName.contains($0.cityName)
        })
        
        return matched ?? cities.first
    }
    
    func matchDistrict(targetName: String, city: String, districts: [District]) -> District? {
        let cleanTarget = targetName
            .replacingOccurrences(of: " District", with: "")
            .replacingOccurrences(of: " City", with: "")
            .replacingOccurrences(of: " County", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 1. Direct match (Tightened)
        var finalDistrict = districts.first(where: { 
            $0.districtName.isLike(cleanTarget) || $0.districtNameEn.isLike(cleanTarget) ||
            $0.districtName.contains(cleanTarget) || cleanTarget.contains($0.districtName)
        })
        
        // 2. Fallback: If no match, try checking if the city name is a district (Very common)
        if finalDistrict == nil {
            finalDistrict = districts.first(where: { 
                $0.districtName.isLike(city) || $0.districtName.contains(city) || city.contains($0.districtName)
            })
        }
        
        // 3. Last Fallback: First district in list
        return finalDistrict ?? districts.first
    }
    
    // MARK: - Private Mappings
    
    private func mapCountryNameVariants(_ name: String) -> [String] {
        let cleanName = name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        switch cleanName {
        case "turkey", "türkiye", "turkiye":
            return ["TURKIYE", "TURKEY"]
        case "united kingdom", "great britain", "uk", "ingiltere":
            return ["INGILTERE", "UNITED KINGDOM"]
        case "united states", "usa", "americ", "abd", "america", "amerika birleşik devletleri":
            return ["ABD", "USA", "AMERIKA"]
        case "china", "çin", "cin":
            return ["CIN", "CHINA"]
        case "central african republic", "orta afrika cumhuriyeti":
            return ["ORTA AFRIKA CUMHURIYETI"]
        case "germany", "almanya":
            return ["ALMANYA", "GERMANY"]
        case "france", "fransa":
            return ["FRANSA", "FRANCE"]
        case "russia", "rusya":
            return ["RUSYA", "RUSSIA"]
        default:
            return [name.uppercased()]
        }
    }
}

