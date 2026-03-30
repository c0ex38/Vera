import SwiftUI
import UIKit
extension Font {
    // MARK: - Legacy Adaptive Typography
    
    static var adaptiveLargeTitle: Font {
        UIDevice.current.userInterfaceIdiom == .pad ? .system(size: 44, weight: .bold) : .largeTitle
    }
    
    static var adaptiveTitle: Font {
        UIDevice.current.userInterfaceIdiom == .pad ? .system(size: 36, weight: .bold) : .title
    }
    
    static var adaptiveHeadline: Font {
        UIDevice.current.userInterfaceIdiom == .pad ? .system(size: 24, weight: .bold) : .headline
    }
    
    static var adaptiveBody: Font {
        UIDevice.current.userInterfaceIdiom == .pad ? .system(size: 20, weight: .regular) : .body
    }
    
    static var adaptiveSubheadline: Font {
        UIDevice.current.userInterfaceIdiom == .pad ? .system(size: 18, weight: .medium) : .subheadline
    }
    
    static var adaptiveFootnote: Font {
        UIDevice.current.userInterfaceIdiom == .pad ? .system(size: 16, weight: .regular) : .footnote
    }

    // MARK: - Vera Custom Typography
    
    /// Bölüm başlıkları için yuvarlatılmış ve kalın font
    static var veraTitle: Font {
        .system(size: UIDevice.current.userInterfaceIdiom == .pad ? 28 : 22, weight: .bold, design: .rounded)
    }
    
    /// Kart üzerindeki kategori etiketleri için küçük ve çok kalın font
    static var veraCardHeader: Font {
        .system(size: UIDevice.current.userInterfaceIdiom == .pad ? 16 : 14, weight: .black, design: .rounded)
    }
    
    /// Ayet, Hadis gibi okuma metinleri için orta boy Serif font
    static var veraContent: Font {
        .system(size: UIDevice.current.userInterfaceIdiom == .pad ? 22 : 18, weight: .medium, design: .serif)
    }
    
    /// Butonlar ve aksiyon yazıları için kalın ve yuvarlatılmış font
    static var veraAction: Font {
        .system(size: UIDevice.current.userInterfaceIdiom == .pad ? 18 : 15, weight: .bold, design: .rounded)
    }
    
    /// Alt başlıklar ve ikincil bilgiler için orta boy font
    static var veraSubheadline: Font {
        .system(size: UIDevice.current.userInterfaceIdiom == .pad ? 20 : 16, weight: .semibold, design: .rounded)
    }
}

extension View {
    func adaptivePadding() -> some View {
        self.padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 64 : 32)
    }
}
