import Foundation
import SwiftUI
import Combine

/// A central container for application dependencies.
/// This container manages the lifecycle of core services and provides them as protocols
/// to ensure a decoupled and testable architecture.
@MainActor
final class DependencyContainer: ObservableObject {
    /// Explicitly provide the publisher for ObservableObject conformance.
    public let objectWillChange = ObservableObjectPublisher()
    
    let database: DatabaseProvider
    let prayerService: PrayerTimeServiceProvider
    let notification: NotificationProvider
    let location: LocationProvider
    let environment: EnvironmentProvider
    let interstitialAdManager: InterstitialAdManager
    let preferences: PreferenceManager
    let sermon: SermonServiceProvider
    
    init(
        database: DatabaseProvider? = nil,
        prayerService: PrayerTimeServiceProvider? = nil,
        notification: NotificationProvider? = nil,
        location: LocationProvider? = nil,
        environment: EnvironmentProvider? = nil,
        interstitialAdManager: InterstitialAdManager? = nil,
        preferences: PreferenceManager? = nil,
        sermon: SermonServiceProvider? = nil
    ) {
        self.database = database ?? AppDatabaseManager.shared
        self.prayerService = prayerService ?? PrayerTimeService.shared
        self.notification = notification ?? NotificationManager.shared
        self.location = location ?? LocationManager.shared
        self.environment = environment ?? AppEnvironment.shared
        self.interstitialAdManager = interstitialAdManager ?? InterstitialAdManager.shared
        self.preferences = preferences ?? PreferenceManager.shared
        self.sermon = sermon ?? SermonService.shared
    }
}
