import SwiftUI

struct DhikrView: View {
    @StateObject private var viewModel = DhikrViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var showTargetAlert = false
    @State private var newTargetString = ""
    @State private var showResetAlert = false
    @State private var showTesbihatSheet = false
    
    let predefinedDhikrs = [
        (L10n.Dhikr.subhanallah, 33),
        (L10n.Dhikr.elhamdulillah, 33),
        (L10n.Dhikr.allahuekber, 33),
        (L10n.Dhikr.tevhidi, 99),
        (L10n.Dhikr.salavat, 99),
        (L10n.Dhikr.estagfirullah, 100),
        (L10n.Dhikr.free, 0)
    ]
    
    var body: some View {
        ZStack {
            Color.themeBackground.ignoresSafeArea()
            
            VStack {
                // Özel Header
                VeraCustomHeader(title: L10n.Dhikr.title) {
                    HStack(spacing: 12) {
                        // Ses Aç/Kapat Butonu
                        Button(action: {
                            viewModel.isSoundEnabled.toggle()
                        }) {
                            Image(systemName: viewModel.isSoundEnabled ? "speaker.wave.3.fill" : "speaker.slash.fill")
                                .font(.title3)
                                .foregroundColor(.themePrimary)
                                .padding(14)
                                .background(Color.themeSurface)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.04), radius: 5, y: 2)
                        }
                        
                        // Sıfırlama Butonu
                        Button(action: {
                            showResetAlert = true
                        }) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.title3)
                                .foregroundColor(.themeText)
                                .padding(14)
                                .background(Color.themeSurface)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.04), radius: 5, y: 2)
                        }
                        .alert(L10n.Dhikr.resetTitle, isPresented: $showResetAlert) {
                            Button(L10n.Common.reset, role: .destructive) {
                                withAnimation(.spring()) {
                                    viewModel.reset()
                                }
                            }
                            Button(L10n.Common.cancel, role: .cancel) {}
                        } message: {
                            Text(L10n.Dhikr.resetMessage)
                        }
                    }
                }
                
                // Zikir Başlığı ve Tesbihat Seçimi
                Button(action: {
                    showTesbihatSheet = true
                }) {
                    HStack {
                        Text(viewModel.title)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.themeText)
                            .multilineTextAlignment(.center)
                        
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundColor(.themePrimary)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.themeSurface)
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.03), radius: 5, y: 2)
                }
                .padding(.top, 10)
                
                Spacer()
                
                // Mükemmel Sayaç Ekranı
                VStack(spacing: 12) {
                    Text("\(viewModel.count)")
                        .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 160 : 100, weight: .heavy, design: .rounded))
                        .foregroundColor(.themePrimary)
                        .minimumScaleFactor(0.4)
                        .lineLimit(1)
                        .padding(.horizontal)
                        .scaleEffect(viewModel.target > 0 && viewModel.count % viewModel.target == 0 && viewModel.count > 0 ? 1.1 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.5), value: viewModel.count)
                    
                    Button(action: {
                        showTargetAlert = true
                    }) {
                        HStack(spacing: 8) {
                            Text(viewModel.target > 0 ? String(format: L10n.Dhikr.target, viewModel.target) : L10n.Dhikr.noTarget)
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .tracking(1.5)
                            Image(systemName: "pencil")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundColor(.themePrimary)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(Color.themePrimary.opacity(0.1))
                        .clipShape(Capsule())
                    }
                }
                .padding(.bottom, 60)
                
                Spacer()
                
                // Devasa ve Glassmorphic Dokunmatik Buton
                Button(action: {
                    viewModel.increment()
                }) {
                    ZStack {
                        // Arkadaki Parlama (Glow)
                        Circle()
                            .fill(Color.themePrimary.opacity(0.3))
                            .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? 350 : 250, height: UIDevice.current.userInterfaceIdiom == .pad ? 350 : 250)
                            .blur(radius: 20)
                        
                        // Ana Buton Zemini
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.themePrimary, .themePrimary.opacity(0.85)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? 320 : 240, height: UIDevice.current.userInterfaceIdiom == .pad ? 320 : 240)
                            .shadow(color: .themePrimary.opacity(0.2), radius: 30, y: 15)
                        
                        // İç Çerçeve (Derinlik Hissi)
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 4)
                            .frame(width: 220, height: 220)
                        
                        // Glassmorphic İç Kavis (Işık Yansıması)
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 140, height: 140)
                            .offset(y: -30)
                            .blur(radius: 20)
                        
                        // Merkez İkon (İsteğe Bağlı)
                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white.opacity(0.7))
                            .offset(y: 10)
                    }
                }
                .buttonStyle(DhikrButtonStyle())
                
                Spacer()
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .alert(L10n.Dhikr.setTarget, isPresented: $showTargetAlert) {
            TextField(L10n.Dhikr.newTarget, text: $newTargetString)
                .keyboardType(.numberPad)
            Button(L10n.Common.save, action: {
                if let newTarget = Int(newTargetString), newTarget > 0 {
                    viewModel.target = newTarget
                }
                newTargetString = ""
            })
            Button(L10n.Common.cancel, role: .cancel, action: {
                newTargetString = ""
            })
        } message: {
            Text(L10n.Dhikr.targetDesc)
        }
        .sheet(isPresented: $showTesbihatSheet) {
            NavigationView {
                List {
                    ForEach(predefinedDhikrs, id: \.0) { dhikr in
                        Button(action: {
                            viewModel.loadTemplate(newTitle: dhikr.0, newTarget: dhikr.1)
                            showTesbihatSheet = false
                        }) {
                            HStack {
                                Text(dhikr.0)
                                    .font(.headline)
                                    .foregroundColor(.themeText)
                                Spacer()
                                if dhikr.1 > 0 {
                                    Text("\(dhikr.1)")
                                        .font(.subheadline)
                                        .foregroundColor(.themeTextSecondary)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Color.themePrimary.opacity(0.1))
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }
                }
                .navigationTitle(L10n.Dhikr.selectTesbihat)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(L10n.Common.close) {
                            showTesbihatSheet = false
                        }
                    }
                }
            }
            .navigationViewStyle(.stack)
            .presentationDetents([.medium, .large])
        }
    }
}

// Özel Yaylı Tıklama Animasyonu
struct DhikrButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.90 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.5), value: configuration.isPressed)
    }
}

#Preview {
    DhikrView()
}
