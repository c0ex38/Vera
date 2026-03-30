import SwiftUI
import Combine
import CoreLocation

@MainActor
class LocationSettingsViewModel: ObservableObject {
    
    // Centralized preferences
    private let preferences = PreferenceManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    @Published var autoLocationEnabled: Bool
    @Published var savedDistrictID: String
    @Published var savedLocationName: String
    
    @Published var isLocating = false
    @Published var lastError: String? = nil
    
    init() {
        self.autoLocationEnabled = preferences.autoLocationEnabled
        self.savedDistrictID = preferences.savedDistrictID
        self.savedLocationName = preferences.savedLocationName
        
        setupBindings()
    }
    
    private func setupBindings() {
        $autoLocationEnabled.sink { [weak self] in self?.preferences.autoLocationEnabled = $0 }.store(in: &cancellables)
        $savedDistrictID.sink { [weak self] in self?.preferences.savedDistrictID = $0 }.store(in: &cancellables)
        $savedLocationName.sink { [weak self] in self?.preferences.savedLocationName = $0 }.store(in: &cancellables)
    }
    
    func refreshGPSLocation() {
        guard autoLocationEnabled else { return }
        isLocating = true
        lastError = nil
        
        LocationManager.shared.requestLocation()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isLocating = false
        }
    }
}
