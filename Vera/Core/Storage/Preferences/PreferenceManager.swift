import Foundation
import SwiftUI
import Combine

/// A centralized manager for all application preferences and settings.
/// Replaces direct UserDefaults access for better maintainability and testability.
@MainActor
final class PreferenceManager: ObservableObject {
    
    static let shared = PreferenceManager()
    
    private let defaults = UserDefaults.standard
    
    // MARK: - Keys
    private enum Keys {
        static let databaseVersion = "VeraDatabaseVersion_Refactor"
        static let quranAuthorId = "selectedQuranAuthorId"
        static let districtID = "savedDistrictID"
        static let locationName = "savedLocationName"
        static let latitude = "savedLatitude"
        static let longitude = "savedLongitude"
        static let autoLocationEnabled = "autoLocationEnabled"
        static let cachedQiblaLat = "cachedQiblaLat"
        static let cachedQiblaLon = "cachedQiblaLon"
        static let lastAdTime = "lastInterstitialShowTime"
        static let isSoundEnabled = "isDhikrSoundEnabled"
        static let isVibrationEnabled = "isDhikrVibrationEnabled"
        static let appTheme = "appTheme"
        static let appLanguage = "appLanguage"
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let lastQuranPage = "lastQuranPage"
        
        // Notifications
        static let notificationsEnabled = "notificationsEnabled"
        static let adhanSoundEnabled = "adhanSoundEnabled"
        static let reminderEnabled = "reminderEnabled"
        static let reminderOffset = "reminderOffset"
        static let notifyFajr = "notifyFajr"
        static let notifyDhuhr = "notifyDhuhr"
        static let notifyAsr = "notifyAsr"
        static let notifyMaghrib = "notifyMaghrib"
        static let notifyIsha = "notifyIsha"
    }
    
    // MARK: - Database
    var databaseVersion: Int {
        get { defaults.integer(forKey: Keys.databaseVersion) }
        set { defaults.set(newValue, forKey: Keys.databaseVersion) }
    }
    
    // MARK: - Quran
    @Published var selectedQuranAuthorId: Int {
        didSet { defaults.set(selectedQuranAuthorId, forKey: Keys.quranAuthorId) }
    }
    
    @Published var lastQuranPage: Int {
        didSet { defaults.set(lastQuranPage, forKey: Keys.lastQuranPage) }
    }
    
    // MARK: - Location
    @Published var savedDistrictID: String {
        didSet { defaults.set(savedDistrictID, forKey: Keys.districtID) }
    }
    
    @Published var savedLocationName: String {
        didSet { defaults.set(savedLocationName, forKey: Keys.locationName) }
    }
    
    @Published var savedLatitude: Double {
        didSet { defaults.set(savedLatitude, forKey: Keys.latitude) }
    }
    
    @Published var savedLongitude: Double {
        didSet { defaults.set(savedLongitude, forKey: Keys.longitude) }
    }
    
    @Published var autoLocationEnabled: Bool {
        didSet { defaults.set(autoLocationEnabled, forKey: Keys.autoLocationEnabled) }
    }
    
    // MARK: - Qibla
    @Published var cachedQiblaLat: Double {
        didSet { defaults.set(cachedQiblaLat, forKey: Keys.cachedQiblaLat) }
    }
    
    @Published var cachedQiblaLon: Double {
        didSet { defaults.set(cachedQiblaLon, forKey: Keys.cachedQiblaLon) }
    }
    
    
    // MARK: - Advertising
    var lastAdShowTime: Date? {
        get { defaults.object(forKey: Keys.lastAdTime) as? Date }
        set { defaults.set(newValue, forKey: Keys.lastAdTime) }
    }
    
    // MARK: - Dhikr Settings
    @Published var isSoundEnabled: Bool {
        didSet { defaults.set(isSoundEnabled, forKey: Keys.isSoundEnabled) }
    }
    
    @Published var isVibrationEnabled: Bool {
        didSet { defaults.set(isVibrationEnabled, forKey: Keys.isVibrationEnabled) }
    }
    
    // MARK: - Notifications
    @Published var notifyFajr: Bool { didSet { defaults.set(notifyFajr, forKey: Keys.notifyFajr) } }
    @Published var notifyDhuhr: Bool { didSet { defaults.set(notifyDhuhr, forKey: Keys.notifyDhuhr) } }
    @Published var notifyAsr: Bool { didSet { defaults.set(notifyAsr, forKey: Keys.notifyAsr) } }
    @Published var notifyMaghrib: Bool { didSet { defaults.set(notifyMaghrib, forKey: Keys.notifyMaghrib) } }
    @Published var notifyIsha: Bool { didSet { defaults.set(notifyIsha, forKey: Keys.notifyIsha) } }
    
    // Compatibility keys for Onboarding (unifying with notify keys)
    var alarmFajr: Bool { get { notifyFajr } set { notifyFajr = newValue } }
    var alarmSunrise: Bool { get { defaults.bool(forKey: "alarmSunrise") } set { defaults.set(newValue, forKey: "alarmSunrise") } }
    var alarmDhuhr: Bool { get { notifyDhuhr } set { notifyDhuhr = newValue } }
    var alarmAsr: Bool { get { notifyAsr } set { notifyAsr = newValue } }
    var alarmMaghrib: Bool { get { notifyMaghrib } set { notifyMaghrib = newValue } }
    var alarmIsha: Bool { get { notifyIsha } set { notifyIsha = newValue } }

    @Published var reminderEnabled: Bool { didSet { defaults.set(reminderEnabled, forKey: Keys.reminderEnabled) } }
    @Published var reminderOffset: Int { didSet { defaults.set(reminderOffset, forKey: Keys.reminderOffset) } }
    @Published var adhanSoundEnabled: Bool { didSet { defaults.set(adhanSoundEnabled, forKey: Keys.adhanSoundEnabled) } }
    @Published var notificationsEnabled: Bool { didSet { defaults.set(notificationsEnabled, forKey: Keys.notificationsEnabled) } }
    
    // MARK: - App Settings
    @Published var appTheme: Int { didSet { defaults.set(appTheme, forKey: Keys.appTheme) } }
    @Published var appLanguage: String { didSet { defaults.set(appLanguage, forKey: Keys.appLanguage) } }
    @Published var hasCompletedOnboarding: Bool { didSet { defaults.set(hasCompletedOnboarding, forKey: Keys.hasCompletedOnboarding) } }

    private init() {
        self.selectedQuranAuthorId = defaults.integer(forKey: Keys.quranAuthorId) == 0 ? 11 : defaults.integer(forKey: Keys.quranAuthorId)
        self.lastQuranPage = defaults.integer(forKey: Keys.lastQuranPage) == 0 ? 1 : defaults.integer(forKey: Keys.lastQuranPage)
        self.savedDistrictID = defaults.string(forKey: Keys.districtID) ?? ""
        self.savedLocationName = defaults.string(forKey: Keys.locationName) ?? ""
        self.savedLatitude = defaults.double(forKey: Keys.latitude)
        self.savedLongitude = defaults.double(forKey: Keys.longitude)
        self.autoLocationEnabled = defaults.object(forKey: Keys.autoLocationEnabled) as? Bool ?? true
        
        self.cachedQiblaLat = defaults.double(forKey: Keys.cachedQiblaLat)
        self.cachedQiblaLon = defaults.double(forKey: Keys.cachedQiblaLon)
        
        
        self.isSoundEnabled = defaults.object(forKey: Keys.isSoundEnabled) as? Bool ?? true
        self.isVibrationEnabled = defaults.object(forKey: Keys.isVibrationEnabled) as? Bool ?? true
        
        self.notifyFajr = defaults.object(forKey: Keys.notifyFajr) as? Bool ?? true
        self.notifyDhuhr = defaults.object(forKey: Keys.notifyDhuhr) as? Bool ?? true
        self.notifyAsr = defaults.object(forKey: Keys.notifyAsr) as? Bool ?? true
        self.notifyMaghrib = defaults.object(forKey: Keys.notifyMaghrib) as? Bool ?? true
        self.notifyIsha = defaults.object(forKey: Keys.notifyIsha) as? Bool ?? true
        self.reminderEnabled = defaults.bool(forKey: Keys.reminderEnabled)
        self.reminderOffset = defaults.integer(forKey: Keys.reminderOffset) == 0 ? 15 : defaults.integer(forKey: Keys.reminderOffset)
        self.adhanSoundEnabled = defaults.object(forKey: Keys.adhanSoundEnabled) as? Bool ?? true
        self.notificationsEnabled = defaults.object(forKey: Keys.notificationsEnabled) as? Bool ?? true
        
        self.appTheme = defaults.integer(forKey: Keys.appTheme)
        self.appLanguage = defaults.string(forKey: Keys.appLanguage) ?? "tr"
        self.hasCompletedOnboarding = defaults.bool(forKey: Keys.hasCompletedOnboarding)
    }
    
    /// Resets all preferences to their default values.
    func resetAll() {
        // Reset local properties (which will trigger didSet and update UserDefaults)
        self.hasCompletedOnboarding = false
        self.autoLocationEnabled = true
        self.notificationsEnabled = true
        self.adhanSoundEnabled = true
        self.reminderEnabled = false
        self.savedDistrictID = ""
        self.savedLocationName = ""
        self.savedLatitude = 0
        self.savedLongitude = 0
        self.appTheme = 0 // System
        // We keep the language as is to avoid sudden UI language swap
        
        // Ensure all keys are physically removed for a clean slate
        let allKeys = [
            Keys.districtID, Keys.locationName, Keys.latitude, Keys.longitude,
            Keys.autoLocationEnabled, Keys.hasCompletedOnboarding,
            Keys.notificationsEnabled, Keys.reminderEnabled
        ]
        for key in allKeys {
            defaults.removeObject(forKey: key)
        }
        
        defaults.synchronize()
    }
}
