import Foundation
import CoreLocation
import MapKit
import Combine
import SwiftUI

/// Location manager that handles permissions and coordinate-to-address conversion.
/// Refactored to use PreferenceManager for centralized state management.
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate, LocationProvider {
    static let shared = LocationManager()
    private let manager = CLLocationManager()
    private let preferences: PreferenceManager = PreferenceManager.shared
    
    @Published var location: CLLocation?
    @Published var mapItem: MKMapItem?
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var errorMessage: String?
    
    var finalLocation: CLLocation? {
        if preferences.autoLocationEnabled {
            return location
        } else if preferences.savedLatitude != 0.0 && preferences.savedLongitude != 0.0 {
            return CLLocation(latitude: preferences.savedLatitude, longitude: preferences.savedLongitude)
        }
        return location
    }
    
    var locationPublisher: AnyPublisher<CLLocation?, Never> { $location.eraseToAnyPublisher() }
    
    var finalLocationPublisher: AnyPublisher<CLLocation?, Never> {
        // Triggers on location updates or preference changes
        Publishers.Merge(
            $location.map { _ in () },
            preferences.objectWillChange.map { _ in () }
        )
        .receive(on: RunLoop.main)
        .map { [weak self] _ in self?.finalLocation }
        .removeDuplicates()
        .eraseToAnyPublisher()
    }
    
    var mapItemPublisher: AnyPublisher<MKMapItem?, Never> { $mapItem.eraseToAnyPublisher() }
    var errorMessagePublisher: AnyPublisher<String?, Never> { $errorMessage.eraseToAnyPublisher() }
    
    override init() {
        self.authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        manager.distanceFilter = 500
    }
    
    func requestLocation() {
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        } else {
            manager.requestLocation()
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.authorizationStatus = manager.authorizationStatus
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            DispatchQueue.main.async {
                if let error = error {
                    DebugLog.error("Geocoding Error: \(error.localizedDescription)")
                    self?.errorMessage = L10n.LocationError.cannotResolve
                    return
                }
                
                if let placemark = placemarks?.first {
                    self?.mapItem = MKMapItem(placemark: MKPlacemark(placemark: placemark))
                    DebugLog.log("Location Resolved: \(placemark.locality ?? "Bilinmiyor")")
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.errorMessage = L10n.LocationError.cannotGet(error.localizedDescription)
    }
}
