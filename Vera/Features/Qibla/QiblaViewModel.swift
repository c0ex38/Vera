import Foundation
import CoreLocation
import Combine
import SwiftUI

class QiblaViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var heading: Double = 0.0
    @Published var qiblaBearing: Double = 0.0
    @Published var angleToQibla: Double = 0.0
    @Published var distanceToQibla: Double = 0.0
    @Published var isFacingQibla: Bool = false
    @Published var errorMsg: String?
    
    // Centralized preferences
    private let preferences = PreferenceManager.shared
    
    // Kabe Koordinatları (The Kaaba, Mecca)
    private let meccaLocation = CLLocation(latitude: 21.422487, longitude: 39.826206)
    private var locationManager: CLLocationManager
    private var lastLocation: CLLocation?
    
    override init() {
        locationManager = CLLocationManager()
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.headingFilter = 1.0
    }
    
    private var lastAngle: Double = 0.0
    
    func start() {
        let status = locationManager.authorizationStatus
        let cachedLat = preferences.cachedQiblaLat
        let cachedLon = preferences.cachedQiblaLon
        
        if preferences.autoLocationEnabled && cachedLat == 0.0 {
            if status == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
            } else if status == .denied || status == .restricted {
                errorMsg = "Kıble pusulası için konum iznine ihtiyacımız var."
            }
        }
        
        // Use cached location to avoid immediate GPS ping
        if cachedLat != 0.0 && cachedLon != 0.0 {
            let savedLoc = CLLocation(latitude: cachedLat, longitude: cachedLon)
            self.lastLocation = savedLoc
            self.distanceToQibla = savedLoc.distance(from: meccaLocation) / 1000.0
            self.qiblaBearing = self.calculateBearing(from: savedLoc, to: self.meccaLocation)
            self.updateAngle()
        } else if preferences.autoLocationEnabled {
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                locationManager.startUpdatingLocation()
            }
        } else {
            errorMsg = "Konum verisi bulunamadı. Lütfen ana sayfadan konum seçin veya Ayarlar'dan otomatiği açın."
        }
        
        #if targetEnvironment(simulator)
        self.heading = 0.0
        if self.lastLocation == nil {
            let mockLoc = CLLocation(latitude: 41.0082, longitude: 28.9784) // Istanbul
            self.locationManager(self.locationManager, didUpdateLocations: [mockLoc])
        }
        #else
        if CLLocationManager.headingAvailable() {
            locationManager.startUpdatingHeading()
        } else {
            errorMsg = "Cihazınız pusula desteklemiyor."
        }
        #endif
    }
    
    func stop() {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            errorMsg = nil
            if preferences.cachedQiblaLat == 0.0 {
                manager.startUpdatingLocation()
            }
            #if !targetEnvironment(simulator)
            if CLLocationManager.headingAvailable() {
                manager.startUpdatingHeading()
            }
            #endif
        } else if status == .denied || status == .restricted {
            errorMsg = "Kıble pusulası için konum iznine ihtiyacımız var."
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.lastLocation = location
        
        // Cache location in preference manager
        preferences.cachedQiblaLat = location.coordinate.latitude
        preferences.cachedQiblaLon = location.coordinate.longitude
        
        manager.stopUpdatingLocation()
        
        let distance = location.distance(from: meccaLocation) / 1000.0
        self.distanceToQibla = distance
        
        self.qiblaBearing = self.calculateBearing(from: location, to: self.meccaLocation)
        self.updateAngle()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.heading = newHeading.trueHeading > 0 ? newHeading.trueHeading : newHeading.magneticHeading
        self.updateAngle()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DebugLog.error("Pusula/Konum Hatası: \(error.localizedDescription)")
    }
    
    private func updateAngle() {
        var rawAngle = qiblaBearing - heading
        if rawAngle < 0 {
            rawAngle += 360
        }
        
        let currentRem = lastAngle.truncatingRemainder(dividingBy: 360)
        let adjustedRem = currentRem < 0 ? currentRem + 360 : currentRem
        
        let delta = rawAngle - adjustedRem
        var newAngle = lastAngle + delta
        
        if delta > 180 {
            newAngle -= 360
        } else if delta < -180 {
            newAngle += 360
        }
        
        self.angleToQibla = newAngle
        self.lastAngle = newAngle
        
        let isFacing = (rawAngle <= 2 || rawAngle >= 358)
        
        if isFacing && !self.isFacingQibla {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }
        
        self.isFacingQibla = isFacing
    }
    
    private func calculateBearing(from startLocation: CLLocation, to endLocation: CLLocation) -> Double {
        let lat1 = startLocation.coordinate.latitude.degreesToRadians
        let lon1 = startLocation.coordinate.longitude.degreesToRadians
        
        let lat2 = endLocation.coordinate.latitude.degreesToRadians
        let lon2 = endLocation.coordinate.longitude.degreesToRadians
        
        let dLon = lon2 - lon1
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        
        var radiansBearing = atan2(y, x)
        if radiansBearing < 0.0 {
            radiansBearing += 2 * .pi
        }
        
        return radiansBearing.radiansToDegrees
    }
}
