import SwiftUI

struct Step1LocationView: View {
    @Binding var currentStep: Int
    @StateObject private var gpsViewModel = HomeViewModel()
    @State private var showPicker = false
    @AppStorage("savedDistrictID") private var savedDistrictID: String = ""
    @AppStorage("savedLocationName") private var savedLocationName: String = ""
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "mappin.and.ellipse")
                .font(.system(size: 80))
                .foregroundColor(.themePrimary)
            
            Text(L10n.Onboarding.Step1.title)
                .font(.adaptiveTitle)
                .foregroundColor(.themeSecondary)
            
            Text(L10n.Onboarding.Step1.desc)
                .font(.adaptiveBody)
                .multilineTextAlignment(.center)
                .foregroundColor(.themeTextDescription)
                .padding(.horizontal, 32)
            
            Spacer()
            
            if !savedDistrictID.isEmpty {
                VStack(spacing: 8) {
            Text(L10n.Location.selected).font(.subheadline)
            Text(savedLocationName).font(.headline).foregroundColor(.themePrimary)
            Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
        }
        .padding()
        .background(Color.themePrimary.opacity(0.1))
        .cornerRadius(12)
    } else if gpsViewModel.state == .requestingLocation || gpsViewModel.state == .matchingAPI {
        ProgressView(L10n.Location.searching)
            .padding()
    } else if case .error(let msg) = gpsViewModel.state {
        Text(msg)
            .font(.footnote)
            .foregroundColor(.red)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
    }
    
    VStack(spacing: 12) {
        if savedDistrictID.isEmpty {
            Button(action: {
                gpsViewModel.start()
            }) {
                HStack {
                    Image(systemName: "location.fill")
                    Text(L10n.Location.auto)
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            
            Button(L10n.Location.manual) { showPicker = true }
                .buttonStyle(SecondaryButtonStyle())
        } else {
            Button(L10n.Common.next) { currentStep += 1 }
                .buttonStyle(PrimaryButtonStyle())
            
            Button(L10n.Location.change) { showPicker = true }
                .buttonStyle(SecondaryButtonStyle())
        }
    }
            .padding(.bottom, 40)
        }
        .padding(.top, 60)
        .sheet(isPresented: $showPicker) { LocationPickerView() }
    }
}
