import SwiftUI

struct DiscoverySection: View {
    @State private var suggestions: [HomeSuggestion] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Keşfet & Öğren")
                .font(.veraTitle)
                .foregroundColor(.themeText)
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
            }
        }
        .onAppear {
            if suggestions.isEmpty {
                suggestions = HomeSuggestion.getMultiple(count: 3)
            }
        }
    }
}
