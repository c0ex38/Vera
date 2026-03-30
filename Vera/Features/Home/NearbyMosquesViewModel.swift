import Foundation
import MapKit
import Combine
import CoreLocation

// Çevredeki camileri arama ve listeleme işlemlerini yöneten ViewModel
class NearbyMosquesViewModel: ObservableObject {
    @Published var mosques: [MKMapItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    func fetchNearbyMosques(in region: MKCoordinateRegion? = nil, near location: CLLocation? = nil) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = L10n.NearbyMosques.searchQuery
        
        if let region = region {
            request.region = region
        } else if let location = location {
            request.region = MKCoordinateRegion(
                center: location.coordinate,
                latitudinalMeters: 5000,
                longitudinalMeters: 5000
            )
        }
        
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
                
                self?.mosques = response?.mapItems ?? []
            }
        }
    }
}
