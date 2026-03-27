import SwiftUI

struct Step7FinishView: View {
    @Binding var currentStep: Int
    var completeOnboarding: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 120 : 80))
                .foregroundColor(.themePrimary)
            
            Text(L10n.Onboarding.Step7.title)
                .font(.adaptiveTitle)
                .foregroundColor(.themeSecondary)
            
            Text(L10n.Onboarding.Step7.desc)
                .font(.adaptiveBody)
                .multilineTextAlignment(.center)
                .foregroundColor(.themeTextDescription)
                .padding(.horizontal, 32)
            
            Spacer()
            
            Button(L10n.Onboarding.start) {
                completeOnboarding()
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.bottom, 40)
        }
        .padding(.top, 60)
    }
}
