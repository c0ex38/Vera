import SwiftUI
import MapKit

struct NearbyMosquesView: View {
    @EnvironmentObject var container: DependencyContainer
    @StateObject private var viewModel = NearbyMosquesViewModel()
    @State private var position: MapCameraPosition = .automatic
    @State private var selectedMosque: MKMapItem?
    
    // Back navigation dismiss
    @Environment(\.presentationMode) var presentationMode
    
    @State private var hasMoved = false
    @State private var lastSearchCoordinate: CLLocationCoordinate2D?
    @State private var currentMapRegion: MKCoordinateRegion?
    
    private var header: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.themeText)
                    .frame(width: 40, height: 40)
                    .background(Color.themeBackground)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
            }
            
            Spacer()
            
            Text(L10n.NearbyMosques.title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.themeText)
            
            Spacer()
            
            Button(action: {
                if let location = container.location.finalLocation {
                    withAnimation {
                        position = .region(MKCoordinateRegion(
                            center: location.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                        ))
                        lastSearchCoordinate = location.coordinate
                    }
                }
            }) {
                Image(systemName: "location.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.themePrimary)
                    .frame(width: 40, height: 40)
                    .background(Color.themeBackground)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
            }
        }
        .padding(.horizontal)
        .padding(.top, 10)
        .padding(.bottom, 10)
        .background(Color.themeSurface.ignoresSafeArea(edges: .top))
        .shadow(color: .black.opacity(0.05), radius: 5, y: 3)
        .zIndex(1)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            ZStack(alignment: .bottom) {
                mapView
                
                // Burayı Ara Butonu
                if hasMoved {
                    VStack {
                        Button(action: {
                            searchInCurrentArea()
                        }) {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                Text("Bu Bölgede Ara")
                            }
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.themePrimary)
                            .cornerRadius(20)
                            .shadow(radius: 5)
                        }
                        .padding(.top, 20)
                        Spacer()
                    }
                }
                
                statusOverlay
                detailOverlay
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            container.location.requestLocation()
        }
        .onReceive(container.location.finalLocationPublisher) { newValue in
            if let loc = newValue, viewModel.mosques.isEmpty && !viewModel.isLoading {
                let region = MKCoordinateRegion(
                    center: loc.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
                position = .region(region)
                lastSearchCoordinate = loc.coordinate
                viewModel.fetchNearbyMosques(near: loc)
            }
        }
    }
    
    private func searchInCurrentArea() {
        if let region = currentMapRegion {
            viewModel.fetchNearbyMosques(in: region)
            lastSearchCoordinate = region.center
            withAnimation {
                hasMoved = false
            }
        }
    }
    
    private var mapView: some View {
        Map(position: $position, selection: $selectedMosque) {
            UserAnnotation()
            
            ForEach(viewModel.mosques, id: \.self) { mosque in
                Annotation(mosque.name ?? L10n.NearbyMosques.unknown, coordinate: mosque.placemark.coordinate) {
                    Button(action: {
                        withAnimation(.spring()) {
                            selectedMosque = mosque
                        }
                    }) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.themePrimary)
                            .background(Circle().fill(Color.white))
                            .shadow(radius: 3)
                    }
                }
            }
        }
        .onMapCameraChange(frequency: .continuous) { context in
            // Şu anki bölgeyi kaydet
            self.currentMapRegion = context.region
            
            // Kullanıcı haritayı hareket ettirdiğinde butonu göster
            if let last = lastSearchCoordinate {
                let distance = CLLocation(latitude: last.latitude, longitude: last.longitude)
                    .distance(from: CLLocation(latitude: context.region.center.latitude, longitude: context.region.center.longitude))
                
                // 500 metreden fazla hareket edildiyse butonu göster
                if distance > 500 {
                    withAnimation {
                        hasMoved = true
                    }
                }
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }
    
    @ViewBuilder
    private var statusOverlay: some View {
        if viewModel.isLoading {
            VStack(spacing: 12) {
                ProgressView()
                    .scaleEffect(1.2)
                Text(L10n.NearbyMosques.searching)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.themeText)
            }
            .padding(20)
            .background(.ultraThinMaterial)
            .cornerRadius(16)
            .shadow(radius: 5)
            .padding(.bottom, 130)
        } else if let error = viewModel.errorMessage {
            Text(error)
                .foregroundColor(.red)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                .padding(.bottom, 130)
        } else if viewModel.mosques.isEmpty && !viewModel.isLoading {
            // Sadece cami bulunamadıysa göster (Konum varsa)
            if container.location.location != nil {
                Text(L10n.NearbyMosques.notFound)
                    .foregroundColor(.themeTextSecondary)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .padding(.bottom, 130)
            }
        }
    }
    
    @ViewBuilder
    private var detailOverlay: some View {
        if let selected = selectedMosque {
            MosqueDetailCard(mapItem: selected, onClose: {
                withAnimation(.spring()) {
                    selectedMosque = nil
                }
            })
            .padding(.horizontal)
            .padding(.bottom, 120)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}

// Marker tıklandığında altta çıkan şık tasarım kartı
struct MosqueDetailCard: View {
    let mapItem: MKMapItem
    let onClose: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(mapItem.name ?? L10n.NearbyMosques.unknown)
                        .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 24 : 18, weight: .bold, design: .rounded))
                        .foregroundColor(.themeText)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray.opacity(0.5))
                        .font(.title2)
                }
            }
            
            Button(action: {
                mapItem.openInMaps(launchOptions: [
                    MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking
                ])
            }) {
                HStack {
                    Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                    Text(L10n.NearbyMosques.directions)
                }
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.themePrimary)
                .cornerRadius(12)
            }
        }
        .padding(20)
        .background(Color.themeSurface)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 8)
    }
}
