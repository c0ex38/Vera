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
    let subscription: SubscriptionProvider
    let notification: NotificationProvider
    let location: LocationProvider
    let environment: EnvironmentProvider
    
    init(
        database: DatabaseProvider? = nil,
        prayerService: PrayerTimeServiceProvider? = nil,
        subscription: SubscriptionProvider? = nil,
        notification: NotificationProvider? = nil,
        location: LocationProvider? = nil,
        environment: EnvironmentProvider? = nil
    ) {
        self.database = database ?? AppDatabaseManager.shared
        self.prayerService = prayerService ?? PrayerTimeService.shared
        self.subscription = subscription ?? SubscriptionManager.shared
        self.notification = notification ?? NotificationManager.shared
        self.location = location ?? LocationManager.shared
        self.environment = environment ?? AppEnvironment.shared
    }
}
