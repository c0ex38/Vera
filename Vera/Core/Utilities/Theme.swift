import SwiftUI
import UIKit

// MARK: - Theme Management
struct Theme {
    // İslami uygulamalar için genellikle güven veren, huzurlu ve premium hissi veren renkler tercih edilir.
    // Ana renk olarak "Teal/Zümrüt Yeşili" ve tamamlayıcı vurgu olarak "Altın/Kum" tonları kullanıldı.
    
    // MARK: - Core Theme Colors
    static let primary = Color(hex: "0D9488")     // Koyu Zümrüt / Teal Yeşili (Güven, Dinçlik)
    static let secondary = Color(hex: "D4AF37")   // Altın / Kum Tonu (Premium, Saygınlık)
    
    // MARK: - Reactive Colors (Always check current traits)
    static var background: Color {
        Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor(hex: "111827") : UIColor(hex: "F9FAFB")
        })
    }
    
    static var surface: Color {
        Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor(hex: "1F2937") : UIColor(hex: "FFFFFF")
        })
    }
    
    static var surfaceSecondary: Color {
        Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor(hex: "111827").withAlphaComponent(0.5) : UIColor(hex: "F3F4F6")
        })
    }
    
    static var primarySoft: Color {
        Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor(hex: "132D2B") : UIColor(hex: "E6F4F1")
        })
    }
    
    static var text: Color {
        Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor(hex: "F9FAFB") : UIColor(hex: "111827")
        })
    }
    
    static var textSecondary: Color {
        Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor(hex: "D1D5DB") : UIColor(hex: "4B5563")
        })
    }
    
    static var textDescription: Color {
        Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor(hex: "E5E7EB") : UIColor(hex: "374151")
        })
    }
    
    // MARK: - Spacing Tokens
    struct Spacing {
        static let xxs: CGFloat = 2
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // MARK: - Typography (Premium Rounded Design)
    struct Typography {
        static func title(_ size: CGFloat = 20) -> Font {
            .system(size: size, weight: .bold, design: .rounded)
        }
        
        static func headline(_ size: CGFloat = 17) -> Font {
            .system(size: size, weight: .semibold, design: .rounded)
        }
        
        static func body(_ size: CGFloat = 15) -> Font {
            .system(size: size, weight: .medium, design: .rounded)
        }
        
        static func caption(_ size: CGFloat = 13) -> Font {
            .system(size: size, weight: .regular, design: .rounded)
        }
        
        static func tiny(_ size: CGFloat = 11) -> Font {
            .system(size: size, weight: .bold, design: .rounded)
        }
    }
}

// MARK: - Color & UIColor Extensions for Easy Hex Support
extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}

extension Color {
    init(hex: String) {
        self.init(UIColor(hex: hex))
    }
    
    // SwiftUI Görünümlerinde kolay kullanım için kısayollar
    static var themePrimary: Color { Theme.primary }
    static var themeSecondary: Color { Theme.secondary }
    static var themeBackground: Color { Theme.background }
    static var themeSurface: Color { Theme.surface }
    static var themeSurfaceSecondary: Color { Theme.surfaceSecondary }
    static var themePrimarySoft: Color { Theme.primarySoft }
    static var themeText: Color { Theme.text }
    static var themeTextSecondary: Color { Theme.textSecondary }
    static var themeTextDescription: Color { Theme.textDescription }
}

// MARK: - ShapeStyle Extension for Shorthand Support
// This allows using .foregroundStyle(.themePrimary) instead of .foregroundStyle(Color.themePrimary)
extension ShapeStyle where Self == Color {
    static var themePrimary: Color { .themePrimary }
    static var themeSecondary: Color { .themeSecondary }
    static var themeBackground: Color { .themeBackground }
    static var themeSurface: Color { .themeSurface }
    static var themeSurfaceSecondary: Color { .themeSurfaceSecondary }
    static var themePrimarySoft: Color { .themePrimarySoft }
    static var themeText: Color { .themeText }
    static var themeTextSecondary: Color { .themeTextSecondary }
    static var themeTextDescription: Color { .themeTextDescription }
}
