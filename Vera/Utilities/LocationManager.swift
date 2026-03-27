import Foundation
import CoreLocation
import MapKit
import Combine
import SwiftUI

// Location yöneticimiz: Konum izinlerini alır ve koordinatı İl/İlçe adına çevirir.
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate, LocationProvider {
    static let shared = LocationManager()
    private let manager = CLLocationManager()
    
    @Published var location: CLLocation?
    @Published var mapItem: MKMapItem?
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var errorMessage: String?
    
    // Global Home Location Sync
    @AppStorage("savedLatitude") private var savedLatitude: Double = 0.0
    @AppStorage("savedLongitude") private var savedLongitude: Double = 0.0
    @AppStorage("autoLocationEnabled") private var autoLocationEnabled: Bool = true
    
    var finalLocation: CLLocation? {
        if autoLocationEnabled {
            return location
        } else if savedLatitude != 0.0 && savedLongitude != 0.0 {
            return CLLocation(latitude: savedLatitude, longitude: savedLongitude)
        }
        return location
    }
    
    var locationPublisher: AnyPublisher<CLLocation?, Never> { $location.eraseToAnyPublisher() }
    
    var finalLocationPublisher: AnyPublisher<CLLocation?, Never> {
        // Otomatik konum, manuel koordinat veya ana ayar değiştiğinde tetiklenir
        Publishers.Merge3(
            $location.map { _ in () },
            NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification).map { _ in () },
            Just(()).eraseToAnyPublisher()
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
        manager.desiredAccuracy = kCLLocationAccuracyKilometer // Namaz vakti ilçe bazlıdır, KM yeterlidir.
        manager.distanceFilter = 500 // 500 metreden az hareketlerde güncelleme yapma
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
        
        // Reverse Geocoding (CoreLocation standard - More reliable for coords)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("DEBUG: Geocoding Error: \(error.localizedDescription)")
                    self?.errorMessage = "Konum çözümlenemedi." // Simplified error
                    return
                }
                
                if let placemark = placemarks?.first {
                    // MKMapItem oluşturmak için placemark'ı kullanıyoruz
                    self?.mapItem = MKMapItem(placemark: MKPlacemark(placemark: placemark))
                    print("DEBUG: Location Resolved: \(placemark.locality ?? "Bilinmiyor")")
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.errorMessage = "Konum alınamadı: \(error.localizedDescription)"
    }
}
