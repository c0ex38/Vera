import Foundation
import MapKit
import Combine
import CoreLocation

// Çevredeki camileri arama ve listeleme işlemlerini yöneten ViewModel
class NearbyMosquesViewModel: ObservableObject {
    @Published var mosques: [MKMapItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    // MKLocalSearch ile "Cami" kelimesini kullanıcının etrafında arıyoruz.
    /// MKLocalSearch ile camileri arama ve listeleme
    /// - Parameters:
    ///   - region: Arama yapılacak spesifik harita bölgesi (Nil ise konuma göre arar)
    ///   - location: Arama merkez koordinatı
    func fetchNearbyMosques(in region: MKCoordinateRegion? = nil, near location: CLLocation? = nil) {
        let request = MKLocalSearch.Request()
        
        // Daha geniş sonuç için hem yerel hem de global terimi birleştiriyoruz
        let baseQuery = L10n.NearbyMosques.searchQuery
        request.naturalLanguageQuery = baseQuery.lowercased().contains("mosque") ? baseQuery : "\(baseQuery) Mosque"
        
        if let region = region {
            request.region = region
        } else if let location = location {
            // Yarıçapı 5 km'den 10 km'ye çıkarıyoruz
            request.region = MKCoordinateRegion(
                center: location.coordinate,
                latitudinalMeters: 10000,
                longitudinalMeters: 10000
            )
        }
        
        // Not: .religiousSite veya .placeOfWorship gibi kategoriler iOS 18 öncesi SDK'larda bulunmayabilir.
        // Bu yüzden aramayı sadece 'naturalLanguageQuery' üzerinden yapıyoruz, bu en güvenli yöntemdir.
        request.resultTypes = .pointOfInterest
        
        isLoading = true
        errorMessage = nil
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = "Arama yapılamadı: \(error.localizedDescription)"
                    return
                }
                
                guard let mapItems = response?.mapItems else {
                    self?.mosques = []
                    return
                }
                
                // Mevcut sonuçlarla yenileri birleştirip ID bazlı tekilleştiriyoruz (Ekranda daha çok Cami kalsın diye)
                let combined = (self?.mosques ?? []) + mapItems
                var uniqueMosques: [MKMapItem] = []
                var seenNames = Set<String>()
                
                for item in combined {
                    let name = item.name ?? ""
                    if !seenNames.contains(name) {
                        seenNames.insert(name)
                        uniqueMosques.append(item)
                    }
                }
                
                // Sadece en yakınları veya yeni bulunanları göster (Maks 50)
                self?.mosques = Array(uniqueMosques.prefix(50))
            }
        }
    }
}
