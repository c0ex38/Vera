import XCTest
@testable import Vera

final class LocationMatcherTests: XCTestCase {
    var sut: LocationMatcher!
    
    override func setUp() {
        super.setUp()
        sut = LocationMatcher()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_matchCountry_withEnglishName_returnsMappedTurkishName() {
        // Given
        let countries = [
            Country(countryName: "TURKIYE", countryNameEn: "Turkey", countryId: "2")
        ]
        
        // When
        let result = sut.matchCountry(gpsName: "Turkey", countries: countries)
        
        // Then
        XCTAssertEqual(result?.countryName, "TURKIYE")
        XCTAssertEqual(result?.countryId, "2")
    }
    
    func test_matchCity_withProvinceSuffix_matchesCorrectly() {
        // Given
        let cities = [
            City(cityName: "ISTANBUL", cityNameEn: "Istanbul", cityId: "34"),
            City(cityName: "ANKARA", cityNameEn: "Ankara", cityId: "06")
        ]
        
        // When
        let result = sut.matchCity(gpsName: "Istanbul Province", cities: cities)
        
        // Then
        XCTAssertEqual(result?.cityName, "ISTANBUL")
    }
    
    func test_matchDistrict_withDistrictSuffix_matchesCorrectly() {
        // Given
        let districts = [
            District(districtName: "USKUDAR", districtNameEn: "Uskudar", districtId: "12345"),
            District(districtName: "KADIKOY", districtNameEn: "Kadikoy", districtId: "54321")
        ]
        
        // When
        let result = sut.matchDistrict(targetName: "Uskudar District", city: "Istanbul", districts: districts)
        
        // Then
        XCTAssertEqual(result?.districtName, "USKUDAR")
    }
    
    func test_matchDistrict_fallbackToCityName_works() {
        // Given
        let districts = [
            District(districtName: "PENDIK", districtNameEn: "Pendik", districtId: "999")
        ]
        
        // When
        // In some cases, the city name might be the only match in the district list
        let result = sut.matchDistrict(targetName: "Some Specific Area", city: "Pendik", districts: districts)
        
        // Then
        XCTAssertEqual(result?.districtName, "PENDIK")
    }
}
