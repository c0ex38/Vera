import SwiftUI
import Combine
import CoreLocation

class LocationSettingsViewModel: ObservableObject {
    @AppStorage("autoLocationEnabled") var autoLocationEnabled: Bool = true
    @AppStorage("savedDistrictID") var savedDistrictID: String = ""
    @AppStorage("savedLocationName") var savedLocationName: String = ""
    
    @Published var isLocating = false
    @Published var lastError: String? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Here we could listen for location updates if needed
    }
    
    func refreshGPSLocation() {
        guard autoLocationEnabled else { return }
        isLocating = true
        lastError = nil
        
        // Bu işlem HomeViewModel üzerinden de tetiklenebilir ama burada bağımsız bir tetikleyici ekliyoruz.
        LocationManager.shared.requestLocation()
        
        // Simüle edilmiş bir bekleme (UI tepkisi için)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isLocating = false
        }
    }
}
