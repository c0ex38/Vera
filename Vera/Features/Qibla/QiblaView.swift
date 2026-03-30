import SwiftUI

struct QiblaView: View {
    @StateObject private var viewModel = QiblaViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    // Kıbleye tam denk gelince nefes alan bir parlama efekti yaratmak için
    @State private var glowPulse: Bool = false
    private let successHaptic = UINotificationFeedbackGenerator()
    
    var body: some View {
        ZStack {
            // Dinamik Arkaplan: Kıble yönüne bakıldığında çok şık bir zümrüt/yemyeşil uzay boşluğuna döner
            LinearGradient(
                colors: viewModel.isFacingQibla 
                    ? [Color(hex: "064E3B").opacity(0.9), Color(hex: "022C22")]
                    : [Color.themeBackground, Color.themeBackground.opacity(0.95)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.8), value: viewModel.isFacingQibla)
            
            VStack(spacing: 0) {
                // Özel Header (Safe Area Sensistive)
                HStack {
                    if presentationMode.wrappedValue.isPresented {
                        Button(action: { presentationMode.wrappedValue.dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.title3.bold())
                                .foregroundColor(viewModel.isFacingQibla ? .white : .themeText)
                                .padding(12)
                                .background(viewModel.isFacingQibla ? Color.white.opacity(0.15) : Color.themeSurface)
                                .clipShape(Circle())
                        }
                    }
                    
                    Spacer()
                    
                    Text(L10n.Qibla.title)
                        .font(.title2.bold())
                        .foregroundColor(viewModel.isFacingQibla ? .white : .themeText)
                    
                    Spacer()
                    
                    if presentationMode.wrappedValue.isPresented {
                        Circle().fill(Color.clear).frame(width: 44, height: 44)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 16)
                
                if let error = viewModel.errorMsg {
                    Spacer()
                    ErrorStateView(
                        iconName: "location.slash.fill",
                        message: error
                    )
                    Spacer()
                } else {
                    
                    // Şık HUD (Head-Up Display) Derece Göstergesi
                    Text("\(String(format: "%.0f", viewModel.heading))°")
                        .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 54 : 36, weight: .light, design: .rounded))
                        .foregroundColor(viewModel.isFacingQibla ? .white : .themeText)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 8)
                        .background(
                            Capsule(style: .continuous)
                                .fill(viewModel.isFacingQibla ? Color.white.opacity(0.15) : Color.themeSurface)
                        )
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(viewModel.isFacingQibla ? Color.white.opacity(0.3) : Color.themePrimary.opacity(0.2), lineWidth: 1)
                        )
                        .padding(.bottom, 20)
                        .animation(.none, value: viewModel.heading)
                    
                    Spacer()
                    
                    // MÜKEMMEL PUSULA TASARIMI
                    ZStack {
                        Circle()
                            .fill(RadialGradient(colors: [Color.themePrimary.opacity(0.2), .clear], center: .center, startRadius: 100, endRadius: 200))
                            .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? 450 : 350, height: UIDevice.current.userInterfaceIdiom == .pad ? 450 : 350)
                            .opacity(viewModel.isFacingQibla ? 1 : 0)
                            .scaleEffect(glowPulse ? 1.05 : 0.95)
                            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: glowPulse)
                        
                        // 2. Tırtıklı Kadran Çizgileri
                        Circle()
                            .stroke(
                                viewModel.isFacingQibla ? Color.white.opacity(0.3) : Color.themePrimary.opacity(0.15),
                                style: StrokeStyle(lineWidth: 16, dash: [2, 8])
                            )
                            .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? 380 : 290, height: UIDevice.current.userInterfaceIdiom == .pad ? 380 : 290)
                        
                        // 3. Ana Pusula Zemini
                        Circle()
                            .fill(viewModel.isFacingQibla ? Color.white.opacity(0.08) : Color.themeSurface.opacity(0.7))
                            .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? 320 : 250, height: UIDevice.current.userInterfaceIdiom == .pad ? 320 : 250)
                            .shadow(color: .black.opacity(0.03), radius: 15, y: 10)
                            .overlay(
                                Circle().stroke(viewModel.isFacingQibla ? Color.white.opacity(0.3) : Color.themePrimary.opacity(0.1), lineWidth: 1)
                            )
                        
                        // 4. Sabit Yön Belirteçleri
                        ZStack {
                            Text(L10n.Qibla.north).font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 24 : 18, weight: .bold)).offset(y: UIDevice.current.userInterfaceIdiom == .pad ? -130 : -100)
                            Text(L10n.Qibla.east).font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 20 : 14, weight: .semibold)).offset(x: UIDevice.current.userInterfaceIdiom == .pad ? 130 : 100).opacity(0.4)
                            Text(L10n.Qibla.south).font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 20 : 14, weight: .semibold)).offset(y: UIDevice.current.userInterfaceIdiom == .pad ? 130 : 100).opacity(0.4)
                            Text(L10n.Qibla.west).font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 20 : 14, weight: .semibold)).offset(x: UIDevice.current.userInterfaceIdiom == .pad ? -130 : -100).opacity(0.4)
                        }
                        .foregroundColor(viewModel.isFacingQibla ? .white : .themeTextSecondary)
                        .rotationEffect(Angle(degrees: -viewModel.heading))
                        
                        // 5. Zarif Kabe İbresi
                        ZStack {
                            VStack(spacing: 0) {
                                Image(systemName: "location.north.fill")
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundColor(viewModel.isFacingQibla ? .white : .themePrimary)
                                    .offset(y: -5)
                                    .shadow(color: viewModel.isFacingQibla ? .white.opacity(0.5) : .themePrimary.opacity(0.3), radius: 6)
                                
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                viewModel.isFacingQibla ? .white : .themePrimary,
                                                viewModel.isFacingQibla ? .white.opacity(0) : .themePrimary.opacity(0)
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .frame(width: 3, height: 85)
                                    .padding(.top, -8)
                            }
                            .offset(y: -60)
                        }
                        .rotationEffect(Angle(degrees: viewModel.angleToQibla))
                        .animation(.interpolatingSpring(stiffness: 150, damping: 15), value: viewModel.angleToQibla)
                        
                        // 6. Merkez Görseli
                        ZStack {
                            Circle()
                                .fill(viewModel.isFacingQibla ? Color.white : Color.themePrimary)
                                .frame(width: 60, height: 60)
                                .shadow(color: viewModel.isFacingQibla ? .white.opacity(0.4) : .themePrimary.opacity(0.25), radius: 8, y: 4)
                            
                            Image(systemName: viewModel.isFacingQibla ? "cube.fill" : "safari.fill")
                                .font(.system(size: 24))
                                .foregroundColor(viewModel.isFacingQibla ? Color(hex: "064E3B") : .white)
                        }
                    }
                    .padding(.bottom, 20)
                    
                    Spacer()
                    
                    // Alt Mesafe ve Bilgi Kartı
                    VStack(spacing: 8) {
                    Text(viewModel.isFacingQibla ? L10n.Qibla.facing : L10n.Qibla.notFacing)
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .tracking(2.0)
                        .foregroundColor(viewModel.isFacingQibla ? .white : .themePrimary)
                        
                        if viewModel.distanceToQibla > 0 {
                            HStack(alignment: .lastTextBaseline, spacing: 4) {
                                Text(String(format: "%.0f", viewModel.distanceToQibla))
                                    .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 54 : 36, weight: .heavy, design: .rounded))
                                    .foregroundColor(viewModel.isFacingQibla ? .white : .themeText)
                                
                                Text(L10n.Common.km)
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(viewModel.isFacingQibla ? .white.opacity(0.7) : .themeTextSecondary)
                                    .padding(.bottom, 4)
                            }
                        }
                    }
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(viewModel.isFacingQibla ? Color.white.opacity(0.12) : Color.themeSurface)
                            .overlay(
                                RoundedRectangle(cornerRadius: 28, style: .continuous)
                                    .stroke(viewModel.isFacingQibla ? Color.white.opacity(0.2) : Color.themePrimary.opacity(0.1), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                    .shadow(color: .black.opacity(0.03), radius: 15, y: 10)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.start()
        }
        .onDisappear {
            viewModel.stop()
        }
    }
}

// Extracted from Theme.swift utility for hex if needed inline, though project likely has it.
// Assuming Color(hex:) is available in the project. If not, fallback using native RGB.

#Preview {
    QiblaView()
}
