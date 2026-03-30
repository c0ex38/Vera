import SwiftUI

struct LibraryDetailView: View {
    let item: LibraryItem
    @State private var fontSize: CGFloat = 20
    @State private var showingCopyAlert = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            // Background
            Color.themeBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Header with Font Size Controls
                header
                
                ScrollView {
                    if let steps = item.steps, !steps.isEmpty {
                        LibraryItemStepsView(steps: steps)
                    } else {
                        VStack(spacing: 24) {
                            
                            // 1. Arabic Text
                            if let arabic = item.arabic {
                                VStack(alignment: .trailing, spacing: 8) {
                                    Text(arabic)
                                        .font(.system(size: fontSize * 1.5, weight: .regular))
                                        .multilineTextAlignment(.trailing)
                                        .lineSpacing(10)
                                        .foregroundColor(.themeText)
                                        .padding(24)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                        .background(
                                            RoundedRectangle(cornerRadius: 18)
                                                .fill(Color.themeSurface)
                                                .shadow(color: .black.opacity(0.04), radius: 10, y: 5)
                                        )
                                        .environment(\.layoutDirection, .rightToLeft)
                                }
                            }
                            
                            // 2. Transcription
                            if let trans = item.transcription {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Okunuşu")
                                        .font(.caption).bold()
                                        .foregroundColor(.themePrimary)
                                        .padding(.horizontal, 4)
                                    
                                    Text(trans)
                                        .font(.system(size: fontSize, weight: .medium, design: .serif))
                                        .foregroundColor(.themeText)
                                        .padding(16)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color.themeSurface)
                                        .cornerRadius(12)
                                }
                            }
                            
                            // 3. Meaning
                            if let meaning = item.meaning {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Meali")
                                        .font(.caption).bold()
                                        .foregroundColor(.themePrimary)
                                        .padding(.horizontal, 4)
                                    
                                    Text(meaning)
                                        .font(.system(size: fontSize, weight: .regular))
                                        .foregroundColor(.themeTextSecondary)
                                        .padding(16)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color.themeSurface)
                                        .cornerRadius(12)
                                }
                            }
                        }
                        .padding(20)
                    }
                }
            }
            
            // Bottom Font Switcher Overlay (Optional or integrated)
        }
        .navigationBarHidden(true)
        .overlay(alignment: .bottom) {
             fontControls
        }
    }
    
    // MARK: - Components
    
    private var header: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.themeText)
                    .frame(width: 40, height: 40)
                    .background(Color.themeSurface)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
            }
            
            Spacer()
            
            Text(item.title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.themeText)
                .lineLimit(1)
            
            Spacer()
            
            Button(action: copyToClipboard) {
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 18))
                    .foregroundColor(.themePrimary)
                    .frame(width: 40, height: 40)
                    .background(Color.themeSurface)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .background(Color.themeSurface.ignoresSafeArea(edges: .top))
    }
    
    private var fontControls: some View {
        HStack(spacing: 20) {
            Button(action: { if fontSize > 14 { fontSize -= 2 } }) {
                Image(systemName: "textformat.size.smaller")
                    .font(.system(size: 18))
            }
            
            Slider(value: $fontSize, in: 14...40)
                .accentColor(.themePrimary)
            
            Button(action: { if fontSize < 40 { fontSize += 2 } }) {
                Image(systemName: "textformat.size.larger")
                    .font(.system(size: 18))
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(.ultraThinMaterial)
        .cornerRadius(30)
        .padding(.horizontal, 40)
        .padding(.bottom, 30)
        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
    }
    
    private func copyToClipboard() {
        var textToCopy = item.title + "\n\n"
        if let arabic = item.arabic { textToCopy += arabic + "\n\n" }
        if let trans = item.transcription { textToCopy += "Okunuşu: " + trans + "\n\n" }
        if let meaning = item.meaning { textToCopy += "Meali: " + meaning }
        
        UIPasteboard.general.string = textToCopy
        withAnimation { showingCopyAlert = true }
        
        // Simple UI feedback could be added here
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
