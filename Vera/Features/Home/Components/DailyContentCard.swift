import SwiftUI

struct DailyContentCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(L10n.Home.dailyContent)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.themeText)
                .padding(.horizontal, 20)
            
            ZStack(alignment: .topLeading) {
                // Arkaplan
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.themeSurface)
                    .shadow(color: .black.opacity(0.04), radius: 15, y: 8)
                
                // Dev Silik Tırnak İşareti
                Image(systemName: "quote.opening")
                    .font(.system(size: 80))
                    .foregroundColor(Color.themePrimary.opacity(0.05))
                    .offset(x: -10, y: -20)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("De ki: “Şüphesiz benim namazım, ibadetlerim, hayatım ve ölümüm âlemlerin Rabbi olan Allah içindir.”")
                        .font(.system(size: 18, weight: .medium, design: .serif))
                        .foregroundColor(.themeText)
                        .lineSpacing(8)
                    
                    HStack {
                        Spacer()
                        Text("En'âm Suresi, 162. Ayet")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.themePrimary)
                    }
                }
                .padding(24)
            }
            .padding(.horizontal, 20)
        }
    }
}
