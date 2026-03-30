import SwiftUI

struct Step3NotificationPermissionView: View {
    @Binding var currentStep: Int
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "bell.badge.fill")
                .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 120 : 80))
                .foregroundColor(.themePrimary)
            
            Text(L10n.Onboarding.Step3.title)
                .font(.adaptiveTitle)
                .foregroundColor(.themeSecondary)
            
            Text(L10n.Onboarding.Step3.desc)
                .font(.adaptiveBody)
                .multilineTextAlignment(.center)
                .foregroundColor(.themeTextDescription)
                .padding(.horizontal, 32)
            
            Spacer()
            
            Image(systemName: viewModel.permissionGranted ? "checkmark.seal.fill" : "hand.tap.fill")
                .font(.system(size: 60))
                .foregroundColor(viewModel.permissionGranted ? .green : .themeTextSecondary.opacity(0.5))
            
            Spacer()
            
            VStack(spacing: 12) {
                Button(viewModel.permissionGranted ? L10n.Common.next : L10n.Onboarding.grantPermission) {
                    if viewModel.permissionGranted {
                        currentStep += 1
                    } else {
                        viewModel.requestPermissions()
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                
                if !viewModel.permissionGranted {
                    Button(L10n.Onboarding.skip) { 
                        viewModel.disableAllNotifications()
                        currentStep = 7 
                    }
                        .buttonStyle(SecondaryButtonStyle())
                }
            }
            .padding(.bottom, 40)
        }
        .padding(.top, 60)
        .onAppear {
            Task {
                await NotificationManager.shared.updateAuthorizationStatus()
                viewModel.permissionGranted = NotificationManager.shared.isAuthorized
            }
        }
    }
}
