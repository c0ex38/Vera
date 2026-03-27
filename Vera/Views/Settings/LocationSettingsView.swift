import SwiftUI

struct LocationSettingsView: View {
    @StateObject private var viewModel = LocationSettingsViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var showPicker = false
    
    var body: some View {
        ZStack {
            Color.themeBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Premium Header
                VeraCustomHeader(title: "Konum Tercihleri", subtitle: "Ezan Vakitleri Yerelleştirmesi") {
                    presentationMode.wrappedValue.dismiss()
                }
                .padding(.bottom, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // ANA KONUM AYARI
                        SettingsGroup(header: "KONUM YÖNETİMİ", footer: "Otomatik konum (GPS) açıkken uygulama bulunduğunuz yere göre vakitleri günceller.") {
                            PremiumToggleRow(
                                title: "Otomatik Konum (GPS)",
                                icon: "location.circle.fill",
                                iconColor: .blue,
                                isOn: $viewModel.autoLocationEnabled
                            )
                        }
                        
                        // MEVCUT KONUM VE MANUEL SEÇİM
                        SettingsGroup(header: "KONUM DURUMU") {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(viewModel.autoLocationEnabled ? Color.green.opacity(0.1) : Color.orange.opacity(0.1))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: viewModel.autoLocationEnabled ? "antenna.radiowaves.left.and.right" : "mappin.and.ellipse")
                                        .foregroundColor(viewModel.autoLocationEnabled ? .green : .orange)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Geçerli Lokasyon")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.themeTextSecondary)
                                    Text(viewModel.savedLocationName.isEmpty ? "Seçili Konum Yok" : viewModel.savedLocationName)
                                        .font(.system(size: 17, weight: .bold, design: .rounded))
                                        .foregroundColor(.themeText)
                                }
                                
                                Spacer()
                                
                                if viewModel.autoLocationEnabled {
                                    Button(action: {
                                        viewModel.refreshGPSLocation()
                                    }) {
                                        if viewModel.isLocating {
                                            ProgressView()
                                                .scaleEffect(0.8)
                                        } else {
                                            Image(systemName: "arrow.clockwise.circle.fill")
                                                .font(.system(size: 22))
                                                .foregroundColor(.blue)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            
                            CustomDivider()
                            
                            Button(action: {
                                showPicker = true
                            }) {
                                HStack {
                                    Image(systemName: "pencil.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.themePrimary)
                                    Text("Veya Manuel Konum Seç")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.themeTextSecondary.opacity(0.3))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                            }
                            .foregroundColor(.themeText)
                            .disabled(viewModel.autoLocationEnabled)
                            .opacity(viewModel.autoLocationEnabled ? 0.5 : 1.0)
                        }
                        
                        // UYARI BİLGİSİ
                        if viewModel.autoLocationEnabled {
                            VStack(spacing: 12) {
                                HStack(spacing: 15) {
                                    Image(systemName: "info.circle.fill")
                                        .foregroundColor(.blue)
                                        .font(.system(size: 20))
                                    
                                    Text("GPS aktif olduğu için manuel konum seçimi devre dışıdır. Konumu el ile seçmek isterseniz yukarıdaki 'Otomatik Konum' ayarını kapatmalısınız.")
                                        .font(.system(size: 13))
                                        .foregroundColor(.themeTextSecondary)
                                        .lineLimit(nil)
                                }
                                .padding()
                                .background(Color.blue.opacity(0.05))
                                .cornerRadius(15)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 140)
                }
            }
        }
        .sheet(isPresented: $showPicker) {
            LocationPickerView()
        }
        .navigationBarHidden(true)
        .preferredColorScheme(UserDefaults.standard.integer(forKey: "appTheme") == 1 ? .light : (UserDefaults.standard.integer(forKey: "appTheme") == 2 ? .dark : nil))
    }
}
