import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @State private var currentStep: Int = 1
    @ObservedObject private var preferences = PreferenceManager.shared
    
    var body: some View {
        TabView(selection: $currentStep) {
            Step1LocationView(currentStep: $currentStep).tag(1)
            Step2CountdownPreviewView(currentStep: $currentStep, viewModel: viewModel, countdownManager: viewModel.countdownManager).tag(2)
            Step3NotificationPermissionView(currentStep: $currentStep, viewModel: viewModel).tag(3)
            if viewModel.permissionGranted {
                Step4PrayerAlarmsView(currentStep: $currentStep, viewModel: viewModel).tag(4)
                Step5RemindersView(currentStep: $currentStep, viewModel: viewModel).tag(5)
                Step6iOSWarningView(currentStep: $currentStep).tag(6)
            }
            Step7FinishView(currentStep: $currentStep) {
                withAnimation {
                    preferences.hasCompletedOnboarding = true
                }
            }.tag(7)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.easeInOut, value: currentStep)
        .background(Color.themeBackground.ignoresSafeArea())
    }
}
