import Foundation
import MapKit
import Combine

/// A protocol defining the core database operations for the Vera application.
/// Conforming types provide thread-safe access to persistence for both static (Quran, Esmaul Husna)
/// and dynamic (Dhikr) user data.
protocol DatabaseProvider: Sendable {
    /// Retrieves all 99 names of Allah.
    func fetchEsmaulHusna() async -> [EsmaulHusna]
    
    /// Retrieves a collection of short surahs used in prayer.
    func fetchPrayerSurahs() async -> [Surah]
    
    /// Retrieves religious holidays and significant dates for the current year.
    func fetchReligiousDays() async -> [ReligiousDay]
    
    /// Retrieves the currently active dhikr counter and its progress.
    func fetchActiveDhikr() async -> Dhikr?
    
    /// Persists the state of the active dhikr counter.
    func saveActiveDhikr(_ dhikr: Dhikr) async
    
    /// Retrieves all available Quran translations and authors.
    func fetchAuthors() async -> [QuranAuthor]
    
    /// Retrieves a list of all 114 surahs in the Quran.
    func fetchSurahs() async -> [QuranChapter]
    
    /// Retrieves all verses for a specific page of the Quran using the selected translation.
    func fetchVersesForPage(page: Int, authorId: Int) async -> [QuranVerse]
    
    /// Retrieves a random hadith for the day.
    func fetchHadithOfTheDay() async -> Hadith?
    
    /// Retrieves all 999 hadiths from the database.
    func fetchAllHadiths() async -> [Hadith]
    
    /// Retrieves a specific range of hadiths for pagination.
    func fetchHadithsPaged(offset: Int, limit: Int) async -> [Hadith]
    
    /// Performs a global search across all hadiths.
    func searchHadiths(query: String) async -> [Hadith]
    
    /// Retrieves the total number of hadiths in the database.
    func fetchHadithCount() async -> Int
    
    /// Retrieves the predefined dhikr templates from the 'dhikr_templates' table.
    func fetchDhikrTemplates() async -> [DhikrTemplate]
}

/// A protocol defining the networking operations for retrieving prayer times and location data.
/// Conforming types manage API interactions and local JSON caching for optimized performance.
protocol PrayerTimeServiceProvider: Sendable {
    /// Retrieves a list of supported countries.
    func getCountries() async throws -> [Country]
    
    /// Retrieves a list of cities within a specific country.
    func getCities(countryID: String) async throws -> [City]
    
    /// Retrieves a list of districts within a specific city.
    func getDistricts(cityID: String) async throws -> [District]
    
    /// Retrieves a 30-day schedule of prayer times for a specific district.
    func getPrayerTimes(districtID: String) async throws -> [PrayerTime]
}


/// A protocol for managing local notifications and prayer reminders.
protocol NotificationProvider: AnyObject {
    var isAuthorized: Bool { get }
    func requestAuthorization() async -> Bool
    func updateAuthorizationStatus() async
    func scheduleWeekly(times: [PrayerTime])
    func refreshCurrentSchedule(using prayerService: PrayerTimeServiceProvider?)
    func cancelAllNotifications()
}

/// A protocol for location-related services.
protocol LocationProvider: AnyObject {
    var location: CLLocation? { get }
    var finalLocation: CLLocation? { get }
    var authorizationStatus: CLAuthorizationStatus { get }
    var mapItem: MKMapItem? { get }
    var errorMessage: String? { get }
    
    var locationPublisher: AnyPublisher<CLLocation?, Never> { get }
    var finalLocationPublisher: AnyPublisher<CLLocation?, Never> { get }
    var mapItemPublisher: AnyPublisher<MKMapItem?, Never> { get }
    var errorMessagePublisher: AnyPublisher<String?, Never> { get }
    
    func requestLocation()
}

/// A protocol for application-level environment configuration.
protocol EnvironmentProvider: Sendable {
    var apiBaseURL: String { get }
    var admobBannerID: String { get }
    var admobAppOpenID: String { get }
    var admobInterstitialID: String { get }
}

protocol SermonServiceProvider: Sendable {
    func fetchLatestSermons() async throws -> [Sermon]
}

