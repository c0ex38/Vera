import SwiftUI

struct DiscoverySection: View {
    @State private var suggestions: [HomeSuggestion] = []
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.Home.discovery)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.themeText)
                    
                    Rectangle()
                        .fill(Color.themePrimary.opacity(0.3))
                        .frame(width: 40, height: 4)
                        .cornerRadius(2)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                // iPad: 2-Column Grid
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 20), GridItem(.flexible(), spacing: 20)], spacing: 20) {
                    ForEach(suggestions) { suggestion in
                        DiscoveryCard(suggestion: suggestion)
                    }
                }
                .padding(.horizontal, 20)
            } else {
                // iPhone: Vertical Stack
                VStack(spacing: 20) {
                    ForEach(suggestions) { suggestion in
                        DiscoveryCard(suggestion: suggestion)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .onAppear {
            if suggestions.isEmpty {
                suggestions = HomeSuggestion.getMultiple(count: 3)
            }
        }
    }
}
