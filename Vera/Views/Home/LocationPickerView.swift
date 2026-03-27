import SwiftUI

struct LocationPickerView: View {
    @StateObject private var viewModel = LocationPickerViewModel()
    
    // Uygulama belleğine ilçe ID'si ve ekranda göstermek için ismini kaydediyoruz (UserDefaults)
    @AppStorage("savedDistrictID") private var savedDistrictID: String = ""
    @AppStorage("savedLocationName") private var savedLocationName: String = ""
    
    @Environment(\.dismiss) var dismiss
    @State private var searchText: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Yükleniyor...")
                        .padding()
                } else if let error = viewModel.errorMessage {
                    Text(error).foregroundColor(.red).padding()
                }
                
                List {
                    switch viewModel.step {
                    case .country:
                        ForEach(filteredCountries) { country in
                            Button(country.countryName) {
                                viewModel.selectCountry(country)
                            }
                            .foregroundColor(.themeText)
                        }
                    case .city:
                        ForEach(filteredCities) { city in
                            Button(city.cityName) {
                                viewModel.selectCity(city)
                            }
                            .foregroundColor(.themeText)
                        }
                    case .district:
                        ForEach(filteredDistricts) { district in
                            Button(district.districtName) {
                                viewModel.selectDistrict(district)
                                saveAndDismiss(district: district)
                            }
                            .foregroundColor(.themeText)
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Ara...")
            .navigationTitle(navTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if viewModel.step != .country {
                        Button(action: {
                            searchText = ""
                            viewModel.goBack()
                        }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Geri")
                            }
                            .foregroundColor(.themePrimary)
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") { dismiss() }
                        .foregroundColor(.themePrimary)
                }
            }
        }
    }
    
    // MARK: - Arama Filtreleri
    private var filteredCountries: [Country] {
        if searchText.isEmpty { return viewModel.countries }
        return viewModel.countries.filter { $0.countryName.localizedCaseInsensitiveContains(searchText) }
    }
    
    private var filteredCities: [City] {
        if searchText.isEmpty { return viewModel.cities }
        return viewModel.cities.filter { $0.cityName.localizedCaseInsensitiveContains(searchText) }
    }
    
    private var filteredDistricts: [District] {
        if searchText.isEmpty { return viewModel.districts }
        return viewModel.districts.filter { $0.districtName.localizedCaseInsensitiveContains(searchText) }
    }
    
    private var navTitle: String {
        switch viewModel.step {
        case .country: return "Ülke Seçin"
        case .city: return "Şehir Seçin"
        case .district: return "İlçe Seçin"
        }
    }
    
    // MARK: - Kayıt
    private func saveAndDismiss(district: District) {
        savedDistrictID = district.districtId
        
        let cityPart = viewModel.selectedCity?.cityName ?? ""
        let countryPart = viewModel.selectedCountry?.countryName ?? ""
        
        if cityPart == countryPart || cityPart.isEmpty {
            savedLocationName = "\(district.districtName), \(countryPart)"
        } else {
            savedLocationName = "\(district.districtName), \(cityPart)"
        }
        
        dismiss()
    }
}
