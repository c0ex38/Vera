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
    
    // Kabe Koordinatları
    private let meccaLocation = CLLocation(latitude: 21.422487, longitude: 39.826206)
    private var locationManager: CLLocationManager
    private var lastLocation: CLLocation?
    
    // Uygulama her açıldığında konum istemesin diye son bilinen konumu hafızada tutuyoruz
    @AppStorage("cachedQiblaLat") private var cachedLat: Double = 0.0
    @AppStorage("cachedQiblaLon") private var cachedLon: Double = 0.0
    
    // Sistem geneli Konum tercihi
    @AppStorage("autoLocationEnabled") private var autoLocationEnabled: Bool = true
    
    override init() {
        locationManager = CLLocationManager()
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.headingFilter = 1.0 // Saptırmaları (jitter) azaltmak için 1 derecelik filtre
    }
    
    private var lastAngle: Double = 0.0
    
    func start() {
        let status = locationManager.authorizationStatus
        if autoLocationEnabled && cachedLat == 0.0 {
            if status == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
            } else if status == .denied || status == .restricted {
                errorMsg = "Kıble pusulası için konum iznine ihtiyacımız var."
            }
        }
        
        // Eğer önbellekte konum varsa, her tab açılışında GPS'i tetikleyip yormuyoruz.
        if cachedLat != 0.0 && cachedLon != 0.0 {
            let savedLoc = CLLocation(latitude: cachedLat, longitude: cachedLon)
            self.lastLocation = savedLoc
            self.distanceToQibla = savedLoc.distance(from: meccaLocation) / 1000.0
            self.qiblaBearing = self.calculateBearing(from: savedLoc, to: self.meccaLocation)
            self.updateAngle()
        } else if autoLocationEnabled {
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                locationManager.startUpdatingLocation()
            }
        } else {
            errorMsg = "Konum verisi bulunamadı. Lütfen ana sayfadan konum seçin veya Ayarlar'dan otomatiği açın."
        }
        
        #if targetEnvironment(simulator)
        // Simulator'da fiziksel pusula olmadığı için test edebilmeniz adına sabit bir açı veriyoruz.
        self.heading = 0.0
        if self.lastLocation == nil {
            let mockLoc = CLLocation(latitude: 41.0082, longitude: 28.9784)
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
    
    // Uygulama ilk kez izin aldığında pusula ve konumu anında tetikler.
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            errorMsg = nil
            if cachedLat == 0.0 {
                manager.startUpdatingLocation()
            }
            #if !targetEnvironment(simulator)
            if CLLocationManager.headingAvailable() {
                manager.startUpdatingHeading()
            }
            #endif
        } else if status == .denied || status == .restricted {
            // Kullanıcı izni reddettiyse
            errorMsg = "Kıble pusulası için konum iznine ihtiyacımız var."
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.lastLocation = location
        
        // Önbelleğe kaydet
        self.cachedLat = location.coordinate.latitude
        self.cachedLon = location.coordinate.longitude
        
        // Kabe uzakta olduğu için kullanıcının yürümesi açıyı değiştirmez. 
        // Konumu ilk seferde bulduktan sonra pil optimizasyonu ve gizlilik için konum izlemeyi kapatıyoruz.
        // Sadece pusula (heading) çalışmaya devam etmelidir.
        manager.stopUpdatingLocation()
        
        // Mesafe hesapla (Metre cinsinden gelir, KM'ye çevir)
        let distance = location.distance(from: meccaLocation) / 1000.0
        self.distanceToQibla = distance
        
        // Bearing hesapla
        self.qiblaBearing = self.calculateBearing(from: location, to: self.meccaLocation)
        self.updateAngle()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        // True heading (Coğrafi kuzey) varsa onu, yoksa Manyetik kuzeyi kullan
        self.heading = newHeading.trueHeading > 0 ? newHeading.trueHeading : newHeading.magneticHeading
        self.updateAngle()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Pusula/Konum Hatası: \(error.localizedDescription)")
    }
    
    private func updateAngle() {
        // Cihazın yönü ile Kabe'nin açısı arasındaki fark
        var rawAngle = qiblaBearing - heading
        if rawAngle < 0 {
            rawAngle += 360
        }
        
        // 0-360 sınırı geçişindeki "sapıtma" (ters dönme) problemini çözen shortest-path algoritması
        let currentRem = lastAngle.truncatingRemainder(dividingBy: 360)
        let adjustedRem = currentRem < 0 ? currentRem + 360 : currentRem
        
        let delta = rawAngle - adjustedRem
        var newAngle = lastAngle + delta
        
        // Eğer delta yarım turdan (180) büyükse, en kısa yoldan dönmesini sağla
        if delta > 180 {
            newAngle -= 360
        } else if delta < -180 {
            newAngle += 360
        }
        
        self.angleToQibla = newAngle
        self.lastAngle = newAngle
        
        // ±3 derece toleransla Kabe yönüne bakıyor mu kontrol et (Ham açıya göre test edilir)
        let isFacing = (rawAngle <= 2 || rawAngle >= 358)
        
        if isFacing && !self.isFacingQibla {
            // Tam hedefe gelindiğinde titreşim
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
