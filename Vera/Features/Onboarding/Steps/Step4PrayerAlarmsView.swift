import SwiftUI

struct Step4PrayerAlarmsView: View {
    @Binding var currentStep: Int
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text(L10n.Onboarding.Step4.title)
                .font(.adaptiveTitle)
                .foregroundColor(.themeSecondary)
                .padding(.top, 40)
            
            List {
                Toggle(L10n.Prayer.imsak, isOn: $viewModel.alarmFajr)
                Toggle(L10n.Prayer.sunrise, isOn: $viewModel.alarmSunrise)
                Toggle(L10n.Prayer.dhuhr, isOn: $viewModel.alarmDhuhr)
                Toggle(L10n.Prayer.asr, isOn: $viewModel.alarmAsr)
                Toggle(L10n.Prayer.maghrib, isOn: $viewModel.alarmMaghrib)
                Toggle(L10n.Prayer.isha, isOn: $viewModel.alarmIsha)
            }
            .tint(.themePrimary)
            .scrollContentBackground(.hidden)
            
            Button(L10n.Common.next) { currentStep += 1 }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.bottom, 40)
        }
    }
}
