import SwiftUI

struct Step2CountdownPreviewView: View {
    @Binding var currentStep: Int
    @ObservedObject var viewModel: OnboardingViewModel
    @ObservedObject var countdownManager: PrayerCountdownManager
    @AppStorage("savedDistrictID") private var savedDistrictID: String = ""
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "timer")
                .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 120 : 80))
                .foregroundColor(.themePrimary)
            
            Text(L10n.Onboarding.Step2.title)
                .font(.adaptiveTitle)
                .foregroundColor(.themeSecondary)
            
            Text(L10n.Onboarding.Step2.desc)
                .font(.adaptiveBody)
                .multilineTextAlignment(.center)
                .foregroundColor(.themeTextDescription)
                .padding(.horizontal, 32)
            
            Spacer()
            
            if viewModel.isFetchingPreview {
                ProgressView(L10n.Onboarding.Step2.loading)
                    .padding(40)
            } else {
                VStack(spacing: 16) {
                    Text(L10n.Hero.timeRemaining(to: countdownManager.nextPrayerName))
                        .font(.adaptiveSubheadline)
                        .foregroundColor(.themeTextSecondary)
                    Text(countdownManager.timeRemainingString)
                        .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 60 : 40, weight: .bold, design: .rounded))
                        .foregroundColor(.themePrimary)
                }
                .padding(30)
                .background(Color.themeSurface)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.05), radius: 15, y: 5)
            }
            
            Spacer()
            
            Button(L10n.Onboarding.awesomeNext) { currentStep += 1 }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.bottom, 40)
        }
        .padding(.top, 60)
        .onAppear {
            if !savedDistrictID.isEmpty {
                viewModel.fetchPreviewPrayerTimes(districtID: savedDistrictID)
            }
        }
    }
}
