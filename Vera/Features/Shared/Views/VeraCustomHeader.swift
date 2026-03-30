import SwiftUI

struct VeraCustomHeader<RightContent: View>: View {
    @Environment(\.presentationMode) var presentationMode
    
    var title: String
    var subtitle: String? = nil
    var showBackButton: Bool = true
    var textColor: Color = .themeText
    var buttonBgColor: Color = .themeSurface
    var onBack: (() -> Void)? = nil
    
    @ViewBuilder var rightContent: RightContent
    
    var body: some View {
        HStack {
            if showBackButton {
                Button(action: {
                    if let onBack = onBack {
                        onBack()
                    } else {
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(textColor)
                        .padding(14)
                        .background(buttonBgColor)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.04), radius: 5, y: 2)
                }
            } else {
                // Sağdaki view ile dengeleme yapmak için boş alan
                Circle().fill(Color.clear).frame(width: 50, height: 50)
            }
            
            Spacer(minLength: 10)
            
            VStack(alignment: .center, spacing: 2) {
                Text(title)
                    .font(.adaptiveTitle)
                    .foregroundColor(textColor)
                    .kerning(1.2)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                if let subtitle = subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.adaptiveSubheadline)
                        .foregroundColor(textColor.opacity(0.8))
                        .lineLimit(1)
                }
            }
            
            Spacer(minLength: 10)
            
            rightContent
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }
}

// RightContent geçilmediğinde otomatik tamamlama konforu için
extension VeraCustomHeader where RightContent == AnyView {
    init(title: String, subtitle: String? = nil, showBackButton: Bool = true, textColor: Color = .themeText, buttonBgColor: Color = .themeSurface, onBack: (() -> Void)? = nil) {
        let emptySpacer = AnyView(Circle().fill(Color.clear).frame(width: 50, height: 50))
        self.init(title: title, subtitle: subtitle, showBackButton: showBackButton, textColor: textColor, buttonBgColor: buttonBgColor, onBack: onBack, rightContent: { emptySpacer })
    }
}

#Preview {
    ZStack {
        Color.themeBackground.ignoresSafeArea()
        VStack {
            VeraCustomHeader(title: "Örnek Başlık")
            Spacer()
        }
    }
}
