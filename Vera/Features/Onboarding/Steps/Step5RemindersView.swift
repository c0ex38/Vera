import SwiftUI

struct Step5RemindersView: View {
    @Binding var currentStep: Int
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "clock.badge.exclamationmark")
                .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 120 : 80))
                .foregroundColor(.themePrimary)
            
            Text(L10n.Onboarding.Step5.title)
                .font(.adaptiveTitle)
                .foregroundColor(.themeSecondary)
            
            Text(L10n.Onboarding.Step5.desc)
                .font(.adaptiveBody)
                .multilineTextAlignment(.center)
                .foregroundColor(.themeTextDescription)
                .padding(.horizontal, 32)
            
            Spacer()
            
            VStack {
                Toggle(L10n.Onboarding.Step5.toggle, isOn: $viewModel.enableReminders)
                    .padding()
                
                if viewModel.enableReminders {
                    Divider()
                    HStack {
                        Text(L10n.Onboarding.Step5.durationTitle)
                        Spacer()
                        Picker("", selection: $viewModel.reminderMinutes) {
                            Text(L10n.Onboarding.Step5.minutes(15)).tag(15)
                            Text(L10n.Onboarding.Step5.minutes(30)).tag(30)
                            Text(L10n.Onboarding.Step5.minutes(45)).tag(45)
                        }
                    }
                    .padding()
                }
            }
            .background(Color.themeSurface)
            .cornerRadius(16)
            .padding(.horizontal)
            
            Spacer()
            
            Button(L10n.Common.next) { currentStep += 1 }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.bottom, 40)
        }
        .padding(.top, 60)
    }
}
