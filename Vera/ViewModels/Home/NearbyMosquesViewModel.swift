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
    func fetchNearbyMosques(near location: CLLocation) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "Cami"
        
        // Kullanıcının konumunu merkez alarak yaklaşık 5 KM yarıçapında arama yapıyoruz
        let region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: 5000,
            longitudinalMeters: 5000
        )
        request.region = region
        
        isLoading = true
        errorMessage = nil
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = "Arama sırasında bir hata oluştu: \(error.localizedDescription)"
                    return
                }
                
                guard let mapItems = response?.mapItems else {
                    self?.mosques = []
                    return
                }
                
                // Gelen sonuçları listeye alıyoruz
                self?.mosques = mapItems
            }
        }
    }
}
