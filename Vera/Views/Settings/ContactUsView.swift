import SwiftUI

struct ContactUsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let formURL = URL(string: "https://forms.gle/3bkK2SnDU2q5yda87")!
    
    var body: some View {
        VStack(spacing: 0) {
            VeraCustomHeader(title: "Bize Ulaşın", subtitle: "Soru, görüş ve önerileriniz") {
                presentationMode.wrappedValue.dismiss()
            }
            
            WebView(url: formURL)
                .edgesIgnoringSafeArea(.bottom)
        }
        .navigationBarHidden(true)
    }
}
