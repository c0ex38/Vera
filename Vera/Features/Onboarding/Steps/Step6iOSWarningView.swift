import SwiftUI

struct Step6iOSWarningView: View {
    @Binding var currentStep: Int
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "applelogo")
                .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 120 : 80))
                .foregroundColor(.themeSecondary)
            
            Text(L10n.Onboarding.Step6.title)
                .font(.adaptiveTitle)
                .foregroundColor(.themeSecondary)
            
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    Image(systemName: "speaker.slash.fill")
                        .foregroundColor(.themePrimary)
                        .frame(width: 30)
                    Text(L10n.Onboarding.Step6.warning1)
                        .font(.adaptiveBody)
                        .foregroundColor(.themeTextDescription)
                }
                HStack(alignment: .top) {
                    Image(systemName: "stopwatch.fill")
                        .foregroundColor(.themePrimary)
                        .frame(width: 30)
                    Text(L10n.Onboarding.Step6.warning2)
                        .font(.adaptiveBody)
                        .foregroundColor(.themeTextDescription)
                }
            }
            .padding()
            .background(Color.themeSurface)
            .cornerRadius(16)
            .padding(.horizontal)
            
            Spacer()
            
            Button(L10n.Onboarding.anladim) { currentStep += 1 }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.bottom, 40)
        }
        .padding(.top, 60)
    }
}
